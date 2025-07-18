module team_06_FSM(
    input logic clk,
    input logic rst,
    input logic [7:0]mic_aud,       // Live audio being transmitted
    input logic [7:0] spk_aud,      // Live audio being listened to
    input logic ng_en,              // Noise gate enabale
    input logic  ptt_en,            //Push-to-talk enable
    input logic effect,             // Effect being used
    input logic mute,               // Mute enabled
    output logic [1:0]state,        // State we are currently in
    output logic eff_en,            // Whether the current effect used will be enabled
    output logic vol_en             // Whether volume is enabled or not
);

typedef enum logic [1:0] { 
    LIST = 2'b00,
    TALK = 2'b01
 } state_t;

logic[1:0] current_state, next_state;   // Variables for controlling the state case-satatements
logic [7:0] threshold;                  // Threshold for which the mic_audio should pass in noise gate
logic check;                // check logic for if we're above the threshold or not
logic eff_en_temp;          // effect enable temporaryvariable
logic spk_active;           // logic for if speaker is active

assign threshold = 8'd64; // threshold is 64 decibels

// Synchroning the state with the clock
always_ff @(posedge clk, posedge rst) begin
    if (rst)
        current_state <= LIST;
    else
        current_state <= next_state;
end

// Combinational: next state logic
always_comb begin
    next_state = current_state;
    check = (mic_aud >= threshold);  // Is the mic signal above threshold?
    spk_active = (spk_aud != 0);    // speaker is active logic

/* Case statements for switching between states
based on the current state and certain conditions (MEALY)*/
    case (current_state)
    LIST: begin
        if (spk_active) begin
            next_state = LIST;
        end else if ((ng_en && !ptt_en && check) || ptt_en) begin
            next_state = TALK;
        end 
        end

    TALK: begin
        if ((!ptt_en && !ng_en) || (ng_en && !ptt_en && !check)) begin
                next_state = LIST;
        end else if (spk_active) begin
                next_state = LIST;
        end
        end

    default: next_state = LIST;
    endcase
end

assign state = current_state;

    // Combinational logic for the output of the module
always_comb begin
    vol_en = 0;
    eff_en = 0;

    case (current_state)
        LIST: begin
            if (!mute)
                vol_en = 1;
            else
                vol_en = 0;
                eff_en = 0;
            end

        TALK: begin
            vol_en = 0;
            if (effect)
                eff_en = 1;
            else
                eff_en = 0;
            end

        default: begin
            vol_en = 0;
            eff_en = 0;
            end
        endcase
    end
endmodule