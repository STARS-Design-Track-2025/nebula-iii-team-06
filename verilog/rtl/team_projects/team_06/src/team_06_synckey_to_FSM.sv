module team_06_synckey_to_FSM(
   input  logic clk,
   input  logic rst,
   input  logic [3:0] pbs,
   input  logic [1:0] vol,
   input  logic [7:0] mic_aud,
   input  logic [7:0] spk_aud,
   output logic [1:0] state,
   output logic vol_en,
   output logic [2:0] current_effect,
   output logic mute_tog,
   output logic noise_gate_tog
);

   logic ptt;
   logic mute;
   logic effect;
   logic noise_gate;
   logic [2:0]currnt_effect;
   logic mute_toggle;
   logic noise_gate_toggle;

   team_06_synckey TEO (
       .pbs(pbs),
       .clk(clk),
       .rst(rst),
       .vol(vol),
       .ptt(ptt),
       .noise_gate(noise_gate),
       .effect(effect),
       .mute(mute)
   );

   team_06_FSM JKB (
       .clk(clk),
       .rst(rst),
       .mic_aud(mic_aud),
       .spk_aud(spk_aud),
       .ng_en(noise_gate),
       .ptt_en(ptt),
       .effect(effect),
       .mute(mute),
       .state(state),
       .vol_en(vol_en),
       .current_effect(current_effect),
       .mute_tog(mute_tog),
       .noise_gate_tog(noise_gate_tog)
   );

endmodule
