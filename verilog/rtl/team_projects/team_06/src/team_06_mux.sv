module team_06_mux(
    input logic selector [1:0], //2-bit selector for choosing audio effect
    input logic echo_out[7:0], //echo effect output
    input logic hard_out[7:0], //hard clipping output
    input logic soft_out[7:0], //soft clipping output
    input logic dry_audio[7:0], //no effect 
    output logic final_audio[7:0] //final ouput after selection from mux 
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