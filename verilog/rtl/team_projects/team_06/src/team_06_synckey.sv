module team_06_synckey (
   input logic [3:0] pbs,    // 4 pushbuttons
   input logic clk,          // 25 mHz clock
   input logic rst,          // Active-high reset
   input logic [1:0]vol,      // volume input for the volume knob
   output logic [3:0] volume, // volume output logic for the volume shifter module
   output logic ptt,          // push-to-talk mode enabled
   output logic noise_gate,   // noise gate mode enabled
   output logic effect,       // effects enabled
   output logic mute          // mute button enabled
);


   logic [3:0] currPBS;  // synchronization signals for push-buttons
   logic [1:0] prevV, currV;         // synchronization signals for volume knob
   logic [3:0] prev_syncPBS; // previous synchronized values for push-buttons for the edge detector
   logic [3:0] next_in;       // "next" signal logic for edge detetctor
   logic CW, ACW;          // clockwise and anti-clockwise logic
   logic [3:0] new_volume; // temporary variable for the volmue output
   logic mute_en;      // temporary variable for the mute button
   logic ng_en;        // temporary variable for the noise gate
   logic ptt_en;       // temporary variable for the push-to-talk
   logic effect_en;    // temporary variable for teh effect output
   logic [3:0][15:0] debounce_counters, next_counters; // temporary signals for the counter
   logic [3:0] debouncedPBS; // temporary signals for the debouncer


   typedef enum logic [1:0] { 
       ENC1 = 2'b00,
       ENC2 = 2'b01,
       ENC3 = 2'b11,
       ENC4 = 2'b10
   } ENC_t;

   logic[1:0] current_ENC, previous_ENC; // variables we need for comparing the encoded combinations


   // 2-stage synchronizer for pushbuttons and volume knob
   always_ff @(posedge clk, posedge rst) begin
       if (rst) begin
           currPBS <= 4'b0;
           prevV <= 2'b0;
           currV <= 2'b0;
       end else begin
           currPBS <= pbs;
           currV <= vol;
           prevV <= currV;
       end
   end


   always_comb begin
       next_counters = debounce_counters;

       for (int i = 0; i < 4; i++) begin
           if (pbs[i] == debouncedPBS[i]) begin
               next_counters[i] = 16'd0;
           end else begin
               next_counters[i] = debounce_counters[i] + 1;
               if (debounce_counters[i] >= 16'd5000) begin
                   next_counters[i] = 16'd0;
               end
           end
       end
   end


   always_ff @(posedge clk or posedge rst) begin
       if (rst) begin
           debounce_counters <= 64'd0;
           debouncedPBS <= 0;
           end else begin
           debounce_counters <= next_counters;
           debouncedPBS <= currPBS;
          
       end
   end


   // Memory for storing previous synchronized-debounced signal
   // for the push buttons, so we can compare the signals
   // to detect edge
   always_ff @(posedge clk, posedge rst) begin
       if (rst) begin
           prev_syncPBS <= 4'b0;
       end else begin
           prev_syncPBS <= debouncedPBS;
       end
   end


   assign next_in = currPBS;
   // Edge detector logic for the push buttons: mute, push-to-talk, effects, and mute
   always_comb begin
       mute_en = mute;
       effect_en = effect;
       ptt_en = ptt;
       ng_en = noise_gate;

       if (next_in[1] && ~prev_syncPBS[1]) begin // rising edge for mute
           mute_en = ~mute_en;
       end
       if (next_in[2] && ~prev_syncPBS[2]) begin // rising edge for effects
           effect_en = ~effect;
       end
       if (next_in[3] && ~prev_syncPBS[3]) begin// rising edge noise gate
           ng_en = ~ng_en;
       end
       if (next_in[0]) begin // rising edge for the push-to-talk button
           ptt_en = 1;
       end else begin
        ptt_en = 0;
       end
   end


   // flip-flop to update the pbs enable state store the output of the push buttons
   always_ff @(posedge clk, posedge rst) begin
       if (rst) begin
           mute <= 0;
           effect <= 0;
           noise_gate <= 0;
           ptt <= 0;
       end else begin
           mute <= mute_en;
           effect <= effect_en;
           noise_gate <= ng_en;
           ptt <= ptt_en;
       end
   end


   assign current_ENC = currV;
   assign previous_ENC = prevV;


   // Encoder, monitoring the direction of the changing of each of these bits
   always_comb begin
       case({previous_ENC, current_ENC})
           {ENC1, ENC2}, // 00 → 01
           {ENC2, ENC3}, // 01 → 11
           {ENC3, ENC4}, // 11 → 10
           {ENC4, ENC1}: // 10 → 00
               begin
                   CW = 1;
                   ACW = 0;
               end
           {ENC1, ENC4}, // 00 → 10
           {ENC4, ENC3}, // 10 → 11
           {ENC3, ENC2}, // 11 → 01
           {ENC2, ENC1}: // 01 → 00
               begin  
                                 ACW = 1;
                   CW = 0;
               end
           default: 
               begin
                   CW = 0;
                   ACW = 0;
               end
       endcase
   end


   // Combinational logic for the increasing or reducing the volume
   always_comb begin
       new_volume = volume;
       if (CW && (new_volume < 4'd15)) begin
           new_volume = new_volume + 1;
       end
       else if(ACW && (new_volume > 4'd0)) begin
           new_volume = new_volume - 1;
       end
   end


   // flip-flop for updating and storing the volume output of the module
   always_ff @(posedge clk, posedge rst) begin
       if (rst) begin
           volume <= 4'd0;
       end
       else begin
           volume <= new_volume;
       end
   end


endmodule