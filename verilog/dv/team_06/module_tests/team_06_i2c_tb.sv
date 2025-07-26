`timescale 1ns/10ps
module team_06_i2c_tb;

logic clk;
logic rst;
logic sda_i;
logic [1:0] effect;
logic [7:0] lcdData;
logic sda_o;
logic scl;
logic oeb;

// Instantiation of the i2c module
team_06_i2c ben_tolu (
.clk(clk),
.rst(rst),
.sda_i(sda_i),
.lcdData(lcdData),
.effect(effect),
.sda_o(sda_o),
.scl(scl),
.oeb(oeb)
);

initial clk = 0;
always #12.5 clk = ~clk;

initial begin
    // Waveform Dumping
    $dumpfile("team_06_i2c.vcd");
    $dumpvars(0, team_06_i2c_tb);

    rst = 1;
    sda_i = 0;
    effect = 0;
    lcdData = 0;

    //effect would be 0,1,2, or 3
    //lcdData would be random 8 bit values
    //sda_i would be 1 or zero depending on whether we are receiveing acknowledge signal or not

    #50
    repeat(1024) @(posedge clk);
    rst = 0;
    sda_i = 1;
    effect = 0;
    lcdData = 0;

    repeat(1024*160) @(posedge clk);
    #50
    rst = 0;
    sda_i = 0;
    effect = 1;
    lcdData = 34;

    repeat(1024*160) @(posedge clk);
    #50
    rst = 0;
    sda_i = 1;
    effect = 2;
    lcdData = 255;

    repeat(1024*160) @(posedge clk);
    #50
    rst = 1;
    sda_i = 1;
    effect = 3;
    lcdData = 34;

    repeat(1024) @(posedge clk);
    #50
    rst = 0;
    sda_i = 1;
    effect = 3;
    lcdData = 128;

    #50
    repeat(1024*160) @(posedge clk);
    #50
    rst = 0;
    #20
    $finish;



end
endmodule
