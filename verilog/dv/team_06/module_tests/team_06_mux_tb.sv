/*This is the testbench module
for our multiplexer moduel: which
toggles through audio effects.

The test cases for done below are as follows:
The output of the multiplexer when "selector"
is 00, 01, 10, or 11.
*/
`timescale 1ms/10ps
module team_06_mux_tb;

/* Signals to refer to the 
instantiated ports from the mux module
*/
logic [7:0] dry_audio;
logic [7:0] final_audio;
logic [1:0] selector;
logic [7:0] echo_output;
logic [7:0] soft_out;
logic [7:0] reverb_out;




// Instantiation of the echo module
team_06_mux sahur (
.selector(selector),
.echo_out(echo_output),
.reverb_out(reverb_out),
.soft_out(soft_out),
.dry_audio(dry_audio),
.final_audio(final_audio)
);



initial begin
   // Waveform Dumping
   $dumpfile("team_06_mux.vcd");
   $dumpvars(0, team_06_mux_tb);



echo_output = 0;
soft_out = 0;
dry_audio = 1;
selector = 0;
reverb_out = 0;


#1
echo_output = 1;
soft_out = 0;
dry_audio =0;
selector = 1;
reverb_out = 0;

#1
echo_output = 0;
soft_out = 0;
dry_audio = 0;
selector = 2;
reverb_out = 1;

#1
echo_output = 0;
soft_out = 1;
dry_audio =0;
selector = 3;
reverb_out = 0;
#2;
$finish;








end
endmodule