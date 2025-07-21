`timescale 1ms/10ps

module team_06_readWrite_tb;

    logic clk;
    logic rst;
    logic [31:0] busAudioRead;
    logic [12:0] offset;
    logic [7:0] effectAudioIn;
    logic search;
    logic record;
    logic effect;
    logic busySRAM;
    logic [31:0] busAudioWrite;
    logic [31:0] addressOut;
    logic [7:0] audioOutput;
    logic [3:0] select;
    logic write;
    logic read;


team_06_readWrite sahur (
.clk(clk),
.rst(rst),
.busAudioRead(busAudioRead),
.offset(offset),
.effectAudioIn(effectAudioIn),
.search(search),
.record(record),
.effect(effect),
.busySRAM(busySRAM),
.busAudioWrite(busAudioWrite),
.addressOut(addressOut),
.audioOutput(audioOutput),
.select(select),
.write(write),
.read(read)
    );
// Clock generation
initial clk = 0;
always #0.5 clk = ~clk;

// Task to simulate busySRAM behavior
task automatic simulate_sram_busy(int cycles);
    for (int i = 0; i < cycles; i++) begin
       busySRAM = 1;
@(posedge clk);
    end
    busySRAM = 0;
endtask

 initial begin
 $dumpfile("team_06_readWrite.vcd");
 $dumpvars(0, team_06_readWrite_tb);

//RESET
rst = 1;
record = 0;
search = 1;
busAudioRead = 32'h12345678; // Invalid state
effect = 0;
busySRAM = 0; // Right?
offset = 100; // Some constant
effectAudioIn = 0; 
@(posedge clk);
rst = 0;
@(posedge clk);

//WRITE 4 BYTES 
effectAudioIn = 8'hA1;
effect = 1;
for (int i = 0; i < 4; i++) begin
    simulate_sram_busy(1); // simulate SRAM busy for 1 cycle
    @(posedge clk);
end
record = 0;

// To see if we read back with clean data
offset = 0;
search = 1;
simulate_sram_busy(1); // simulate a read delay
busAudioRead = {8'hDE, 8'hAD, 8'hBE, 8'hEF}; // Fake SRAM word
@(posedge clk);
search = 0;

// CHANGE EFFECT WHILE READING (GOOD DATA BECOMES INVALID) 
effect = 0; // Flip effect, resets goodData
@(posedge clk);
effect = 1;

// FILL SRAM AGAIN AFTER EFFECT TO REGAIN GOOD DATA
record = 1;
for (int i = 0; i < 8; i++) begin
    effectAudioIn = effectAudioIn + 1;
    simulate_sram_busy(1);
    @(posedge clk);
end
record = 0;

// MULTIPLE OFFSETS
offset = 0;
search = 1; 
simulate_sram_busy(1); 
busAudioRead = 32'h44332211;
 @(posedge clk);
offset = 1;
search = 1; 
simulate_sram_busy(1);
busAudioRead = 32'h88776655;
 @(posedge clk);
offset = 2;
rst = 1;
search = 1; 
simulate_sram_busy(1); 
busAudioRead = 32'hCCCCBBAA;
 @(posedge clk);

// ENSURE NO WRITE/READ DURING busySRAM
busySRAM = 1;
record = 1;
effectAudioIn = 8'h55;
@(posedge clk); // nothing should write during this
busySRAM = 0;
record = 0;

#5;
$finish;
    end

endmodule
