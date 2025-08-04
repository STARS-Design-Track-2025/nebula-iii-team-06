module team_06_i2s_to_dac(
    input logic [7:0] parallel_in,
    input logic clk, rst,
    input logic i2sclk, past_i2sclk,
    output logic serial_out
);
    logic [4:0] counter, counter_n;
    logic serial_out_n;
    logic [7:0] parallel_in_temp, parallel_in_temp_n;
      
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
        if (!i2sclk && past_i2sclk) begin // On falling edge
            if (counter == 5'd0) begin // At count zero, we should not do anything
                parallel_in_temp_n = parallel_in; 
                serial_out_n = 0; 
                counter_n = counter + 1; 
            end else if (counter == 5'd9 || counter == 5'd1) begin // At count 1 or 9, we are getting ready for transmission, add first bit
                counter_n = 2;
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
endmodule