module team_06_spi_to_esp_tb;
   logic [7:0] parallel_in;
   logic clk, rst;
   logic serial_out;
   logic spiclk;
   logic cs;
  
   team_06_i2sclkdivider div_i2sclk(.clk(clk), .rst(rst), .i2sclk(spiclk));
   team_06_spi_to_esp DUT(.parallel_in(parallel_in), .clk(clk), .rst(rst), .serial_out(serial_out), .cs(cs));


   initial begin
       clk = 0;
       forever #10 clk = ~clk;
   end


   initial begin
       $dumpfile("team_06_spi_to_esp.vcd");
       $dumpvars(0, team_06_spi_to_esp_tb);


       //power-on reset
       cs = 1;
       rst = 1;
       parallel_in = 8'b10101100; @(negedge spiclk);
     #15;


      
       //mid operation reset
       rst = 0;
       parallel_in = 8'b10101100;
       #20;
       rst = 1;


       //normal operatoion
       #40;
       rst = 0;
       #10000000;
       $finish;

   end

endmodule
