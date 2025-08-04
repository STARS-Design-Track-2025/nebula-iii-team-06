module team_06_tremelo( //so tremelo works by combing the audio input with a triangle waves
    input logic clk, rst,
    input logic [7:0] audio_in,
    input logic en,
    output logic [7:0] audio_out
);
    logic clkdiv, past_clkdiv;
    logic [7:0] curr_depth; //direction can be up and down. It will increment by 1 from 0 to 128
    logic [7:0] nxt_depth;//and decrement by 1 from 128 to 0.
    
    logic curr_direction; //as I said, it can either go up and down, so we need direction
    logic nxt_direction; 
  team_06_clkdivider #(.COUNT(24), .WIDTH(5)) div_i2sclk (.clk(clk), .rst(rst), // Inputs from top
  .clkOut(clkdiv), .past_clkOut(past_clkdiv)); // Outputs
    
    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            curr_depth <= '0;
            curr_direction <= 1;
            dividerout <= 128;
        end
        else begin
            curr_depth <= nxt_depth;
            curr_direction <= nxt_direction;
            dividerout <= dividerout_n;
        end
    end

    logic [15:0] dividerin, dividerdepth, dividerout, dividerout_n;
    always_comb begin
        dividerin = {8'b0, audio_in};
        dividerdepth = {8'b0, curr_depth};
        dividerout_n = dividerout;
        if(clkdiv && !past_clkdiv) begin
            if (en) begin
                if (dividerin >= 128) begin
                    dividerout_n = (255 - dividerin) + (2 * (dividerin - 128) * dividerdepth)/16'd16;
                end else begin
                    dividerout_n = (dividerin) + (2 * (127 - dividerin) * dividerdepth)/16'd16;
                end
            end else begin
                dividerout_n = 0;
            end
        end
        audio_out = dividerout[7:0];
    end                                            
                                                
    always_comb begin
        nxt_direction = curr_direction;
        nxt_depth = curr_depth;
        if(clkdiv && !past_clkdiv) begin
            if(en) begin
                if(curr_depth <16 && curr_direction == 1) begin
                    nxt_depth = curr_depth +1; 
                end
                else if (curr_depth == 16) begin
                    nxt_direction = 0;
                    nxt_depth = curr_depth - 1;
                end
                else if(curr_depth > 0 && curr_direction ==0) begin
                    nxt_depth = curr_depth - 1;
                end
                else if(curr_depth == 0) begin
                    nxt_direction = 1;
                    nxt_depth = curr_depth +1;
                end

            end
        end
    end
endmodule