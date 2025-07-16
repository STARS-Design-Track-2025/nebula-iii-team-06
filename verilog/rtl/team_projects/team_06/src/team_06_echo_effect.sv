`default_nettype none
module team_06_echo_effect (
  input logic clk, rst,
  input logic [7:0] audio_in, //original audio entering echo module 
  input logic echo_enable, //when the echo module is enabled it becomes 1
  input logic [7:0] past_output, //past_output coming from memory
  output logic [12:0] offset, //amount of spaces back we go to get the past output
  output logic search, //searching for past output from memory
  output logic [7:0] echo_out, //the echo output
  output logic [7:0] save_audio //what is being sent to the SRAM
);

//ECHO = (audio_in  + c*past_output)/(1 + C) 
logic [7:0] current_out; //temporary echo output 

assign save_audio = audio_in;//what is being sent to SRAM 
always_ff @(posedge clk or posedge rst) begin 
  if(rst)begin
    echo_out <= 0;  
  end else begin
    echo_out <= current_out; 
  end
end

assign offset = 13'd8000; //giving the offset a value

always_comb begin
  if(echo_enable == 1)begin
    search = 1; //when echo_enable is on, we want to start searching the readwrite for past output from SRAM
    current_out = (audio_in + past_output) >> 1; //the echo formula: we are using C as 1, 
  end else begin
    current_out = audio_in; 
    search = 0;
  end
end

endmodule

