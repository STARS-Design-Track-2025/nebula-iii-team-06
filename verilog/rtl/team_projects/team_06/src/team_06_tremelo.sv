module team_06_tremelo( //so tremelo works by combing the audio input with a triangle waves
    input logic clkdiv, rst,
    input logic [7:0] audio_in,
    input logic en,
    output logic [7:0] audio_out
);
    //logic [7:0] threshold; // the threshold is the maximumn value that our depth can reach
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

    assign audio_out = en ? ((audio_in/8'd16 * curr_depth )) : audio_in;
                                                // if we multiply together, the reuslt got hella bits, so we shift by 7
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


endmodule