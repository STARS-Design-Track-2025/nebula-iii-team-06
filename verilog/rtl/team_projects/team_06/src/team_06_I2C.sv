module team_06_I2C 
(
    input logic clk, rst, effect;
)

logic [8:0] counter; 
logic [8:0] counter_n;
logic clkdiv;
logic clkdiv_n;

    // Clock divider
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= 0;
            clkdiv <= 0;
        end else begin
            counter <= counter_n;
            clkdiv <= clkdiv_n;
        end 
    end

    always_comb begin
        counter_n = counter + 1;
        if(counter == 9'd512) begin // We divide down to about 24 kHz (just random, can change. This is our pseudo-bitclock)
            clkdiv_n = ~clkdiv;
        end
    end

    // Store state change
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            effect_old <= 0;
        end else begin
            effect_old <= effect;
        end 
    end

    always_comb begin
        
    end


endmodule