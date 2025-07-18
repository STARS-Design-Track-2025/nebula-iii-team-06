module team_06_i2s_to_dac(
    input logic [15:0] parallel_in,
    input logic clk, rst,
    output logic serial_out
);
    logic [4:0] counter, counter_n;
    logic i2sclk, past_i2sclk;
    logic serial_out_n;
    logic [15:0] parallel_in_temp, parallel_in_temp_n;
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
        counter_n = counter;
        serial_out_n = serial_out;
        parallel_in_temp_n = parallel_in_temp;

        if (!i2sclk && past_i2sclk) begin 
            if (counter == 5'd0) begin
                parallel_in_temp_n = {parallel_in[14:0], 1'b0}; 
                serial_out_n = parallel_in[15]; 
                counter_n = counter + 1; 
            end else if (counter == 5'd15) begin
                serial_out_n = parallel_in_temp[15]; 
                parallel_in_temp_n = parallel_in; 
                counter_n = counter+1; 
            end else if (counter == 5'd16) begin
                counter_n = 1;
                parallel_in_temp_n = {parallel_in[14:0], 1'b0};
                serial_out_n = parallel_in_temp[15];
            end else begin
                counter_n = counter + 1;
                serial_out_n = parallel_in_temp[15]; 
                parallel_in_temp_n = {parallel_in_temp[14:0], 1'b0}; 
            end
        end
    end
endmodule