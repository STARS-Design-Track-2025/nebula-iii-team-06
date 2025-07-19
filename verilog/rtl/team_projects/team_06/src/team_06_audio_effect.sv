module team_06_audio_effect(
    input logic clk, rst,
    input logic [7:0] audio_in,
    input logic [2:0] sel,
    output logic [7:0] audio_out
);
/*
    //tremelo port
    logic clkdiv;
    logic tremelo_en;
    logic [7:0] tremelo_out;
    team_06_tremelo tremelo(.audio_in(audio_in), .clkdiv(clkdiv), .rst(rst), .tremelo_en(tremelo_en), .audio_out(tremelo_out));

    //soft clipping ports
    logic soft_clip_en;
    logic [7:0] soft_out;
    team_06_soft_clipping soft_clip(.audio_in(audio_in), .soft_clip_en(soft_clip_en), .soft_out(soft_out));










    logic no_filter; //000
    //logic tremelo_en; // 001
    logic reverb_en; // 010
    logic echo_en;//011
    //logic soft_clipping_en;//100

    always_comb begin
        // Default values
        no_filter = 0;
        tremelo_en = 0;
        reverb_en = 0;
        echo_en = 0;
        soft_clip_en = 0;

        case (sel)
            3'b000: no_filter = 1;
            3'b001: tremelo_en = 1;
            3'b010: reverb_en = 1;
            3'b011: echo_en = 1;
            3'b100: soft_clip_en = 1;
            default: no_filter = 1; 
        endcase
    end
*/
endmodule

