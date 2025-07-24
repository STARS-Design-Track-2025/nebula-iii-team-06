module team_06_echo_and_reverb (
  input logic clk, rst, 
  input logic [7:0] audio_in, //original audio entering echo module 
  input logic echo_en, //thismeans
  input logic reverb_en, 
  input logic [7:0] past_output, //past_output coming from memory
  output logic [12:0] offset, //amount of spaces back we go to get the past output
  output logic [7:0] echo_reverb_out, //the echo output
  output logic [7:0] save_audio //what is being sent to the SRAM
);

//ECHO = (audio_in  + c*past_input)/(1 + C) 
logic [7:0] current_out; //temporary echo output 
logic [7:0] save_audio_n;

always_ff @(posedge clk or posedge rst) begin 
    if(rst)begin
        echo_reverb_out <= 8'd0;
        save_audio <= 8'd0;
    end else begin
        echo_reverb_out <= current_out; 
        save_audio <= audio_in;
    end
end

always_comb begin
  if (echo_en && !reverb_en) begin
    save_audio_n = audio_in;
  end else if (!echo_en && reverb_en) begin
    save_audio_n = current_out;
  end else begin
    save_audio_n = 0;
  end
end

logic [8:0] dividerin, dividerpast, dividercurrent;
always_comb begin
    offset = 13'd8000; //giving the offset a value
    dividerin = {audio_in, 1'b0};
    dividerpast = {past_output, 1'b0};
end 

always_comb begin
    if( (echo_en && !reverb_en) || (!echo_en && reverb_en) )begin
        dividercurrent = (dividerin + dividerpast)/2; //the echo formula: we are using C as 1, 
        current_out = dividercurrent[8:1];
    end else begin
        dividercurrent = 0;
        current_out = 0; 
    end
end
endmodule
