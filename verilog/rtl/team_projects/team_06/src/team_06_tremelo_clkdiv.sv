module team_06_tremelo_clkdiv (
    input logic clk, rst,
    output logic clkdiv
);
    logic [4:0] counter;
    logic clkdiv_n;
    logic [4:0] counter_n;
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= '0;
            clkdiv <= '0;
        end
        else begin
            counter <= counter_n;
            clkdiv <= clkdiv_n;
        end
    end

    always_comb begin
        counter_n = counter;
        clkdiv_n = clkdiv;
        if(counter == 24) begin
            counter_n = 1;
            clkdiv_n = ~clkdiv;
        end
        else begin
            counter_n = counter + 1;
        end
    end
endmodule