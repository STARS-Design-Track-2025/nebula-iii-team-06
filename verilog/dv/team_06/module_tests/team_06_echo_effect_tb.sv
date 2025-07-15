`timescale 1ms/10ps
module team_06_echo_effect_tb;

logic clk;
logic rst;
logic [7:0] audio_in;
logic echo_enable;
logic [7:0] past_output;
logic [12:0] offset;
logic search;
logic [7:0] echo_out;
logic [7:0] save_audio;


// Instantiation of the echo module
team_06_echo_effect sahur (
.clk(clk),
.rst(rst),
.audio_in(audio_in),
.echo_enable(echo_enable),
.past_output(past_output),
.offset(offset),
.search(search),
.echo_out(echo_out),
.save_audio(save_audio)
);

initial clk = 0;
always #0.5 clk = ~clk;

initial begin
    // Waveform Dumping
    $dumpfile("waves/team_06_echo_effect.vcd");
    $dumpvars(0, team_06_echo_effect_tb);

rst = 0;
echo_enable = 1;
audio_in = 1;
past_output = 1;

#5
@(posedge clk);
rst = 1;
echo_enable = 0;
audio_in = 0;
past_output = 0;
@(posedge clk);
#5
rst = 0;
@(posedge clk);
#2;
$finish;




end
endmodule
