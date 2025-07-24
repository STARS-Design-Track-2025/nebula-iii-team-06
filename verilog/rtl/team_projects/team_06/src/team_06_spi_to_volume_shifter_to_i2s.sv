module team_06_spi_to_volume_shifter_to_i2s_to_DAC(
    input logic esp_serial_in,
    input logic clk, rst,
    input logic [3:0] volume,
    input logic enable_volume,
    output logic i2s_serial_out
 ); 
    
    //connnects  esp to spi
    //first, we declare the ports between these two modules
    logic [7:0] spi_parallel_out;
    logic finished;
    team_06_esp_to_spi ronaldo(.clk(clk), .rst(rst), .esp_serial_in(esp_serial_in), .spi_parallel_out(spi_parallel_out), .finished(finished));

    //now we connects spi with volume shifter and i2s
    logic [7:0] volume_shifter_out
    team_06_volume_shifter messi(.clk(clk), .rst(rst), .audio_in(spi_parallel_out), .volume(volume), .enable_volume(enable_volume), .audio_out(volume_shifter_out));

    //connecta i2s to dac
    team_06_i2s_to_dac neymar(.parallel_in(volume_shifter_out), .clk(clk), .rst(rst), .serial_out(i2s_serial_out));





endmodule