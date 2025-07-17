module team_06_reverb (
    input logic clk, rst,
    input logic [7:0] audio_in,
    input logic reverb_enable,
    input logic [7:0] past_output,
    output logic r_search,
    output logic [12:0] r_offset,
    output logic [7:0] save_audio,
    output logic [7:0] reverb_out
);

//ECHO = (audio_in  + c*past_output)/(1 + C) 
logic [7:0] current_out; //temporary echo output 
logic r_search_n;

assign save_audio = reverb_out;//what is being sent to SRAM 
always_ff @(posedge clk or posedge rst) begin 
  if(rst)begin
    reverb_out <= 0; 
    r_search <= 0; 
  end else begin
    reverb_out <= current_out; 
    r_search <= r_search_n;
  end
end

logic [8:0] dividerin, dividerpast, dividercurrent;

assign r_offset = 13'd8000; //giving the r_offset a value
assign dividerin = {audio_in, 1'b0};
assign dividerpast = {past_output, 1'b0};

always_comb begin
  if(reverb_enable == 1)begin
    r_search_n = 1; //when reverb_enable is on, we want to start r_searching the readwrite for past output from SRAM
    dividercurrent = (dividerin + dividerpast)/2; //the echo formula: we are using C as 1, 
    current_out = dividercurrent[8:1];
  end else begin
    dividercurrent = 0;
    current_out = audio_in; 
    r_search_n = 0;
  end
end

endmodule