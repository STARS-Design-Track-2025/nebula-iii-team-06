module team_06_i2s_to_dac(
    input logic [7:0] parallel_in,
    input logic clk, rst, en,
    output logic serial_out
);
    logic [4:0] counter, counter_n;
    logic i2sclk, past_i2sclk;
    logic serial_out_n;
    logic [7:0] parallel_in_temp, parallel_in_temp_n;
    team_06_i2sclkdivider div_clk(.clk(clk), .rst(rst), .i2sclk(i2sclk));
    team_06_edge_detection_i2s ed(.i2sclk(i2sclk), .clk(clk), .rst(rst), .past_i2sclk(past_i2sclk));
    
    
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= '0;
            serial_out <= '0;
            parallel_in_temp <= '0;
            
        end else begin
            serial_out <= serial_out_n;
            counter <= counter_n;
            parallel_in_temp <= parallel_in_temp_n;
        end
    end

    always_comb begin
        // counter_n = counter;
        // serial_out_n = serial_out;
        // parallel_in_temp_n = parallel_in_temp;

        if (en) begin
            if (!i2sclk && past_i2sclk) begin 
                if (counter == 5'd0) begin
                    parallel_in_temp_n = {parallel_in[6:0], 1'b0}; 
                    serial_out_n = parallel_in[7]; 
                    counter_n = counter + 1; 
                end else if (counter == 5'd7) begin
                    serial_out_n = parallel_in_temp[7]; 
                    parallel_in_temp_n = parallel_in; 
                    counter_n = counter + 1; 
                end else if (counter == 5'd8) begin
                    counter_n = 1;
                    parallel_in_temp_n = {parallel_in[6:0], 1'b0};
                    serial_out_n = parallel_in[7]; // NOT parallel_in_temp[7], since we reloaded
                end else begin
                    counter_n = counter + 1;
                    serial_out_n = parallel_in_temp[7]; 
                    parallel_in_temp_n = {parallel_in_temp[6:0], 1'b0}; 
                end
            end
            else begin
                counter_n = counter;
                serial_out_n = serial_out;
                parallel_in_temp_n = parallel_in_temp;

            end
        end
        else begin
            serial_out_n = 0;
            counter_n = counter;
            parallel_in_temp_n = parallel_in_temp;
        end
    end
endmodule