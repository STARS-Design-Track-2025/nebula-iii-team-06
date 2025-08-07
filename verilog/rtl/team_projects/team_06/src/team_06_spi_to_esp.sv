module team_06_spi_to_esp(  // this module is to send  8-bit data from SPI serially to esp
    input logic clk, rst,
    input logic [7:0] parallel_in, //input is 8 bits
    input logic spiclk, past_spiclk,
    output logic cs, //you know what clk and rst is. cs is basically an enable signal
    output logic serial_out // serial output
);
    logic [4:0] counter, counter_n; // the counter is to cou if the spi has released all 8 bits. it counts from 1 to 8
    logic serial_out_n; // sequential value of serial_out
    logic [7:0] parallel_in_temp, parallel_in_temp_n;
    logic cs_n;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= '0;
            serial_out <= '0;
            parallel_in_temp <= '0;
            cs <= 1;
        end else begin
            serial_out <= serial_out_n;
            counter <= counter_n;
            parallel_in_temp <= parallel_in_temp_n;
            cs <= cs_n;
        end
    end

    always_comb begin
        counter_n = counter;
        serial_out_n = serial_out;
        parallel_in_temp_n = parallel_in_temp;
        cs_n = 0;

        if (!spiclk && past_spiclk) begin 
            if (counter == 5'd0) begin // if counter is at 0
                parallel_in_temp_n = {parallel_in[6:0], 1'b0}; // example: if we are at 0, and parallel in is 10100111. parallel_in_temp_n wil be 01001110. we put in a new 0 on the right 
                serial_out_n = parallel_in[7];// as I said parallel_in is 10100111. serial_out_n will be the leftmost digit on parallel_in, which is 1
                counter_n = counter + 1; //increments
            end else if (counter == 5'd7) begin
                serial_out_n = parallel_in_temp[7]; //same thing
                parallel_in_temp_n = parallel_in; // at coutner = 7, we load in a new parallel_in, or a new sample
                counter_n = counter+1; 
            end else if (counter == 5'd8) begin
                counter_n = 1;
                parallel_in_temp_n = {parallel_in[6:0], 1'b0};
                serial_out_n = parallel_in_temp[7];
            end else begin
                counter_n = counter + 1;
                serial_out_n = parallel_in_temp[7]; 
                parallel_in_temp_n = {parallel_in_temp[6:0], 1'b0}; 
            end
        end else if (cs) begin
            serial_out_n = 0;
        end
    end
endmodule