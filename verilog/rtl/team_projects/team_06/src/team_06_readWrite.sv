module team_06_readWrite (
    input logic clk, rst,
    input logic [31:0] busAudioRead, // The data that is coming from the SRAM bus (only valid when not busy)
    input logic [12:0] offset, // How many samples into the past are you going (0 is current, all 1s is the oldest)
    input logic [7:0] effectAudioIn, // The audio coming in from the audio effect module for storage
    input logic search, // Audio effects module telling the read write module it is time to read from SRAM
    input logic record, // Audio effects module telling the read write module it is time to write effectAudioIn to SRAM
    input logic [2:0] effect, // This is needed so that when the effect changes, we stop reading from SRAM and wait till it has all been overwritten
    input logic busySRAM, // This comes from SRAM when it is not done reading or writing
    output logic [31:0] busAudioWrite, // This is what you want to write to SRAM
    output logic [31:0] addressOut, // goes to SRAM, where we want to write in memory
    output logic [7:0] audioOutput, // the audio output that goes to the audio effects module
    output logic [3:0] select, // goes to SRAM, which bytes we want in the four byte word (we always want all of them for efficency)
    output logic write, //
    output logic readEdge
);

// SRAM STATE MACHINE - IDLE is when you are not reading or writing, READ/WRITE is when you begin reading/writing, and BUSY is when you are waiting for SRAM

typedef enum logic [1:0] {IDLE, READ, WRITE, BUSY} state_SRAM;
state_SRAM sram, sram_n;
logic sramOld;

assign select = 4'b1111;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        sram <= IDLE;
        sramOld <= 0;
    end else begin
        sram <= sram_n;
        sramOld <= busySRAM;
    end
end

always_comb begin
    if (sram == IDLE) begin
        if (record) begin // record command from audio effects 
        sram_n = WRITE;
        end else if (search && goodData && (audioLocation != address)) begin // search command from audio effects. While in modeReset, you are unable to read as the data is not good
        sram_n = READ;
        end else begin
        sram_n = IDLE;
        end
    end else if (sram == BUSY) begin
        if ( (!busySRAM && sramOld) || readDone || writeDone) begin // If the SRAM is no longer busy, wait for a new command
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
logic [2:0] effect_old;


always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        pointer <= 0;
        dataEvaluation <= 0;
        goodData <= 1;
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

logic [10:0] address, address_n; // The address represents a word. 0 is 0x33000000, 1 is 0x33000001, ect.
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
        inter = pointer - offset;
        address_n = inter[12:2]; // This is so that you are not selecting bits zero through 3, which are all given by SRAM if you request 4
    end
    addressOut = 32'h33000000 + {21'b0, address}; // The global address space begins at 33000000 in hex
end

// READER - What reads from memory 

typedef enum logic {WAIT, REQUEST} state_reader; // Both the reader and writer can either be waiting for the SRAM state change or completing a request.
// Note that the actual state of the SRAM changes due to the reader and writer sections

logic [10:0] audioLocation, audioLocation_n; // Stores the address of the most recent audio file (word)
logic [7:0] audioOutput_n; // What the audio effect modules receieve
logic [31:0] audioSample, audioSample_n; // Most recent audio file (word)
logic read, read_n, readOld, readOld2, readDone, readDone_n;

always_ff @ (posedge clk, posedge rst) begin
    if (rst) begin
        read <= WAIT; 
        audioSample <= 0;
        audioOutput <= 0;
        audioLocation <= 11'b0;
        readOld <= 0;
        sramOld <= 0;
        readDone <= 0;
    end else begin
        read <= read_n;
        audioSample <= audioSample_n;
        audioLocation <= audioLocation_n;
        audioOutput <= audioOutput_n;
        readOld <= read;
        readOld2 <= readOld;
        sramOld <= busySRAM;
        readDone <= readDone_n;
    end
end

always_comb begin
    audioSample_n = audioSample; 
    audioOutput_n = audioOutput;
    audioLocation_n = audioLocation;
    readDone_n = 0;
    if (!goodData) begin  // If we do not have good data, just stop reading and clear everything
        read_n = WAIT;
        audioSample_n = 0;
        audioOutput_n = 0;
        audioLocation_n = 0; 
    end else if (sram == READ) begin
        read_n = REQUEST;
    end else if (read == REQUEST && busySRAM == 0 && sramOld == 1) begin // If we are done with our request, update the output
        read_n = WAIT;
        audioSample_n = busAudioRead;
        audioOutput_n = busAudioRead[pointer2*8+:8]; // This selects the correct quarter of the audio output, ex: 0-7, 8-15, 16-23, 24-31
        audioLocation_n = address;
    end else begin
        read_n = read;
    end

    readEdge = (readOld == 0 && read == 1) ? 1 : 0;
end

// WRITER
logic [31:0] audioTemp_n, audioTemp, busAudioWrite_n;
logic write_n, writeDone, writeDone_n;
always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        busAudioWrite <= 0;
        audioTemp <= 0;
        write <= 0;
        writeDone <= 0;
    end else begin
        busAudioWrite <= busAudioWrite_n;
        write <= write_n;
        audioTemp <= audioTemp_n;
        writeDone <= writeDone_n;
    end
end 

always_comb begin
    audioTemp_n = audioTemp;
    busAudioWrite_n = busAudioWrite;
    writeDone_n = 0;
    if (sram == WRITE) begin
        audioTemp_n[pointer2*8+:8] = effectAudioIn; // add the sample to audioTemp
        write_n = WAIT;
        writeDone_n = 1;
        if (pointer2 == 3) begin
            busAudioWrite_n = audioTemp_n; // Important, make sure this is after you update audioTemp_n
            write_n = REQUEST;
            writeDone_n = 0;
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