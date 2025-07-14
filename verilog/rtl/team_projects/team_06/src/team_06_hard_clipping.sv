module team_06_hard_clipping (
    input logic audio_in[7:0],
    output logic hard_out[7:0]
);

//define maximum clipping threshold between (0 and 255)
localparam logic [7:0] max_thresh = 8'd200; //you can adjust this value as needed 

//hard clipping logic
always_comb begin
    if(audio_in > max_thresh)begin
    hard_out = max_thresh; //clip anything above the threshold 
    end else begin 
        hard_out = audio_in; // pass through values within the range
     end
end 

endmodule
