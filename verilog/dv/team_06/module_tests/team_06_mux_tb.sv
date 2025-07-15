`timescale 1ms/10ps
module team_06_echo_effect_tb;


logic [7:0] dry_audio;
logic [7:0] final_audio;
logic [1:0] selector;
logic [7:0] echo_out;
logic [7:0] soft_out;




// Instantiation of the echo module
team_06_mux sahur (
.selector(selector),
.echo_out(echo_out),
.soft_out(soft_out),
.dry_audio(dry_audio),
.final_audio(final_audio)
);



initial begin
   // Waveform Dumping
   $dumpfile("team_06_mux.vcd");
   $dumpvars(0, team_06_mux_tb);



echo_out = 0;
soft_out = 0;
dry_audio = 0;
dry_audio = 0;


#1
echo_out = 1;
soft_out = 1;
dry_audio =1;
dry_audio = 1;

#1
echo_out = 0;
soft_out = 0;
dry_audio = 0;
dry_audio = 0;

#1
echo_out = 1;
soft_out = 1;
dry_audio =1;
dry_audio = 1;

#1
echo_out = 0;
soft_out = 0;
dry_audio = 0;
dry_audio = 0;
#2;
$finish;








end
endmodule
