module team_06_edge_detection_i2s(
    input logic i2sclk, clk, rst,
    output logic past_i2sclk
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            //curr_i2sclk <= 0;
            past_i2sclk <= 0;
        end else begin
            past_i2sclk <= i2sclk;
             //curr_i2sclk <= i2sclk;
        end
    end
endmodule