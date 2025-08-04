module team_06_FSM (
  input logic clk,
  input logic rst,
  input logic [7:0] mic_aud, // Live audio being transmitted
  input logic [7:0] spk_aud, // Live audio being listened to
  input logic ng_en, // Noise gate enabale
  input logic ptt_en, //Push-to-talk enable
  input logic effect, // Effect being used
  input logic mute, // Mute enabled
  output logic state, // State we are currently in
  output logic vol_en, // Whether volume is enabled or not
  output logic [2:0] current_effect, // output logic for the current effect we're on
  output logic mute_tog, // This is what actually mutes the volume shifter
  output logic effect_en // This is what actually mutes the audio effect module
);


  typedef enum logic {
      LIST = 1'b0,
      TALK = 1'b1
  } state_t;


  typedef enum logic  {
      MUTE = 1,
      MUTE_OFF = 0
  } mute_t;


  typedef enum logic  {
      NOISE = 1,
      NOISE_OFF = 0
  } noise_t;


  typedef enum logic [2:0] {
      NORMAL = 3'b000,
      ECHO = 3'b001,
      TREMOLO = 3'b010,
      REVERB = 3'b011,
      SOFT = 3'b100
  } current_effect_t;


  logic next_state;   // Variables for controlling the state case-satatements
  logic [7:0] threshold;                  // Threshold for which the mic_audio should pass in noise gate
  logic check, check_n;                // check logic for if we're above the threshold or not
  logic eff_en_temp;          // effect enable temporary variable
  logic spk_active;           // logic for if speaker is active
  logic [2:0] next_eff;
  logic effect_button_prev, effect_button_prev2;
  logic effect_button_rising;
  logic noise_gate_tog; // Whether or not noise gates has changed states
  logic [19:0] time_count, time_count2;


  assign threshold = 8'd64; // threshold is 64 decibels

  // Synchroning the state with the clock
  always_ff @(posedge clk, posedge rst) begin
      if (rst) begin
          state <= LIST;
          check = 0;
      end else begin
          state <= next_state;
          check = check_n;
      end
  end

  // Combinational: next state logic
    always_comb begin
        next_state = state;
        check_n = check;
        if (mic_aud >= 128) begin
            check_n = (mic_aud >= threshold + 128);
        end else begin
            check_n  = (mic_aud <= 128 - threshold);
        end
        spk_active = (spk_aud != 128);    // speaker is active logic. Critical that the value is 128 because that is the midpoint between 0 and 255

        /* Case statements for switching between states
        based on the current state and certain conditions (MEALY)*/
        case (state)
        LIST: begin
            if (spk_active) begin
                next_state = LIST;
            end else if ((noise_gate_tog && !ptt_en && check_n) || ptt_en) begin
                next_state = TALK;
            end
            end
        TALK: begin
            if ((!ptt_en && !noise_gate_tog) || (noise_gate_tog && !ptt_en && !check_n)) begin
                next_state = LIST;
            end else if (spk_active) begin
                next_state = LIST;
            end else if ((ptt_en) || (noise_gate_tog && !ptt_en && check_n)) begin
                next_state = TALK;
            end
            end
        default: next_state = LIST;
        endcase
    end

   always_ff @(posedge clk, posedge rst) begin
       if (rst) begin
           time_count <= 0;
       end else begin
           time_count <= time_count2;
       end
   end

    always_comb begin
       time_count2 = time_count;

        case (state)
        LIST: begin
           time_count2 = 0;
           if (ptt_en) begin
               time_count2 = 0;
           end
        end
        TALK: begin
           time_count2 = time_count + 1;
           if (ptt_en) begin
               time_count2 = 0;
           end
           if (ng_en && (mic_aud != 128)) begin
               for (int time_count2 = 1; time_count2 < 1048575; time_count2++) begin
                       time_count2++;
               end
           end
               if ((time_count == 1048575) && ng_en && !ptt_en && !check) begin
                   time_count2 = 0;                    
               end
                else if((time_count == 1048575) && ng_en && !ptt_en && check) begin
                    time_count2 = 0;
           end
        end
        default: begin
           time_count2 = 0;
        end
        endcase
    end


    // Combinational logic for the output of the module
    always_comb begin
        vol_en = 0;
        effect_en = 0;
        case (state)
            LIST: begin
                if (!mute && !rst) begin
                    vol_en = 1;
                end
                else if (ptt_en) begin
                    vol_en = 0;
                end
            end
            TALK: begin
                vol_en = 0;
                effect_en = 1;
            end
            default: begin
                vol_en = 0;
                end
        endcase
    end

  // Detect rising edge of effect_button
  always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
          effect_button_prev <= 0;
          effect_button_prev2 <= 0;
      end else begin
          effect_button_prev <= effect;
          effect_button_prev2 <= effect_button_prev;
      end
  end

  // Update current_effect on each rising edge
  always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
          current_effect <= NORMAL;
      end else begin
          current_effect <= next_eff;
      end
  end

  always_comb begin
      next_eff = current_effect;
      effect_button_rising = (effect_button_prev && !effect_button_prev2);

      case (current_effect)
      NORMAL: begin
          if (effect_button_rising) begin
              next_eff = ECHO;
          end else begin
              next_eff = NORMAL;
          end
      end
      ECHO: begin
          if (effect_button_rising) begin
              next_eff = TREMOLO;
          end else begin
              next_eff = ECHO;
          end
      end
      TREMOLO: begin
          if (effect_button_rising) begin
              next_eff = REVERB;
          end else begin
              next_eff = TREMOLO;
          end
      end
      REVERB: begin
          if (effect_button_rising) begin
              next_eff = SOFT;
          end else begin
              next_eff = REVERB;
          end
      end
      SOFT: begin
          if (effect_button_rising) begin
              next_eff = NORMAL;
          end else begin
              next_eff = SOFT;
          end
      end
      default: next_eff = NORMAL;
      endcase
  end

  logic mute_prev, mute_prev2;
  logic mute_state, next_mute_state, mute_button_rising;
  always_ff @(posedge clk, posedge rst) begin
      if (rst) begin
          mute_prev <= 0;
          mute_prev2 <= 0;
      end
      else begin
          mute_prev <= mute;
          mute_prev2 <= mute_prev;
      end
  end

  always_ff @(posedge clk, posedge rst) begin
      if (rst) begin
          mute_tog <= MUTE_OFF;
      end
      else begin
          mute_tog <= next_mute_state;
      end
  end

  always_comb begin
      next_mute_state = mute_tog;
      mute_button_rising = (mute_prev & !mute_prev2);
      case(mute_tog)
      MUTE_OFF: begin
          if(mute_button_rising)begin
              next_mute_state = MUTE;
          end else begin
              next_mute_state = MUTE_OFF;
          end
      end
      MUTE: begin
          if(mute_button_rising)begin
              next_mute_state = MUTE_OFF;
          end else begin
              next_mute_state = MUTE;
          end
      end
      default: next_mute_state = MUTE_OFF;
      endcase
  end


  logic noise_prev, noise_prev2;
  logic noise_state, next_noise_state, noise_button_rising;
  always_ff @(posedge clk, posedge rst) begin
      if (rst) begin
          noise_prev <= 0;
          noise_prev2 <= 0;
      end
      else begin
          noise_prev <= ng_en;
          noise_prev2 <= noise_prev;
      end
  end

  always_ff @(posedge clk, posedge rst) begin
      if (rst) begin
          noise_state <= NOISE_OFF;
      end
      else begin
          noise_state <= next_noise_state;
      end
  end

  always_comb begin
      next_noise_state = noise_state;
      noise_gate_tog = noise_state;
      noise_button_rising = (noise_prev & !noise_prev2);


      if (spk_active) begin
       next_noise_state = NOISE_OFF;
      end
      case(noise_state)
      NOISE_OFF: begin
          if(noise_button_rising)begin
              next_noise_state = NOISE;
          end else begin
              next_noise_state = NOISE_OFF;
          end
      end
      NOISE: begin
          if(noise_button_rising)begin
              next_noise_state = NOISE_OFF;
          end else begin
              next_noise_state = NOISE;
          end
      end
      default: next_noise_state = NOISE_OFF;
      endcase
  end
 
endmodule
