/*This is the testbench module
for our Soft Clipping moduel: gently, 
using a formula, excludes sound signal
 peaks beyond certain thresholds.

 The test cases for done below are as follows:
 1) When the audio input is lower than or equal to the floor limit, "soft_start".
 2) When the audio input is within the threshold limits.
 3) When the audio input is equal to the threshold limits.
 4) When the audio input is greater than the ceiling limit, "soft_max_thresh".
*/
`timescale 1ms/10ps
module team_06_soft_clipping_tb;


logic [7:0] audio_in;
logic [7:0] soft_out;
logic soft_clip_en;

// Instantiation of the soft clipping
team_06_soft_clipping sahur (
.audio_in(audio_in),
.soft_out(soft_out),
.soft_clip_en(soft_clip_en)
);


initial begin
   // Waveform Dumping
   $dumpfile("team_06_soft_clipping.vcd");
   $dumpvars(0, team_06_soft_clipping_tb);

soft_clip_en = 1;

audio_in = 0;

#5
audio_in = 20;

#5
audio_in = 60;

#5
audio_in = 90;

#5
audio_in = 110;

#5
audio_in = 180;

#5

audio_in = 200;

#5

audio_in = 220;

#5

audio_in = 255;

#5

soft_clip_en = 0;

#5

soft_clip_en = 1;

#2;
$finish;


end
endmodule
