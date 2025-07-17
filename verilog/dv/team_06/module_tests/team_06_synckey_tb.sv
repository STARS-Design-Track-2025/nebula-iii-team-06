`timescale 1ms/10ps
module team_06_synckey_tb;

logic [3:0] pbs;
logic clk;
logic rst;
logic [1:0] vol;
logic [3:0] volume;
logic ptt;
logic noise_gate;
logic effect;
logic mute;


//Instantiation of the synckey module 
team_06_synckey trung_trung_sahur (

    .pbs(pbs),
    .clk(clk),
    .rst(rst),
    .vol(vol),
    .volume(volume),
    .ptt(ptt),
    .noise_gate(noise_gate),
    .effect(effect),
    .mute(mute)
);

initial clk = 0;
always #0.5 clk = ~clk;

initial begin
    //waveform dumping 
    $dumpfile ("team_06_synckey.vcd");
    $dumpvars (0, team_06_synckey_tb);


    rst = 1;
    pbs = 0;
    vol = 1;
    #0.5
    @(posedge clk);
    rst = 1;
    pbs = 0;
    vol = 0;

    #5
    @(posedge clk);
    rst = 0;
    pbs = 1;
    vol = 0;

    @(posedge clk);
    #5
    rst = 0;
    pbs = 2;
    vol = 0;

    @(posedge clk);
    #5
    rst = 0;
    pbs = 3;
    vol = 1;

 @(posedge clk);
    #5
    rst = 0;
    pbs = 4;
    vol = 1;

    @(posedge clk);
    #5
    rst = 0;
    pbs = 4;
    vol = 1;

 @(posedge clk);
    #5
    rst = 0;
    pbs = 5;
    vol = 1;

@(posedge clk);
    #5
    rst = 1;
    pbs = 8;
    vol = 1;

@(posedge clk);
    #5
    rst = 0;
    pbs = 8;
    vol = 1;

    #10
    rst = 0;
    @(posedge clk);
    #2

$finish;
end

endmodule

