`timescale 1ms/10ps


module team_06_synckey_to_FSM_tb;


   logic clk, rst;
   logic [3:0] pbs;
   logic [1:0] vol;
   logic [7:0] mic_aud;
   logic [7:0] spk_aud;
   logic [1:0] state;
   logic eff_en, vol_en, mute_toggle, noise_gate_toggle;
   logic [2:0] current_effect;


   // Instantiate combined module
   team_06_synckey_to_FSM fotnait (
       .clk(clk),
       .rst(rst),
       .pbs(pbs),
       .vol(vol),
       .mic_aud(mic_aud),
       .spk_aud(spk_aud),
       .state(state),
       .eff_en(eff_en),
       .vol_en(vol_en),
       .current_effect(current_effect),
       .mute_tog(mute_toggle),
       .noise_gate_tog(noise_gate_toggle)
   );
   // team_06_FSM trung_trung (
   // .clk(clk),
   // .rst(rst),
   // .mic_aud(mic_aud),
   // .spk_aud(spk_aud),
   // .ng_en(ng_en),
   // .ptt_en(ptt_en),
   // .effect(effect),
   // .mute(mute),
   // .state(state),
   // .eff_en(eff_en),
   // .vol_en(vol_en),
   // .current_effect(current_effect),
   // .mute_tog(mute_toggle),
   // .noise_gate_tog(noise_gate_toggle)
   // );






   initial clk = 0;
   always #0.5 clk = ~clk;


   // Stimulus
   initial begin
   //waveform dumping
   $dumpfile ("team_06_synckey_to_FSM.vcd");
   $dumpvars (0, team_06_synckey_to_FSM_tb);
       // Begining stage with everything being set to zero
       rst = 1;
       pbs = 4'b0000;
       vol = 2'b00;
       mic_aud = 8'd0;
       spk_aud = 8'd0;


       #5
       @(posedge clk);
       rst = 0;
       #5
       @(posedge clk);


       // Push-to-talk and Noise Gate buttons off at the same time "0100"
       pbs[3] = 0;     // Noise Gate
       pbs[2] = 1;     // Effect
       pbs[1] = 0;     // Mute
       pbs[0] = 0;     // Push-to-talk
       spk_aud = 78;
       mic_aud = 0;
       #5
       @(posedge clk);
       pbs[2] = 0;     // Effect
       #5
        @(posedge clk);
       // Noise gate active when the push-to-talk is low and we're below the threshold
       pbs[3] = 1;     // Noise Gate
       pbs[2] = 1;     // Effect
       pbs[1] = 0;     // Mute
       pbs[0] = 0;     // Push-to-talk
       mic_aud = 54;
       #1
       @(posedge clk);
       spk_aud = 67;
       #2
       @(posedge clk);
       // Noise gate enabled with our microphone audio being above the threshold
       pbs[3] = 1;  // Noise Gate button with nothing else being pressed "1000"
       pbs[2] = 0;     // Effect
       pbs[1] = 0;     // Mute
       pbs[0] = 0;     // Push-to-talk
       mic_aud = 70;
       spk_aud = 0;
       #5
       @(posedge clk);
       pbs[3] = 0;
       #10;
       @(posedge clk);
       // Noise gate enabled with our microphone audio being below the threshold
       pbs[3] = 1;  // Noise Gate button with nothing else being pressed "1000"
       pbs[2] = 0;     // Effect
       pbs[1] = 0;     // Mute
       pbs[0] = 0;     // Push-to-talk
       mic_aud = 53;
       spk_aud = 0;
       #5;
       @(posedge clk);


       // Noise gate enabled, then over-ridden by the push-to-talk button
       // with our microphone audio being at the threshold when we disable the push-to-talk with an effect enabled
       pbs[3] = 1;     // Noise Gate
       pbs[2] = 1;     // Effect
       pbs[1] = 0;     // Mute
       pbs[0] = 1;     // Push-to-talk
       mic_aud = 63;  
       spk_aud = 0;
       #5
       pbs[0] = 1;
       #5
       @(posedge clk);
       pbs[3] = 1;     // Noise Gate
       pbs[2] = 1;     // Effect
       pbs[1] = 0;     // Mute
       pbs[0] = 0;     // Push-to-talk
       mic_aud = 64;   // At threshold
       spk_aud = 0;
       #5
       @(posedge clk);
       rst = 1;
       pbs[3] = 0;     // Noise Gate
       pbs[2] = 0;     // Effect
       pbs[1] = 0;     // Mute
       pbs[0] = 0;     // Push-to-talk
       spk_aud = 0;
       mic_aud = 0;
       #10;
       @(posedge clk);
       rst = 0;
       // Effect and Mute buttons with nothing else being pressed "0110"
       pbs[3] = 0;     // Noise Gate
       pbs[2] = 1;     // Effect
       pbs[1] = 1;     // Mute
       pbs[0] = 0;     // Push-to-talk
       spk_aud = 0;
       mic_aud = 0; 
       #5
       @(posedge clk);
       pbs[2] = 0;
       pbs[1] = 0;
       #10;
       @(posedge clk);


       rst = 1; // MID-OPERATION reset
       pbs[3] = 1;     // Noise Gate
       pbs[2] = 1;     // Effect
       pbs[1] = 1;     // Mute
       pbs[0] = 1;     // Push-to-talk
       mic_aud = 54;
       spk_aud = 0;
       #5
       @(posedge clk);
       rst = 0;
       #5


       @(posedge clk);
      // Push-to-talk button with nothing else being pressed "0001"
       pbs[3] = 0;     // Noise Gate
       pbs[2] = 0;     // Effect
       pbs[1] = 0;     // Mute
       pbs[0] = 1;     // Push-to-talk
       mic_aud = 54;
       spk_aud = 0;
       #5
       @(posedge clk);
       pbs[0] = 0;
       #10;
       @(posedge clk);


       // All the buttons active at the same time
       pbs[3] = 1;     // Noise Gate
       pbs[2] = 1;     // Effect
       pbs[1] = 1;     // Mute
       pbs[0] = 1;     // Push-to-talk
       mic_aud = 54;
       spk_aud = 0;
       #5
       @(posedge clk);
       // Only Mute active "0010"
       pbs[3] = 0;     // Noise Gate
       pbs[2] = 0;     // Effect
       pbs[1] = 1;     // Mute
       pbs[0] = 0;     // Push-to-talk
       mic_aud = 0;
       spk_aud = 0;
       #5
       @(posedge clk);
       pbs[1] = 0;
       #2;
       $finish;
   end


endmodule




