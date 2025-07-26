/*This is the testbench module
for our Echo Effect module: creating the echo sound effect.

 */
`timescale 1ms/10ps
module team_06_echo_and_reverb_tb;

logic clk;
logic rst;
logic [7:0] audio_in;
logic echo_en;
logic reverb_en;
logic [7:0] past_output;
logic [12:0] offset;
//logic search;
logic [7:0] echo_reverb_out;
logic [7:0] save_audio;

// Instantiation of the echo module
team_06_echo_and_reverb sahur (
.clk(clk),
.rst(rst),
.audio_in(audio_in),
.echo_en(echo_en),
.reverb_en(reverb_en),
.past_output(past_output),
.offset(offset),
.echo_reverb_out(echo_reverb_out),
.save_audio(save_audio)
);


initial clk = 0;
always #0.5 clk = ~clk;

initial begin
    // Waveform Dumping
    $dumpfile("team_06_echo_and_reverb.vcd");
    $dumpvars(0, team_06_echo_and_reverb_tb);
// When we enable the search for the past input
// and reset is pulled low while we have audio signal 
rst = 0;
echo_en = 1;
reverb_en = 0;
audio_in = 68;
past_output = 50;
@(posedge clk);
#5

// When we enable the search for the past input
// and reset is pulled high 
rst = 1;
echo_en = 1;
audio_in = 78;
past_output = 89;
@(posedge clk);
#5
// When we enable the search for the past input
// and reset is pulled high but with different audio values
rst = 1;
echo_en = 1;
audio_in = 65;
past_output = 56;
#5
// When we disable the search for the past input
// and reset is pulled high 
rst = 0;
echo_en = 0;
audio_in = 75;
past_output = 0;
@(posedge clk);
#5

// This test case is to see what happens when we have two maximum values
rst = 0;
echo_en = 1;
audio_in = 255;
past_output = 255;
#5

// This test case is to see what happens when we have even and odd values. You see that we do floor rounding
rst = 0;
echo_en = 1;
audio_in = 254;
past_output = 255;
#5

// This test case is to see what happens if we switch to reverb_en
rst = 0;
echo_en = 0;
reverb_en = 1;
audio_in = 254;
past_output = 255;
#5

// This test case demonstrates that when both search and reverb are on, we do not go to memory
rst = 0;
echo_en = 1;
reverb_en = 1;
audio_in = 254;
past_output = 255;
#5

rst = 1;
echo_en = 1;
audio_in = 12;
past_output = 255;
#5

#2;
$finish;

end
endmodule
