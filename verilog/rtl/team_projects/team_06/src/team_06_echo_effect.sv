`default_nettype none
module team_06_echo_effect (
  input logic clk, rst,
  input logic [7:0] audio_in, //original audio entering echo module 
  input logic search_enable, //this triggers  memory search for the past output to make the echo effect
  input logic [7:0] past_output, //past_output coming from memory
  output logic [12:0] offset, //amount of spaces back we go to get the past output
  output logic search, //searching for past output from memory
  output logic [7:0] echo_out, //the echo output
  output logic [7:0] save_audio //what is being sent to the SRAM
);

//ECHO = (audio_in  + c*past_input)/(1 + C) 
logic [7:0] current_out; //temporary echo output 
logic search_n;

assign save_audio = audio_in;//what is being sent to SRAM 
always_ff @(posedge clk or posedge rst) begin 
  if(rst)begin
    echo_out <= 0; 
    search <= 0; 
  end else begin
    echo_out <= current_out; 
    search <= search_n;
  end
end

logic [8:0] dividerin, dividerpast, dividercurrent;
always_comb begin
  offset = 13'd8000; //giving the offset a value
  dividerin = {audio_in, 1'b0};
  dividerpast = {past_output, 1'b0};
end 
always_comb begin
  if(search_enable == 1)begin
    search_n = 1; //when search_enable is on, we want to start searching the readwrite for past output from SRAM
    dividercurrent = (dividerin + dividerpast)/2; //the echo formula: we are using C as 1, 
    current_out = dividercurrent[8:1];
  end else begin
    dividercurrent = 0;
    current_out = audio_in; 
    search_n = 0;
  end
end

endmodule

