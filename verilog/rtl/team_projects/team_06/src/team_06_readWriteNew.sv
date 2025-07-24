module team_06_readWriteNew (
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
    output logic write, // When we are physically reading from memory
    output logic read // When we are physically writing from memory 
);

// SRAM STATE MACHINE - IDLE is when you are not reading or writing, READPROCESS / WRITEPROCESS is when you are doing the processing
// but not actually reading or writing to SRAM, READ/WRITE is when you begin reading/writing, and BUSY is when you are waiting for SRAM

typedef enum logic [2:0] {IDLE, READ, READPROCESS, WRITE, WRITEPROCESS, BUSY} state_SRAM;
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
    case (sram)
        IDLE:  
        begin
            if (record) begin // record command from audio effects 
                sram_n = WRITEPROCESS;
            end else if (search && goodData) begin // search command from audio effects. While in modeReset, you are unable to read
                sram_n = READPROCESS;
            end else begin
                sram_n = IDLE;
            end
        end
    endcase
end

endmodule