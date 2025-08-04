module team_06_clkdivider #(parameter COUNT = 1, parameter WIDTH = 1) (
    input logic clk, rst,
    output logic clkOut,
    output logic past_clkOut
);
    logic [WIDTH-1:0] counter;
    logic clkOut_n;
    logic [WIDTH-1:0] counter_n;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= '0;
            clkOut <= '0;
            past_clkOut <= 0;
        end
        else begin
            counter <= counter_n;
            clkOut <= clkOut_n;
            past_clkOut <= clkOut;
        end
    end

    always_comb begin
        counter_n = counter;
        clkOut_n = clkOut;
        if(counter == COUNT) begin
            counter_n = 1;
            clkOut_n = ~clkOut;
        end
        else begin
            counter_n = counter + 1;
        end
    end
endmodule