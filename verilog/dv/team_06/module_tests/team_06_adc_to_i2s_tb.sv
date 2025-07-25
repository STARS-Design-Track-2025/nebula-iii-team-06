module team_06_adc_to_i2s_tb;
    logic clk, rst;
    logic adc_serial_in; //adc sends msb first, so we shift right
    logic [7:0] i2s_parallel_out;// spi_parallel_out will always be 0 unitl it collects all 8 bits
    logic finished;
    logic [7:0] temp;
    logic i2sclk;
    logic ws;

    team_06_adc_to_i2s DUT(.clk(clk), .rst(rst), .adc_serial_in(adc_serial_in), .i2s_parallel_out(i2s_parallel_out), .finished(finished), .ws(ws));
    team_06_i2sclkdivider div_i2sclk(.clk(clk), .rst(rst), .i2sclk(i2sclk));


    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    initial begin
        $dumpfile("team_06_adc_to_i2s.vcd");
        $dumpvars(0, team_06_adc_to_i2s_tb);
        adc_serial_in = 0;
        rst = 1;
        @(negedge i2sclk);
        
        rst = 0; //sends :10100111
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 0; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 0; @(negedge i2sclk);
        adc_serial_in = 0; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 0; @(negedge i2sclk);
        adc_serial_in = 0; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 0; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 0; @(negedge i2sclk);
        adc_serial_in = 0; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 0; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 0; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 0; @(negedge i2sclk);

        // Test -1
        adc_serial_in = 1; @(negedge i2sclk);
        repeat (39) @(negedge i2sclk);

        // Test -128
        adc_serial_in = 1; @(negedge i2sclk);
        adc_serial_in = 0; @(negedge i2sclk);
        repeat (30) @(negedge i2sclk);

        // Test 127
        adc_serial_in = 0; @(negedge i2sclk);
        adc_serial_in = 1; @(negedge i2sclk);
        repeat (37) @(negedge i2sclk);

        //rst = 1;
      #250000
        rst = 1;
        #25000
        rst = 0;
        #25000
        //another way by using for loop. we have to send msb first
        temp = 8'b11010110;
        for(int i = 7; i >= 0; i--) begin
            adc_serial_in = temp[i]; @(posedge i2sclk);
        end
        $finish;
    end
    
endmodule