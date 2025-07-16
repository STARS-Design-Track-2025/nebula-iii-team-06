module team_06_adc_to_i2s
(
    input logic clk, rst,
    input logic adc_serial_in, //adc sends msb first, so we shift right
    output logic [7:0] spi_parallel_out,// spi_parallel_out will always be 0 unitl it collects all 8 bits
    output logic finished // this is to know if our 8 bit register recieve 8bbits form ADC

);
    logic i2sclk;
    logic curr_i2sclk, past_i2sclk;
    //logic past_i2sclk;
    logic [2:0] counter, counter_n; // counter is used to count how many bits we have right now. it will count from 1 to 8
    logic [7:0] out_temp, out_temp_n, spi, spi_parallel_out_n;
    logic finished_n;

    team_06_i2sclkdivider div_clk(.clk(clk), .rst(rst), .i2sclk(i2sclk));
    team_06_edge_detection_i2s ed(.i2sclk(i2sclk), .curr_i2sclk(curr_i2sclk), .past_i2sclk(past_i2sclk));
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= '0;
            out_temp <= '0;
            finished <= '0;
            spi_parallel_out <= '0;
        end else begin
            counter <= counter_n;
            out_temp <= out_temp_n;
            finished <= finished_n;                                                  
            spi_parallel_out <= spi_parallel_out_n; 
        end
    end

    always_comb begin
        counter_n = counter;
        out_temp_n = out_temp;
        finished_n = finished;
        spi_parallel_out_n = spi_parallel_out;
        if (curr_i2sclk && !past_i2sclk) begin
            counter_n = counter + 1;
            out_temp_n = {out_temp[6:0], adc_serial_in};
            finished_n = (counter == 3'd7); 
            spi_parallel_out_n = (counter == 3'd7) ? {out_temp[6:0], adc_serial_in} : spi_parallel_out;
        end
    end 

endmodule
