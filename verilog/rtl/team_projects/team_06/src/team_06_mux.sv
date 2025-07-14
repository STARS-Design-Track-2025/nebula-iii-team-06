module team_06_mux(
    input logic [1:0] selector, //2-bit selector for choosing audio effect
    input logic [7:0] echo_out, //echo effect output
    input logic [7:0] hard_out, //hard clipping output
    input logic [7:0] soft_out, //soft clipping output
    input logic [7:0] dry_audio, //no effect 
    output logic [7:0] final_audio //final ouput after selection from mux 
);

//combinational logic to select audio effect based on sel input
always_comb begin 
    case(selector)
    2'b00: final_audio = dry_audio; // no effect
    2'b01: final_audio = echo_out; // echo effect
    2'b10: final_audio = hard_out; // hard clipping effect
    2'b11: final_audio = soft_out; //soft clipping effect
    default: final_audio = dry_audio; //fallback to dry
    endcase
end


endmodule