module team_06_I2C 
(
    input logic clk, rst, effect
);
/*
logic [8:0] counter; 
logic [8:0] counter_n;
logic clkdiv;
logic clkdiv_n;
logic sda;
logic scl;
logic effect_old;

    // Clock divider for send
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
        clkdiv_n = clkdiv;
        if(counter == 9'd511) begin // We divide down to about 24 kHz (just random, can change. This is our pseudo-bitclock)
            clkdiv_n = ~clkdiv;
        end
    end


    // Store state change and count
    logic start, start_n, ending, ending_n;
    logic [4:0] transmissionCount, transmissionCount_n;
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            effect_old <= 0;
            start <= 0;
            ending <= 0;
            transmissionCount <= 17; // This keeps track of how many half cycles you need to cycle the clock
        end else begin
            effect_old <= effect;
            start <= 0;
            ending <= 0;
            transmissionCount <= transmissionCount_n;
        end 
    end

    always_comb begin
        start_n = start;
        ending_n = ending;
        if (clkdiv_n != clkdiv) // If clkdiv has changed states
            transmissionCount_n = transmissionCount + 1; // Base case: transmission count goes up
            if (effect_old != effect && transmissionCount == 17) begin // If you are done transmitting and you have a new effect, get ready for transmission
                transmissionCount_n = 0;
                start_n = 1;
                ending_n = 0;
            end else if (transmissionCount == 17) // If you are done transmitting
                ending_n = 1;
                transmissionCount_n = 17; // Do nothing
    end

    // SDA and SCL controls
    logic sda_n, scl_n;
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            sda <= 1;
            scl <= 1;
        end else begin
            sda <= sda_n;
            scl <= scl_n;
        end 
    end

always_comb begin
    if (start)
        if (sda_n == 1) begin
            sda_n = 0;
        end else
            scl_n = 0;
    case (transmissionCount)
    endcase
end
*/
endmodule