`default_nettype none
module team_06_echo_effect (
  input logic clk, rst,
  input logic [7:0] audio_in,
  input logic echo_enable,
  input logic [7:0] past_output,
  output logic [12:0] offset,
  output logic search,
  output logic [7:0] echo_out,
  output logic [7:0] save_audio
);

//ECHO = (current_output  + c*past_output)/(1 + C) 
logic [7:0] current_out;

assign save_audio = audio_in;

always_ff @(posedge clk or posedge rst) begin
  if(rst)begin
    echo_out <= 0; 
  end else begin
    echo_out <= current_out;
  end
end

assign offset = 13'd8000;

always_comb begin
  if(echo_enable == 1)begin
    search = 1;
    current_out = (audio_in + past_output) >> 1;
  end else begin
    current_out = audio_in;
    search = 0;
  end
end

endmodule

