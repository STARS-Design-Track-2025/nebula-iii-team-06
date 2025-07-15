`timescale 1ms/10ps
module team_06_soft_clipping_tb;


logic [7:0] audio_in;
logic [7:0] soft_out;

// Instantiation of the soft clipping
team_06_soft_clipping sahur (
.audio_in(audio_in),
.soft_out(soft_out)
);


initial begin
   // Waveform Dumping
   $dumpfile("team_06_soft_clipping.vcd");
   $dumpvars(0, team_06_soft_clipping_tb);



audio_in = 1;



#5

audio_in = 0;

#5

audio_in = 1;

#2;
$finish;


end
endmodule
