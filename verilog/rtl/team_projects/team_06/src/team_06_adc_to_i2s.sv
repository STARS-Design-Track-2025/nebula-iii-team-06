module team_06_adc_to_i2s
(
    input logic clk, rst,
    input logic adc_serial_in, //adc sends msb first, so we shift right
    input logic i2sclk, // Comes from clkdivider, clock speed is 10MHZ / (2 * counter), must not exceed 3.2 MHZ
    input logic past_i2sclk, // Comes from clkdivider
    output logic [7:0] i2s_parallel_out,// i2s_parallel_out will always be 0 unitl it collects all 8 bits
    output logic fifnished, // this is to know if our 8 bit register recieve 8bbits form ADC
    output logic ws // Indicates we are changing the word (set of data)
);

    logic [4:0] counter, counter_n; // counter is used to count how many bits we have right now. 
    logic done_n;
    logic [31:0] out_temp, out_temp_n;
    logic [7:0] temp_signed, i2s_parallel_out_n; // Temp signed is the data before any conversions, raw ADC data
    logic ws_n;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= '0;
            out_temp <= '0;
            done <= '0;
            i2s_parallel_out <= 8'd128;
            ws <= 0;
        end else begin
            counter <= counter_n;
            out_temp <= out_temp_n;
            done <= done_n;                                                  
            i2s_parallel_out <= i2s_parallel_out_n; 
            ws <= ws_n;
        end
    end

    always_comb begin
        ws_n = ws;
        counter_n = counter;
        out_temp_n = out_temp;
        done_n = done;
        temp_signed = 0;
        i2s_parallel_out_n = i2s_parallel_out;
        if (!i2sclk && past_i2sclk && done) begin // If we are on a falling edge and we are at the end of our count, toggle word select
            ws_n = !ws;
            finished == (ws == 1) ? 1 : 0;
        end else if (i2sclk && !past_i2sclk && !ws) begin // On every rising edge
            out_temp_n = {out_temp[30:0], adc_serial_in}; // Add newest bit
            counter_n = counter + 1;
            done_n = (counter == 31); 
            if (counter == 31) begin
                temp_signed = out_temp[30:23]; // These are the only bits that we care about (8 MSBs)
                i2s_parallel_out_n = temp_signed + 8'b10000000;   // -128 to 127  + 128 -> 0 to 255
            end
        end
    end 
endmodule