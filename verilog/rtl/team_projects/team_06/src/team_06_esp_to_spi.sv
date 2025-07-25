module team_06_esp_to_spi
(
   input logic clk, rst,
   input logic esp_serial_in, //adc sends msb first, so we shift right
   output logic [7:0] spi_parallel_out,// i2s_parallel_out will always be 0 unitl it collects all 8 bits
   output logic finished // this is to know if our 8 bit register recieve 8bbits form ADC
 
);
   logic spiclk;   // clock signal for the divider clock from div_clk
   logic past_spiclk;  // We use this clock in tandem with the spiclk to detect edges for the parallel output
   //logic past_i2sclk;
   logic [4:0] counter, counter_n; // counter is used to count how many bits we have right now. it will count from 1 to 8
   logic [7:0] spi_parallel_out_n; // our temporary variable we use to update the output
   logic finished_n;              // this is the logic used to detect when the counter reaches eight
   logic [7:0] out_temp, out_temp_n; // buffer signal


   team_06_i2sclkdivider div_clk(.clk(clk), .rst(rst), .i2sclk(spiclk));
   team_06_edge_detection_i2s ed(.i2sclk(spiclk), .clk(clk), .rst(rst), .past_i2sclk(past_spiclk));


   // Here, is the flip-flop we use to update, in essence, our output using its temporary signal
   always_ff @(posedge clk or posedge rst) begin
       if(rst) begin
           counter <= 0;
           out_temp <= 0;
           finished <= 0;
           spi_parallel_out <= 8'd128;
          
       end else begin
           counter <= counter_n;
           finished <= finished_n;                                                 
           spi_parallel_out <= spi_parallel_out_n;
           out_temp <= out_temp_n;
     end
   end
   // Here, is the comb-logic for the counter, the "finished", and the output for the esp to spi module
   always_comb begin
       counter_n = counter;
       finished_n = finished;
       out_temp_n = out_temp;
       spi_parallel_out_n =  spi_parallel_out;
       if (!spiclk && past_spiclk) begin
          if ( counter == 8) begin
               spi_parallel_out_n = out_temp;
               out_temp_n = {out_temp[6:0], esp_serial_in};
               counter_n = 1;
               finished_n = 1;
          end else begin
           out_temp_n = {out_temp[6:0], esp_serial_in};
           counter_n = counter + 1;
           finished_n = 0;
          end
         


       end
   end


endmodule
