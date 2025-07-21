module team_06_readWrite (
    input logic clk, rst,
    input logic [31:0] busAudioRead, // The data that is coming from the SRAM bus (only valid when not busy)
    input logic [12:0] offset, // How many samples into the past are you going (0 is current, all 1s is the oldest)
    input logic [7:0] effectAudioIn, // The audio coming in from the audio effect module for storage
    input logic search, // Audio effects module telling the read write module it is time to read from SRAM
    input logic record, // Audio effects module telling the read write module it is time to write effectAudioIn to SRAM
    input logic effect, // This is needed so that when the effect changes, we stop reading from SRAM and wait till it has all been overwritten
    input logic busySRAM, // This comes from SRAM when it is not done reading or writing
    output logic [31:0] busAudioWrite, // This is what you want to write to SRAM
    output logic [31:0] addressOut, // goes to SRAM, where we want to write in memory
    output logic [7:0] audioOutput, // the audio output that goes to the audio effects module
    output logic [3:0] select, // goes to SRAM, which bytes we want in the four byte word (we always want all of them for efficency)
    output logic write, //
    output logic read
);

// SRAM STATE MACHINE - IDLE is when you are not reading or writing, READ/WRITE is when you begin reading/writing, and BUSY is when you are waiting for SRAM

typedef enum logic [1:0] {IDLE, READ, WRITE, BUSY} state_SRAM;
state_SRAM sram, sram_n;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        sram <= IDLE;
    end else begin
        sram <= sram_n;
    end
end

always_comb begin
    if (sram == IDLE) begin
        if (record) begin // record command from audio effects 
        sram_n = WRITE;
        end else if (search && goodData) begin // search command from audio effects. While in modeReset, you are unable to read as the data is not good
        sram_n = READ;
        end else begin
        sram_n = IDLE;
        end
    end else if (sram == BUSY) begin
        if (!busySRAM) begin // If the SRAM is no longer busy, wait for a new command
            sram_n = IDLE;
        end else sram_n = BUSY; 
    end else begin
        sram_n = BUSY; // You should only be in WRITE or READ for one cycle, therefore, we go to BUSY if not IDLE or BUSY
    end
end

// POINTER ARITHMETIC and SRAM cleaning
logic [12:0] pointer, pointer_n, dataEvaluation, dataEvaluation_n; // Pointer counts each byte in memory. 0 is 0x33....0, 1 is 0x33.....1
logic [1:0] pointer2; // pointer2 is used later to find when we have four bytes of data to send to SRAM
logic goodData, goodData_n; // Whether your data is good
logic effect_old;


always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        pointer <= 0;
        dataEvaluation <= 0;
        goodData <= 0;
        effect_old <= 0;
    end else begin
        pointer <= pointer_n;
        dataEvaluation <= dataEvaluation_n;
        goodData <= goodData_n;
        effect_old <= effect;
    end
end

assign pointer2 = pointer[1:0]; 

always_comb begin

    dataEvaluation_n = dataEvaluation;
    goodData_n = goodData;

    if (effect_old != effect) begin // If we reset the mode, we designate the last memory address to clean
        dataEvaluation_n = pointer;
        goodData_n = 0;
    end else if (dataEvaluation == pointer) begin // If we reach the last memory address, we should have clean data next clock cycle
        goodData_n = 1;
    end

    if (sram == WRITE) begin
        pointer_n = pointer + 1;
    end else begin
        pointer_n = pointer;
    end
end

// ADDRESS CALCULATION

logic [10:0] address, address_n; // The address represents a word. 0 is 0x33000000, 1 is 0x33000004, ect.
logic [12:0] inter; // just some intermediate variable for bit addressing

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        address <= 0;
    end else begin
        address <= address_n;
    end
end

always_comb begin
    inter = 'b0; 
    if (sram == WRITE) begin
        address_n = pointer[12:2]; // This is so that you are not selecting bits zero through 3, which are all given by SRAM if you request 4
    end else if (sram == BUSY) begin
        address_n = address;
    end else begin
        inter = pointer + offset;
        address_n = inter[12:2]; // This is so that you are not selecting bits zero through 3, which are all given by SRAM if you request 4
    end
    addressOut = 32'h33000000 + {19'b0, address, 2'b0}; // The global address space begins at 33000000 in hex
end

// READER - What reads from memory 

typedef enum logic {WAIT, REQUEST} state_reader; // Both the reader and writer can either be waiting for the SRAM state change or completing a request.
// Note that the actual state of the SRAM changes due to the reader and writer sections

logic [10:0] audioLocation, audioLocation_n; // Stores the address of the most recent audio file (word)
logic [7:0] audioOutput_n; // What the audio effect modules receieve
logic [31:0] audioSample, audioSample_n; // Most recent audio file (word)
logic read_n; 

always_ff @ (posedge clk, posedge rst) begin
    if (rst) begin
        read <= WAIT; 
        audioSample <= 0;
        audioOutput <= 0;
        audioLocation <= 0;
    end else begin
        read <= read_n;
        audioSample <= audioSample_n;
        audioLocation <= audioLocation_n;
        audioOutput <= audioOutput_n;
    end
end

always_comb begin
    audioSample_n = audioSample; 
    audioOutput_n = audioOutput;
    audioLocation_n = audioLocation;
    if (!goodData) begin  // If we do not have good data, just stop reading and clear everything
        read_n = WAIT;
        audioSample_n = 0;
        audioOutput_n = 0;
        audioLocation_n = 0; 
    end else if (sram == READ) begin
        if (audioLocation != address) begin // If the word has changed
            read_n = REQUEST;
        end else begin  // If we have not changed the word we are looking at, no need to read 
                        // from memory as it is stored in a register! Good for consecutive audio samples in memory.
            read_n = WAIT;
        end
    end else if (read == REQUEST && busySRAM == 0) begin // If we are done with our request, update the output
        read_n = WAIT;
        audioSample_n = busAudioRead;
        audioOutput_n = busAudioRead[pointer2*8+:8]; // This selects the correct quarter of the audio output, ex: 0-7, 8-15, 16-23, 24-31
        audioLocation_n = address;
    end else begin
        read_n = read;
    end
end

// WRITER
logic [31:0] audioTemp_n, audioTemp, busAudioWrite_n;
logic write_n;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        busAudioWrite <= 0;
        audioTemp <= 0;
        write <= 0;
    end else begin
        busAudioWrite <= busAudioWrite_n;
        write <= write_n;
        audioTemp <= audioTemp_n;
    end
end 

always_comb begin
    audioTemp_n = audioTemp;
    busAudioWrite_n = busAudioWrite;
    if (sram == WRITE) begin
        audioTemp_n[pointer2*8+:8] = effectAudioIn; // add the sample to audioTemp
        write_n = WAIT;
        if (pointer2 == 3) begin
            busAudioWrite_n = audioTemp_n; // Important, make sure this is after you update audioTemp_n
            write_n = REQUEST;
        end
    end else if (write == REQUEST && busySRAM == 0) begin // If the request has completed, go back to waiting
        write_n = WAIT; 
    end
    else begin // Do not change anything if our state has not changed
        audioTemp_n = audioTemp;
        busAudioWrite_n = busAudioWrite;
        write_n = write;
    end
end

endmodule
// module team_06_readWrite (
//     input logic clk, rst,
//     input logic [31:0] busAudioRead, // Data from SRAM (valid when not busy)
//     input logic [12:0] offset,       // Delay offset (0 = current, all 1s = oldest)
//     input logic [7:0] effectAudioIn, // Audio to store in SRAM
//     input logic search,              // Request to read from SRAM
//     input logic record,              // Request to write to SRAM
//     input logic effect,              // Effect mode (reset on change)
//     input logic busySRAM,            // SRAM busy signal
//     output logic [31:0] busAudioWrite, // Data to write to SRAM
//     output logic [31:0] addressOut,   // SRAM address
//     output logic [7:0] audioOutput,   // Audio to effect module
//     output logic [3:0] select,        // Byte select (always all bytes)
//     output logic write,               // SRAM write enable
//     output logic read                 // SRAM read enable
// );

//     // SRAM state machine
//     typedef enum logic [1:0] {IDLE, READ, WRITE, BUSY} state_SRAM;
//     state_SRAM sram, sram_n;

//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             sram <= IDLE;
//         end else begin
//             sram <= sram_n;
//         end
//     end

//     always_comb begin
//         sram_n = sram;
//         case (sram)
//             IDLE: begin
//                 if (record) begin
//                     sram_n = WRITE;
//                 end else if (search && goodData) begin
//                     sram_n = READ;
//                 end
//             end
//             BUSY: begin
//                 if (!busySRAM) begin
//                     sram_n = IDLE;
//                 end
//             end
//             READ, WRITE: begin
//                 sram_n = BUSY;
//             end
//             default: sram_n = IDLE;
//         endcase
//     end

//     // Pointer arithmetic and SRAM cleaning
//     logic [12:0] pointer, pointer_n, dataEvaluation, dataEvaluation_n;
//     logic [1:0] pointer2;
//     logic goodData, goodData_n;
//     logic effect_old;

//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             pointer <= 0;
//             dataEvaluation <= 0;
//             goodData <= 0;
//             effect_old <= 0;
//         end else begin
//             pointer <= pointer_n;
//             dataEvaluation <= dataEvaluation_n;
//             goodData <= goodData_n;
//             effect_old <= effect;
//         end
//     end

//     assign pointer2 = pointer[1:0];

//     always_comb begin
//         dataEvaluation_n = dataEvaluation;
//         goodData_n = goodData;
//         pointer_n = pointer;

//         if (effect_old != effect) begin
//             dataEvaluation_n = pointer;
//             goodData_n = 0;
//         end else if (dataEvaluation == pointer && pointer != 0) begin
//             goodData_n = 1;
//         end

//         if (sram == WRITE && !busySRAM) begin
//             pointer_n = pointer + 1;
//         end
//     end

//     // Address calculation
//     logic [10:0] address, address_n;
//     logic [12:0] inter;

//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             address <= 0;
//         end else begin
//             address <= address_n;
//         end
//     end

//     always_comb begin
//         inter = pointer + offset;
//         if (sram == WRITE) begin
//             address_n = pointer[12:2];
//         end else if (sram == BUSY) begin
//             address_n = address;
//         end else begin
//             address_n = inter[12:2] > 8191 ? 8191 : inter[12:2]; // Prevent overflow
//         end
//         addressOut = 32'h33000000 + {19'b0, address, 2'b0};
//     end

//     // Reader
//     typedef enum logic {WAIT, REQUEST} state_reader;
//     state_reader read_state, read_state_n;
//     logic [10:0] audioLocation, audioLocation_n;
//     logic [7:0] audioOutput_n;
//     logic [31:0] audioSample, audioSample_n;

//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             read_state <= WAIT;
//             audioSample <= 0;
//             audioOutput <= 0;
//             audioLocation <= 0;
//         end else begin
//             read_state <= read_state_n;
//             audioSample <= audioSample_n;
//             audioOutput <= audioOutput_n;
//             audioLocation <= audioLocation_n;
//         end
//     end

//     always_comb begin
//         audioSample_n = audioSample;
//         audioOutput_n = audioOutput;
//         audioLocation_n = audioLocation;
//         read_state_n = read_state;

//         if (!goodData) begin
//             read_state_n = WAIT;
//             audioSample_n = 0;
//             audioOutput_n = 0;
//             audioLocation_n = 0;
//         end else if (sram == READ) begin
//             if (audioLocation != address) begin
//                 read_state_n = REQUEST;
//             end else begin
//                 read_state_n = WAIT;
//             end
//         end else if (read_state == REQUEST && !busySRAM) begin
//             read_state_n = WAIT;
//             audioSample_n = busAudioRead;
//             audioOutput_n = busAudioRead[pointer2*8+:8];
//             audioLocation_n = address;
//         end
//     end

//     assign read = (read_state == REQUEST);

//     // Writer
//     state_reader write_state, write_state_n;
//     logic [31:0] audioTemp, audioTemp_n, busAudioWrite_n;

//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             busAudioWrite <= 0;
//             audioTemp <= 0;
//             write_state <= WAIT;
//         end else begin
//             busAudioWrite <= busAudioWrite_n;
//             audioTemp <= audioTemp_n;
//             write_state <= write_state_n;
//         end
//     end

//     always_comb begin
//         audioTemp_n = audioTemp;
//         busAudioWrite_n = busAudioWrite;
//         write_state_n = write_state;
//         select = 4'b1111; // Always write all bytes

//         if (sram == WRITE && !busySRAM) begin
//             audioTemp_n[pointer2*8+:8] = effectAudioIn;
//             if (pointer2 == 3) begin
//                 busAudioWrite_n = audioTemp_n;
//                 write_state_n = REQUEST;
//             end else begin
//                 write_state_n = WAIT;
//             end
//         end else if (write_state == REQUEST && !busySRAM) begin
//             write_state_n = WAIT;
//         end
//     end

//     assign write = (write_state == REQUEST);
// endmodule
// module team_06_readWrite (
//     input logic clk, rst,
//     input logic [31:0] busAudioRead, // The data that is coming from the SRAM bus (only valid when not busy)
//     input logic [12:0] offset, // How many samples into the past are you going (0 is current, all 1s is the oldest)
//     input logic [7:0] effectAudioIn, // The audio coming in from the audio effect module for storage
//     input logic search, // Audio effects module telling the read write module it is time to read from SRAM
//     input logic record, // Audio effects module telling the read write module it is time to write effectAudioIn to SRAM
//     input logic effect, // This is needed so that when the effect changes, we stop reading from SRAM and wait till it has all been overwritten
//     input logic busySRAM, // This comes from SRAM when it is not done reading or writing
//     output logic [31:0] busAudioWrite, // This is what you want to write to SRAM
//     output logic [31:0] addressOut, // goes to SRAM, where we want to write in memory
//     output logic [7:0] audioOutput, // the audio output that goes to the audio effects module
//     output logic [3:0] select, // goes to SRAM, which bytes we want in the four byte word (we always want all of them for efficency)
//     output logic write, //
//     output logic read
// );

// // SRAM STATE MACHINE - IDLE is when you are not reading or writing, READ/WRITE is when you begin reading/writing, and BUSY is when you are waiting for SRAM

// typedef enum logic [1:0] {IDLE, READ, WRITE, BUSY} state_SRAM;
// state_SRAM sram, sram_n;

// always_ff @(posedge clk, posedge rst) begin
//     if (rst) begin
//         sram <= IDLE;
//     end else begin
//         sram <= sram_n;
//     end
// end

// always_comb begin
//     if (sram == IDLE) begin
//         if (record) begin // record command from audio effects 
//         sram_n = WRITE;
//         end else if (search && goodData) begin // search command from audio effects. While in modeReset, you are unable to read as the data is not good
//         sram_n = READ;
//         end else begin
//         sram_n = IDLE;
//         end
//     end else if (sram == BUSY) begin
//         if (!busySRAM) begin // If the SRAM is no longer busy, wait for a new command
//             sram_n = IDLE;
//         end else sram_n = BUSY; 
//     end else begin
//         sram_n = BUSY; // You should only be in WRITE or READ for one cycle, therefore, we go to BUSY if not IDLE or BUSY
//     end
// end

// // POINTER ARITHMETIC and SRAM cleaning
// logic [12:0] pointer, pointer_n, dataEvaluation, dataEvaluation_n; // Pointer counts each byte in memory. 0 is 0x33....0, 1 is 0x33.....1
// logic [1:0] pointer2; // pointer2 is used later to find when we have four bytes of data to send to SRAM
// logic goodData, goodData_n; // Whether your data is good
// logic effect_old;


// always_ff @(posedge clk, posedge rst) begin
//     if (rst) begin
//         pointer <= 0;
//         dataEvaluation <= 0;
//         goodData <= 0;
//         effect_old <= 0;
//     end else begin
//         pointer <= pointer_n;
//         dataEvaluation <= dataEvaluation_n;
//         goodData <= goodData_n;
//         effect_old <= effect;
//     end
// end

// assign pointer2 = pointer[1:0]; 

// always_comb begin

//     dataEvaluation_n = dataEvaluation;
//     goodData_n = goodData;

//     if (effect_old != effect) begin // If we reset the mode, we designate the last memory address to clean
//         dataEvaluation_n = pointer;
//         goodData_n = 0;
//     end else if (dataEvaluation == pointer) begin // If we reach the last memory address, we should have clean data next clock cycle
//         goodData_n = 1;
//     end

//     if (sram == WRITE) begin
//         pointer_n = pointer + 1;
//     end else begin
//         pointer_n = pointer;
//     end
// end

// // ADDRESS CALCULATION

// logic [10:0] address, address_n; // The address represents a word. 0 is 0x33000000, 1 is 0x33000004, ect.
// logic [12:0] inter; // just some intermediate variable for bit addressing

// always_ff @(posedge clk, posedge rst) begin
//     if (rst) begin
//         address <= 0;
//     end else begin
//         address <= address_n;
//     end
// end

// always_comb begin
//     inter = 'b0; 
//     if (sram == WRITE) begin
//         address_n = pointer[12:2]; // This is so that you are not selecting bits zero through 3, which are all given by SRAM if you request 4
//     end else if (sram == BUSY) begin
//         address_n = address;
//     end else begin
//         inter = pointer + offset;
//         address_n = inter[12:2]; // This is so that you are not selecting bits zero through 3, which are all given by SRAM if you request 4
//     end
//     addressOut = 32'h33000000 + {19'b0, address, 2'b0}; // The global address space begins at 33000000 in hex
// end

// // READER - What reads from memory 

// typedef enum logic {WAIT, REQUEST} state_reader; // Both the reader and writer can either be waiting for the SRAM state change or completing a request.
// // Note that the actual state of the SRAM changes due to the reader and writer sections

// logic [10:0] audioLocation, audioLocation_n; // Stores the address of the most recent audio file (word)
// logic [7:0] audioOutput_n; // What the audio effect modules receieve
// logic [31:0] audioSample, audioSample_n; // Most recent audio file (word)
// logic read_n; 

// always_ff @ (posedge clk, posedge rst) begin
//     if (rst) begin
//         read <= WAIT; 
//         audioSample <= 0;
//         audioOutput <= 0;
//         audioLocation <= 0;
//     end else begin
//         read <= read_n;
//         audioSample <= audioSample_n;
//         audioLocation <= audioLocation_n;
//         audioOutput <= audioOutput_n;
//     end
// end

// always_comb begin
//     audioSample_n = audioSample; 
//     audioOutput_n = audioOutput;
//     audioLocation_n = audioLocation;
//     if (!goodData) begin  // If we do not have good data, just stop reading and clear everything
//         read_n = WAIT;
//         audioSample_n = 0;
//         audioOutput_n = 0;
//         audioLocation_n = 0; 
//     end else if (sram == READ) begin
//         if (audioLocation != address) begin // If the word has changed
//             read_n = REQUEST;
//         end else begin  // If we have not changed the word we are looking at, no need to read 
//                         // from memory as it is stored in a register! Good for consecutive audio samples in memory.
//             read_n = WAIT;
//         end
//     end else if (read == REQUEST && busySRAM == 0) begin // If we are done with our request, update the output
//         read_n = WAIT;
//         audioSample_n = busAudioRead;
//         audioOutput_n = busAudioRead[pointer2*8+:8]; // This selects the correct quarter of the audio output, ex: 0-7, 8-15, 16-23, 24-31
//         audioLocation_n = address;
//     end else begin
//         read_n = read;
//     end
// end

// // WRITER
// logic [31:0] audioTemp_n, audioTemp, busAudioWrite_n;
// logic write_n;

// always_ff @(posedge clk, posedge rst) begin
//     if (rst) begin
//         busAudioWrite <= 0;
//         audioTemp <= 0;
//         write <= 0;
//     end else begin
//         busAudioWrite <= busAudioWrite_n;
//         write <= write_n;
//         audioTemp <= audioTemp_n;
//     end
// end 

// always_comb begin
//     audioTemp_n = audioTemp;
//     busAudioWrite_n = busAudioWrite;
//     if (sram == WRITE) begin
//         audioTemp_n[pointer2*8+:8] = effectAudioIn; // add the sample to audioTemp
//         write_n = WAIT;
//         if (pointer2 == 3) begin
//             busAudioWrite_n = audioTemp_n; // Important, make sure this is after you update audioTemp_n
//             write_n = REQUEST;
//         end
//     end else if (write == REQUEST && busySRAM == 0) begin // If the request has completed, go back to waiting
//         write_n = WAIT; 
//     end
//     else begin // Do not change anything if our state has not changed
//         audioTemp_n = audioTemp;
//         busAudioWrite_n = busAudioWrite;
//         write_n = write;
//     end
// end

// endmodule
// My prediction was correcct