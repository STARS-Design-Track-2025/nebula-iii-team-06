module team_06_readWrite (
    input logic clk, rst,
    input logic [31:0] busAudioRead,
    input logic [12:0] offset,
    input logic [7:0] micAudio,
    input logic search,
    input logic record,
    input logic busySRAM,
    output logic [31:0] busAudioWrite,
    output logic [31:0] addressOut, // goes to SRAM
    output logic [7:0] audioOutput, //past output
    output logic [3:0] select,
    output logic write,
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
        end else if (search) begin // search command from audio effects
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

// POINTER ARITHMETIC 
logic [12:0] pointer, pointer_n; // Pointer counts each byte in memory. 0 is 0x33....0, 1 is 0x33.....1
logic [1:0] pointer2; // pointer2 is used later to find when we have four bytes of data to send to SRAM

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        pointer <= 0;
    end else begin
        pointer <= pointer_n;
    end
end

assign pointer2 = pointer[1:0]; 

always_comb begin
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

always_comb begin
    audioSample_n = audioSample; 
    audioOutput_n = audioOutput;
    audioLocation_n = audioLocation;
    if (sram == READ) begin
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
        audioTemp_n[pointer2*8+:8] = micAudio; // add the sample to audioTemp
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