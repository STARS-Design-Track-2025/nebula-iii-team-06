// // module team_06_adc_to_i2s
// // (
// //     input logic clk, rst,
// //     input logic adc_serial_in, //adc sends msb first, so we shift right
// //     output logic [7:0] spi_parallel_out,// spi_parallel_out will always be 0 unitl it collects all 8 bits
// //     output logic finished // this is to know if our 8 bit register recieve 8bbits form ADC

// );
//     logic i2sclk;
//     logic past_i2sclk;
//     //logic past_i2sclk;
//     logic [2:0] counter, counter_n; // counter is used to count how many bits we have right now. it will count from 1 to 8
//     logic [7:0] out_temp, out_temp_n, spi, spi_parallel_out_n;
//     logic finished_n;

//     team_06_i2sclkdivider div_clk(.clk(clk), .rst(rst), .i2sclk(i2sclk));
//     team_06_edge_detection_i2s ed(.i2sclk(i2sclk), .clk(clk), .rst(rst), .past_i2sclk(past_i2sclk));
//     always_ff @(posedge clk or posedge rst) begin
//         if(rst) begin
//             counter <= '0;
//             out_temp <= '0;
//             finished <= '0;
//             spi_parallel_out <= '0;
//         end else begin
//             counter <= counter_n;
//             out_temp <= out_temp_n;
//             finished <= finished_n;                                                  
//             spi_parallel_out <= spi_parallel_out_n; 
//         end
//     end

<<<<<<< HEAD
    always_comb begin
        ws_n = ws;
        counter_n = counter;
        out_temp_n = out_temp;
        finished_n = finished;
        i2s_parallel_out_n = i2s_parallel_out;
        if (!i2sclk && past_i2sclk && counter == 31) begin
            ws_n = !ws;
        end else if (i2sclk && !past_i2sclk) begin
            out_temp_n = {out_temp[30:0], adc_serial_in};
            counter_n = counter +1;
            finished_n= (counter == 31);
            if (counter == 31) begin
                signed_val = out_temp[30];
                data = out_temp[29:22];
                temp_signed = {signed_val, data};
                temp_unsigned = (temp_signed == 9'b10000000)? 011111111 : (signed_val == 0)? temp_signed : ~temp_signed + 9'd1;;
                i2s_parallel_out_n = (temp_unsigned > 10'd255) ? 8'd255: temp_unsigned[7:0];
            end
=======
//     always_comb begin
//         counter_n = counter;
//         out_temp_n = out_temp;
//         finished_n = finished;
//         spi_parallel_out_n = spi_parallel_out;
//         if (i2sclk && !past_i2sclk) begin
//             counter_n = counter + 1;
//             out_temp_n = {out_temp[6:0], adc_serial_in};
//             finished_n = (counter == 3'd7); 
//             spi_parallel_out_n = (counter == 3'd7) ? {out_temp[6:0], adc_serial_in} : spi_parallel_out;
//         end
//     end 
>>>>>>> 174ac799a7a1772e6f9b4ec7f13cd6135de3d95e

// // endmodule
