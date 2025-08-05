module team_06_newDisplay (
   input logic clk,
   input logic rst,
   input logic talkieState, // Is the walkie talkie in listen or talk state?
   input logic [2:0] current_effect, // What audio effect is the walkie talkie on?
   input logic [3:0] volume, // From 0 (min) to 15 (max)
   input logic enable_volume, // Whether or not we are muted
   output logic [127:0] row_1, 
   output logic [127:0] row_2
);

    logic [2:0] desiredLCDstate;
    // This is a modification of the typedef from FSM to include listen and an empty state
    typedef enum logic [2:0] {
       NORMAL = 3'b000,
       ECHO = 3'b001,
       TREMOLO = 3'b010,
       REVERB = 3'b011,
       SOFT = 3'b100,
       NONE = 3'b110,
       LISTEN = 3'b111
   } current_effect_t;

   typedef enum logic [7:0] {
        A = 8'h41, B = 8'h42, C = 8'h43, D = 8'h44, E = 8'h45,
        F = 8'h46, G = 8'h47, H = 8'h48, I = 8'h49, J = 8'h4A,
        K = 8'h4B, L = 8'h4C, M = 8'h4D, N = 8'h4E, O = 8'h4F,
        P = 8'h50, Q = 8'h51, R = 8'h52, S = 8'h53, T = 8'h54,
        U = 8'h55, V = 8'h56, W = 8'h57, X = 8'h58, Y = 8'h59,
        Z = 8'h5A, SPACE = 8'h20, FILL = 8'hFF
   } letters_t;

    typedef enum logic {
       LIST = 1'b0,
       TALK = 1'b1
   } state_t;

    always_comb begin
        desiredLCDstate = (talkieState == LIST) ? LISTEN : current_effect; // We need to convert our talkiestate and effect into just one state 

        case (desiredLCDstate) 
            NORMAL: row_1 = {N, O, SPACE, E, F, F, E, C, T, {7{SPACE}}}; 
            ECHO: row_1 = {E, C, H, O, {12{SPACE}}};
            TREMOLO: row_1 = {T, R, E, M, O, L, O, {9{SPACE}}};
            REVERB: row_1 = {R, E, V, E, R, B, {10{SPACE}}};
            SOFT: row_1 = {R, E, V, E, R, B, {10{SPACE}}};
            LISTEN: row_1 = {L, I, S, T, E, N, {10{SPACE}}};
            default: row_1 = {{16{FILL}}};
        endcase
            if (enable_volume) begin
                for(int i = 0; i <= 15; i++) begin
                    row_2[(128-8*i)-:8] = ({28'b0, volume} >= i) ? FILL : SPACE;
                end 
            end else begin
                row_2 =  {{16{SPACE}}};
            end
    end


endmodule