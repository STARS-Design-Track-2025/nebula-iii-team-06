module team_06_spi_to_volume_shifter_to_i2s_to_DAC_tb;
    logic esp_serial_in;
    logic clk;
    logic rst;
    logic [3:0] volume;
    logic enable_volume;
    logic i2s_serial_out;
    logic clkdiv;

    team_06_spi_to_volume_shifter_to_i2s_to_DAC DUT(.esp_serial_in(esp_serial_in), .clk(clk), .rst(rst), .volume(volume), 
            .enable_volume(enable_volume), .i2s_serial_out(i2s_serial_out));
    team_06_i2sclkdivider div_i2sclk(.clk(clk), .rst(rst), .i2sclk(clkdiv));
    //clock generatiom
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        $dumpfile("team_06_spi_to_volume_shifter_to_i2s_to_DAC.vcd");
        $dumpvars(0, team_06_spi_to_volume_shifter_to_i2s_to_DAC_tb);

        //initialize inputs
        
        volume = 10;
        enable_volume = 1;
        rst= 0;
        #100;
        //power on rst
        rst = 1;
        #100; // 5 cycle

        //normal operation
        rst = 0;
        esp_serial_in = 1; @(negedge clkdiv);
        esp_serial_in = 0;@(negedge clkdiv);
        esp_serial_in = 1;@(negedge clkdiv);
        esp_serial_in = 0;@(negedge clkdiv);
        esp_serial_in = 1;@(negedge clkdiv);
        esp_serial_in = 0;@(negedge clkdiv);
        esp_serial_in = 1;@(negedge clkdiv);
        esp_serial_in = 0;@(negedge clkdiv);
        #100;
        enable_volume = 0;
        #100;

        //normal operataion reset
        rst = 1;
        #1000;
        enable_volume = 1;
        rst = 0;
        esp_serial_in = 1; @(negedge clkdiv);
        esp_serial_in = 0;@(negedge clkdiv);
        esp_serial_in = 1;@(negedge clkdiv);
        esp_serial_in = 0;@(negedge clkdiv);
        esp_serial_in = 1;@(negedge clkdiv);
        esp_serial_in = 0;@(negedge clkdiv);
        esp_serial_in = 1;@(negedge clkdiv);
        esp_serial_in = 1;@(negedge clkdiv);
        #100;
        
        $finish;


      

    end
endmodule