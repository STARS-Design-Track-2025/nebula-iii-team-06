`timescale 1ms/10ps
module team_06_spi_to_esp_tb;

logic clk;
logic rst;
logic [7:0] parallel_in;
logic cs;
logic serial_out;
logic past_spiclk;

//Instantiation of the module
team_06_spi_to_esp trung (
.parallel_in(parallel_in),
.clk(clk),
.rst(rst),
.cs(cs),
.serial_out(serial_out)
);

initial clk = 0;
always #0.5 clk = ~clk;


initial begin
//waveform dumping
$dumpfile ("team_06_spi_to_esp.vcd");
$dumpvars (0, team_06_spi_to_esp_tb);

cs = 0;
rst = 1;
parallel_in = 67;
#0.5
@(posedge clk);
cs = 1;
rst = 0;
parallel_in = 1;

#500
@(posedge clk);
cs = 0;
rst = 0;
parallel_in = 32;


@(posedge clk);
#500
cs = 1;
rst = 1;
parallel_in = 83;

@(posedge clk);
#500
cs = 1;
rst = 0;
parallel_in = 255;

@(posedge clk);
#500
cs = 1;
rst = 0;
parallel_in = 79;
#500
$finish;
end

endmodule
