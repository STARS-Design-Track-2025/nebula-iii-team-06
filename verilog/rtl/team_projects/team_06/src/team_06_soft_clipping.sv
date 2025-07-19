module team_06_soft_clipping(
    input logic [7:0] audio_in,  // input logic for transmitted signal
    output logic [7:0] soft_out  // output logic for the soft clipping
);

//soft clipping thresholds 
localparam logic [7:0] soft_max_thresh = 8'd220; //upper limit for soft clipping 
localparam logic [7:0] soft_start_max = 8'd180; //begin compression here
localparam logic [7:0] soft_start_min = 8'd76; //begin compression here
localparam logic [7:0] soft_min_thresh = 8'd36; //begin compression here

always_comb begin
    if (audio_in <= soft_min_thresh) begin // If you are below or equal to the min threshold, hard clipping
        soft_out = soft_min_thresh;
    end else if (audio_in < soft_start_min) begin // If you are below the soft low threshold, soft clipping
        soft_out =  audio_in + ((soft_start_min - audio_in) >> 1);
    end else if (audio_in >= soft_max_thresh) begin // If you are above or equal to the min threshold, hard clipping
        soft_out = soft_max_thresh;
    end else if (audio_in > soft_start_max) begin  // If you are above the soft high threshold, soft clipping
        soft_out = soft_start_max + ((audio_in - soft_start_max) >> 1); //gradually reduces loudness using slope compression 
    end else 
        soft_out = audio_in;
end

endmodule