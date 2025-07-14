module team_06_adc_to_i2s
(
    input logic spiclk, rst,
    input logic adc_serial_in, //adc sends msb first, so we shift right
    output logic [7:0] spi_parallel_out,// spi_parallel_out will always be 0 unitl it collects all 8 bits
    output logic finished // this is to know if our 8 bit register recieve 8bbits form ADC

);
    logic [3:0] counter; // counter is used to count how many bits we have right now. it will count from 1 to 8
    logic [7:0] out_temp;
    always_ff @(posedge spiclk or posedge rst) begin
        if(rst) begin
            counter <= ' 0;
            out_temp <= '0;
            finished <= '0;
            spi_parallel_out <= '0;
        end else begin
            counter <= (counter == 4'd8)? 0: counter +1;
            out_temp <= {out_temp[6:0], adc_serial_in};
            finished <= (counter == 4'd8)? 1:0;                                                   
            spi_parallel_out <= (counter == 4'd8)? {out_temp[6:0], adc_serial_in} : 0;
        end
    end

endmodule
