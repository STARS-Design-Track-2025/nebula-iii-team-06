module team_06_echo_and_reverb (
  input logic clk, rst, 
  input logic [7:0] audio_in, //original audio entering echo module 
  input logic echo_en, 
  input logic reverb_en,
  input logic goodData,
  input logic [7:0] past_output, //past_output coming from memory
  output logic [7:0] echo_reverb_out, //the echo output
  output logic [7:0] save_audio //what is being sent to the SRAM
);


logic [7:0] current_out; //temporary echo output 
logic [7:0] save_audio_n; 

always_ff @(posedge clk or posedge rst) begin 
    if(rst)begin
        echo_reverb_out <= 8'd128; // By defualt, must be 128 as that is considered zero in our system
        save_audio <= 8'd128;
    end else begin
        echo_reverb_out <= current_out; 
        save_audio <= save_audio_n;
    end
end

always_comb begin
  if ((echo_en && !reverb_en) || !goodData) begin // if echo, we save our input
    save_audio_n = audio_in;
  end else if (!echo_en && reverb_en) begin // if reverb, we save our output
    save_audio_n = current_out;
  end else begin
    save_audio_n = 8'hAA; // If neither, we default to AA as a flag (we won't actually save)
  end
end

always_comb begin
    if(echo_en ^ reverb_en && goodData) begin // if just echo or just reverb is enabled
        current_out = (audio_in + past_output)/2; //the echo formula: we are using C as 1, 
    end else if (echo_en ^ reverb_en) begin
        current_out = audio_in;
    end else begin
        current_out = 128; 
    end
end
endmodule
