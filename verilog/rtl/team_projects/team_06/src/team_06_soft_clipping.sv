module team_06_soft_clipping(
    input logic audio_in[7:0],
    output logic soft_out[7:0]
);

//soft clipping thresholds 
localparam logic [7:0] soft_max_thresh = 8'd220; //upper limit for soft clipping 
localparam logic [7:0] soft_start = 8'd180; //begin compression here

//temporary internal variable for smoothed output
logic [7:0] temp;

always_comb begin
    if (audio_in <= soft_start)begin //no clipping needed, just pass signal through
        soft_out = audio_in;
    end else if (audio_in <= soft_max_thresh) begin 
        temp = soft_start + ((audio_in - soft_start) >> 1); //gradually reduces loudness using slope compression 
        soft_out = temp;
    end else begin
        soft_out = soft_max_thresh; //clamps very loud values to soft_max_thresh i.e 220
    end
end



endmodule