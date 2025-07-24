`timescale 1ms/10ps

module team_06_readWrite_tb;

    logic clk;
    logic rst;
    logic [31:0] busAudioRead;
    logic [12:0] offset;
    logic [7:0] effectAudioIn;
    logic search;
    logic record;
    logic [2:0] effect;
    logic busySRAM;
    logic [31:0] busAudioWrite;
    logic [31:0] addressOut;
    logic [7:0] audioOutput;
    logic [3:0] select;
    logic write;
    logic readEdge;

    logic [31:0] wdati;
    logic wack;
    logic [31:0] wadr;
    logic [31:0] wdato;
    logic [3:0] wsel;
    logic wwe;
    logic wstb;
    logic wcyc;


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
.readEdge(readEdge)
    );

wishbone_manager starbucks(
    // User design
    .nRST(!rst),
    .CLK(clk),
    .CPU_DAT_I(busAudioWrite),
    .ADR_I(addressOut),
    .SEL_I(select), // all 1s 
    .WRITE_I(write),
    .READ_I(readEdge),
    .CPU_DAT_O(busAudioRead),
    .BUSY_O(busySRAM),
    // Wishbone interconnect inputs
    .DAT_I(wdati),
    .ACK_I(wack),
    // Wishbone interconnect outputs
    .ADR_O(wadr),
    .DAT_O(wdato),
    .SEL_O(wsel),
    .WE_O(wwe),
    .STB_O(wstb),
    .CYC_O(wcyc)
);

sram_WB_Wrapper tsaocca(
    .wb_rst_i(rst),
    .wb_clk_i(clk),
    .wbs_stb_i(wstb),
    .wbs_cyc_i(wcyc),
    .wbs_we_i(wwe),
    .wbs_sel_i(wsel),
    .wbs_dat_i(wdato),
    .wbs_adr_i(wadr),
    .wbs_ack_o(wack),
    .wbs_dat_o(wdati)
);


// Clock generation
initial clk = 0;
always #0.5 clk = ~clk;


 initial begin
 $dumpfile("team_06_readWrite.vcd");
 $dumpvars(0, team_06_readWrite_tb);

rst = 1;
record = 1;
search = 1;
effect = 0;
offset = 0; 
@(posedge clk);
rst = 0;
effectAudioIn = 8'b11111111; 
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
effectAudioIn = 8'hAB;
repeat (20) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (20) @(posedge clk);
rst = 1;
repeat (2) @(posedge clk);
rst = 0;
effectAudioIn = 8'b10101010; 
record = 0;
offset = 13'b1111111110111;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
effectAudioIn = 8'hCD;
repeat (20) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (2) @(posedge clk);
record = 1;
repeat (2) @(posedge clk);
record = 0;
repeat (20) @(posedge clk);
/*
//RESET
rst = 1;
record = 1;
search = 1;
effect = 0;
offset = 0; // Some constant
effectAudioIn = 0; 
@(posedge clk);
rst = 0;
effectAudioIn = 8'b11111111;
@(posedge clk);
record = 0;
@(posedge clk);
record = 1;
@(posedge clk);
record = 0;
@(posedge clk);
record = 1;
@(posedge clk);
record = 0;
@(posedge clk);
record = 1;
repeat (10) @(posedge clk);
offset = 1;
record = 0;
search = 1;
repeat (15) @(posedge clk);
effectAudioIn = 8'hAB;
record = 1;
search = 1;
repeat (2) @(posedge clk);
effectAudioIn = 8'hCD;
record = 1;
search = 1;
repeat (2) @(posedge clk);
effectAudioIn = 8'hEF;
record = 1;
search = 1;
repeat (2) @(posedge clk);
effectAudioIn = 8'h00;
record = 1;
search = 1;
repeat (8) @(posedge clk);
*/
/*

//readEdge 4 BYTES 
effectAudioIn = 8'hA1;
effect = 1;
record = 0;

// To see if we readEdge back with clean data
offset = 0;
search = 1;
// {8'hDE, 8'hAD, 8'hBE, 8'hEF}; // Fake SRAM word
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
    // Hehe
    @(posedge clk);
end
record = 0;

// MULTIPLE OFFSETS
offset = 0;
search = 1; 
// Hehe 
// Trung wuz here32'h44332211;
 @(posedge clk);
offset = 1;
search = 1; 
// Hehe
// Trung wuz here32'h88776655;
 @(posedge clk);
offset = 2;
rst = 1;
search = 1; 
// Hehe 
// Trung wuz here32'hCCCCBBAA;
 @(posedge clk);

// ENSURE NO WRITE/readEdge DURING busySRAM
record = 1;
effectAudioIn = 8'h55;
@(posedge clk); // nothing should write during this
record = 0;
*/

#5;
$finish;
    end

endmodule
