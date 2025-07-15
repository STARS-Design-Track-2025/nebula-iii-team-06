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

logic [7:0] r_current_out;

assign save_audio = reverb_out;

always_ff @(posedge clk or posedge rst) begin 
  if(rst)begin
    reverb_out <= 0;  
  end else begin
    reverb_out <= r_current_out; 
  end
end

assign r_offset = 13'd8000; //giving the offset a value

always_comb begin
  if(reverb_enable == 1)begin
    r_search = 1; //when echo_enable is on, we want to start searching the readwrite for past output from SRAM
    r_current_out = (audio_in + past_output) >> 1; //the echo formula: we are using C as 1, 
  end else begin
    r_current_out = audio_in; 
    r_search = 0;
  end
end

endmodule