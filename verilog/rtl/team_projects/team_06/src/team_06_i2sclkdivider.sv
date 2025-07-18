module team_06_i2sclkdivider(
    input logic clk, rst,
    output logic i2sclk
);

    logic [4:0] counter;
    logic i2sclk_n;
    logic [4:0] counter_n;
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= '0;
            i2sclk <= '0;
        end
        else begin
            counter <= counter_n;
            i2sclk <= i2sclk_n;
        end
    end

    always_comb begin
        counter_n = counter;
        i2sclk_n = i2sclk;
        if(counter == 24) begin
            counter_n = 1;
            i2sclk_n = ~i2sclk;
        end else begin
            counter_n = counter + 1;
        end
    end
endmodule