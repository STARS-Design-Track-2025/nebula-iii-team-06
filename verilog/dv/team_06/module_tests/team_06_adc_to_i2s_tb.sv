module team_06_adc_to_i2s_tb;
    logic spiclk, rst;
    logic adc_serial_in; //adc sends msb first, so we shift right
    logic [7:0] spi_parallel_out;// spi_parallel_out will always be 0 unitl it collects all 8 bits
    logic finished;
    logic [7:0] temp;

    team_06_adc_to_i2s DUT(.spiclk(spiclk), .rst(rst), .adc_serial_in(adc_serial_in), .spi_parallel_out(spi_parallel_out), .finished(finished));

    initial begin
        spiclk = 0;
        forever #10 spiclk = ~spiclk;
    end
    initial begin
        $dumpfile("team_06_adc_to_i2s.vcd");
        $dumpvars(0, team_06_adc_to_i2s_tb);
        adc_serial_in = 0;
        rst = 1;
        #25;
        
        rst = 0; //sends :10100111
        adc_serial_in = 1; @(posedge spiclk);
        adc_serial_in = 0; @(posedge spiclk);
        adc_serial_in = 1; @(posedge spiclk);
        adc_serial_in = 0; @(posedge spiclk);
        adc_serial_in = 0; @(posedge spiclk);
        adc_serial_in = 1; @(posedge spiclk);
        adc_serial_in = 1; @(posedge spiclk);
        adc_serial_in = 1; @(posedge spiclk);

        rst = 1;
        #15;
        rst = 0;

        //another way by using for loop. we have to send msb first
        temp = 8'b11010110;
        for(int i = 7; i >= 0; i--) begin
            adc_serial_in = temp[i]; @(posedge spiclk);
        end
        $finish;
    end
    
endmodule