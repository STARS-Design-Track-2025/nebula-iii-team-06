`default_nettype none
module team_06_echo_effect (
  input logic clk, rst,
  input logic audio_in[7:0],
  input logic echo_enable,
  input logic past_output[7:0],
  output logic offset[12:0],
  output logic search,
  output logic echo_out[7:0],
  output logic save_audio[7:0]
);

//ECHO = (current_output  + c*past_output)/(1 + C) 
logic current_out[7:0];

assign save_audio = audio_in;

always_ff @(posedge clk or posedge rst) begin
  if(rst)begin
    echo_out = 0; 
  end else begin
    echo_out <= current_out;
  end
end

assign offset = 13'd8000;

always_comb begin
  if(echo_enable = 1)begin
    search = 1;
    current_out = (audio_in + past_output) >> 1;
  end else begin
    current_out = audio_in;
  end
end

endmodule

