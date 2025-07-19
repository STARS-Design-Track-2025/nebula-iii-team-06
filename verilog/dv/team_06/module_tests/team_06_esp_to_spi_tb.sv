`timescale 1ms/10ps
module team_06_esp_to_spi_tb;

logic clk;
logic rst;
logic esp_serial_in;
logic [7:0] spi_parallel_out;
logic finished;
logic spiclk;
logic past_spiclk;

 //Instantiation of the module
team_06_esp_to_spi trung (
   .clk(clk),
   .rst(rst),
   .esp_serial_in(esp_serial_in),
   .spi_parallel_out(spi_parallel_out),
   .finished(finished)
);

initial clk = 0;
always #0.5 clk = ~clk;

initial begin
   //waveform dumping
   $dumpfile ("team_06_esp_to_spi.vcd");
   $dumpvars (0, team_06_esp_to_spi_tb);

   rst = 1;
   esp_serial_in = 1;

   @(posedge clk);
   rst = 0;
   esp_serial_in = 1;

   repeat(2) @(posedge clk);
   #500
   rst = 1;
   esp_serial_in = 1;

   @(posedge clk);
   #500
   rst = 0;
   esp_serial_in = 1;

   repeat(5) @(posedge clk);
   #500
   rst = 0;
   esp_serial_in = 0;

   repeat(5) @(posedge clk);
   #500
   rst = 0;
   esp_serial_in = 0;

   repeat (5) @(posedge clk);
   #500
   rst = 1;
   esp_serial_in = 1;

   repeat(3) @(posedge clk);

$finish;
end


endmodule

