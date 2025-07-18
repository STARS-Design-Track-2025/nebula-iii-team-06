/*This is the testbench module
for our Echo Effect module: creating the echo sound effect.

 */
`timescale 1ms/10ps
module team_06_echo_effect_tb;

logic clk;
logic rst;
logic [7:0] audio_in;
logic search_enable;
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
.search_enable(search_enable),
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
    $dumpfile("team_06_echo_effect.vcd");
    $dumpvars(0, team_06_echo_effect_tb);
// When we enable the search for the past input
// and reset is pulled low while we have audio signal 
rst = 0;
search_enable = 1;
audio_in = 68;
past_output = 50;
@(posedge clk);
#5

// When we enable the search for the past input
// and reset is pulled high 
rst = 1;
search_enable = 1;
audio_in = 78;
past_output = 89;
@(posedge clk);
#5
// When we enable the search for the past input
// and reset is pulled high but with different audio values
rst = 1;
search_enable = 1;
audio_in = 65;
past_output = 56;
#5
// When we disable the search for the past input
// and reset is pulled high 
rst = 0;
search_enable = 0;
audio_in = 75;
past_output = 0;
@(posedge clk);
#5

// This test case is to see what happens when we have two maximum values
rst = 0;
search_enable = 1;
audio_in = 255;
past_output = 255;
#5

// This test case is to see what happens when we have even and odd values. You see that we do floor rounding
rst = 0;
search_enable = 1;
audio_in = 254;
past_output = 255;
#5

rst = 1;
search_enable = 1;
audio_in = 12;
past_output = 255;
#5

#2;
$finish;

end
endmodule