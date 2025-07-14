module team_06_clkdivider( // this module is to create a new clock that has lower frequency than the 
    input clk, rst, //system's clock so that the new clock can be used for tremelo module
    output clkdiv
);
    logic [24:0] counter;
    logic [24:0] counter_n;
    logic clkdiv_temp;
    logic clkdiv_temp_n;
    parameter DIV_COUNT = 25_000_000 / 2; // so our counter will ramp up tp this value and
                                         // and once it reaches this value, the clock will toggle

    assign clkdiv = clkdiv_temp;
    
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= 0;
            clkdiv_temp <= 0;

        end else begin
            counter <= counter_n;
            clkdiv_temp <= clkdiv_temp_n;
        end 
    end

    always_comb begin
        counter_n = counter;
        clkdiv_temp_n = clkdiv_temp;
        if(counter < DIV_COUNT) begin
            counter_n = counter + 1;
        end
        else if(counter == DIV_COUNT) begin
            counter_n = 0;
            clkdiv_temp_n = ~clkdiv_temp;
        end
    end

endmodule