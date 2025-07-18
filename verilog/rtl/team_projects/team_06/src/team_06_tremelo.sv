module team_06_tremelo( //so tremelo works by combing the audio input with a triangle waves
    input logic clkdiv, rst,
    input logic [7:0] audio_in,
    input logic en,
    output logic [7:0] audio_out
);

/*
    logic [7:0] curr_depth; //direction can be up and down. It will increment by 1 from 0 to 128
    logic [7:0] nxt_depth;//and decrement by 1 from 128 to 0.
    
    logic curr_direction; //as I said, it can either go up and down, so we need direction
    logic nxt_direction; 
    
    always_ff @(posedge clkdiv, posedge rst) begin
        if(rst) begin
            curr_depth <= '0;
            curr_direction <= 1;
        end
        else begin
            curr_depth <= nxt_depth;
            curr_direction <= nxt_direction;
        end
    end

    logic [15:0] dividerin, dividerdepth, dividerout;
    always_comb begin
        dividerin = {8'b0, audio_in};
        dividerdepth = {8'b0, curr_depth};
        if (en) begin
            if (dividerin >= 128) begin
                dividerout = (dividerin * dividerdepth )/16'd16
            end else begin
                dividerout = ((128 - dividerin) * dividerdepth )/16'd16
            end
        e

        dividerout = en ? ((dividerin * dividerdepth )/16'd16) : 0; // We need to chage formula for tremelo to account for lack of two's compliment
        audio_out = dividerout[7:0];
    end                                            // if we multiply together, the reuslt got hella bits, so we shift by 7
                                                //to reduce number of bits
    always_comb begin
        nxt_direction = curr_direction;
        nxt_depth = curr_depth;
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
*/
endmodule