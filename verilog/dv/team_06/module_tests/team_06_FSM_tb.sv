`timescale 1ms/10ps
module team_06_FSM_tb;


logic clk;
logic rst;
logic [7:0] mic_aud;
logic [7:0] spk_aud;
logic ng_en;
logic ptt_en;
logic effect;
logic mute;
logic [1:0] state;
logic eff_en;
logic vol_en;
logic [2:0]current_effect;
logic mute_tog;
logic noise_gate_tog;




// Instantiation of the FSM module
team_06_FSM trung_trung (
.clk(clk),
.rst(rst),
.mic_aud(mic_aud),
.spk_aud(spk_aud),
.ng_en(ng_en),
.ptt_en(ptt_en),
.effect(effect),
.mute(mute),
.state(state),
.eff_en(eff_en),
.vol_en(vol_en),
.current_effect(current_effect),
.mute_tog(mute_tog),
.noise_gate_tog(noise_gate_tog)
);


initial clk = 0;
always #0.5 clk = ~clk;


initial begin
   // Waveform Dumping
   $dumpfile("team_06_FSM.vcd");
   $dumpvars(0, team_06_FSM_tb);
  


   rst = 1;
   #1
   @(posedge clk);
   rst = 0;
   mic_aud = 0;
   spk_aud = 0;
   ng_en = 0;
   ptt_en = 0;
   effect = 0;
   mute = 0;


   #5
   @(posedge clk);
   rst = 0;
   mic_aud = 60;
   spk_aud = 0;
   ng_en = 0;
   ptt_en = 1;
   effect = 1;
   mute = 0;


   #5
   @(posedge clk);
   rst = 0;
   mic_aud = 65;
   spk_aud = 0;
   ng_en = 0;
   ptt_en = 1;
   effect = 0;
   mute = 0;


   @(posedge clk);
   #5
   rst = 1;
   mic_aud = 0;
   spk_aud = 0;
   ng_en = 0;
   ptt_en = 0;
   effect = 0;
   mute = 0;


   #5
   @(posedge clk);
   rst = 0;
   mic_aud = 65;
   spk_aud = 0;
   ng_en = 0;
   ptt_en = 1;
   effect = 1;
   mute = 0;
  
   @(posedge clk);
   #5
   rst = 0;
   mic_aud = 70;
   spk_aud = 0;
   ng_en = 1;
   ptt_en = 0;
   effect = 0;
   mute = 0;


   @(posedge clk);
   #5
   rst = 0;
   mic_aud = 80;
   spk_aud = 0;
   ng_en = 1;
   ptt_en = 0;
   effect = 1;
   mute = 0;


   @(posedge clk);
   #5
   rst = 0;
   mic_aud = 45;
   spk_aud = 0;
   ng_en = 0;
   ptt_en = 0;
   effect = 0;
   mute = 0;


   @(posedge clk);
   #5
   rst = 0;
   mic_aud = 20;
   spk_aud = 1;
   ng_en = 1;
   ptt_en = 1;
   effect = 0;
   mute = 0;


   @(posedge clk);
   #5
   rst = 0;
   mic_aud = 0;
   spk_aud = 1;
   ng_en = 0;
   ptt_en = 0;
   effect = 0;
   mute = 1;
   #5


   @(posedge clk);
   #5
   rst = 0;
   mic_aud = 0;
   spk_aud = 0;
   ng_en = 0;
   ptt_en = 0;
   effect = 0;
   mute = 0;
   #5


   @(posedge clk);
   #5
   rst = 0;
   mic_aud = 0;
   spk_aud = 0;
   ng_en = 0;
   ptt_en = 0;
   effect = 0;
   mute = 1;
   #5


   @(posedge clk);
   #5
   rst = 1;
   mic_aud = 0;
   spk_aud = 0;
   ng_en = 0;
   ptt_en = 0;
   effect = 0;
   mute = 0;
   #5


   @(posedge clk);
   #5
   rst = 0;
   #2;
   $finish;


// rst = 0;
// echo_enable = 1;
// audio_in = 1;
// past_output = 1;


// #5
// @(posedge clk);
// rst = 1;
// echo_enable = 0;
// audio_in = 0;
// past_output = 0;
// @(posedge clk);
// #5
// rst = 0;
// @(posedge clk);
// #2;


end
endmodule

