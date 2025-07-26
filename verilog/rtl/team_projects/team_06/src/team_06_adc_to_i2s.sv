module team_06_adc_to_i2s
(
    input logic clk, rst,
    input logic adc_serial_in, //adc sends msb first, so we shift right
    output logic [7:0] i2s_parallel_out,// i2s_parallel_out will always be 0 unitl it collects all 8 bits
    output logic finished, // this is to know if our 8 bit register recieve 8bbits form ADC
    output logic ws // Indicates we are changing the word (set of data)
);

    logic i2sclk;
    logic past_i2sclk;
    logic [4:0] counter, counter_n; // counter is used to count how many bits we have right now. it will count from 1 to 8
    logic finished_n;
    logic [31:0] out_temp, out_temp_n;
    logic [7:0] temp_signed, i2s_parallel_out_n;
    logic [7:0] data;
    logic ws_n;

    team_06_i2sclkdivider div_clk(.clk(clk), .rst(rst), .i2sclk(i2sclk));
    team_06_edge_detection_i2s ed(.i2sclk(i2sclk), .clk(clk), .rst(rst), .past_i2sclk(past_i2sclk));

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= '0;
            out_temp <= '0;
            finished <= '0;
            i2s_parallel_out <= 8'd128;
            ws <= 0;
        end else begin
            counter <= counter_n;
            out_temp <= out_temp_n;
            finished <= finished_n;                                                  
            i2s_parallel_out <= i2s_parallel_out_n; 
            ws <= ws_n;
        end
    end

    always_comb begin
        ws_n = ws;
        counter_n = counter;
        out_temp_n = out_temp;
        finished_n = finished;
        temp_signed = 0;
        i2s_parallel_out_n = i2s_parallel_out;
        if (!i2sclk && past_i2sclk && counter == 31) begin
            ws_n = !ws;
        end else if (i2sclk && !past_i2sclk) begin
            out_temp_n = {out_temp[30:0], adc_serial_in};
            counter_n = counter + 1;
            finished_n = (counter == 31);
            if (counter == 31) begin
                temp_signed = out_temp[30:23];
                i2s_parallel_out_n = temp_signed + 8'b10000000;   // -128 to 127  + 128 -> 0 to 255
            end
        end
    end 
endmodule
