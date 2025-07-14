module team_06_i2s_to_dac(
    input logic [7:0] parallel_in,
    input logic clk, rst,
    output logic serial_out
);
    logic [3:0] counter;
    logic [7:0] parallel_in_temp;
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= '0;
            serial_out <= '0;
            parallel_in_temp <= '0;
        end else begin
            parallel_in_temp <= (counter == 4'd7 || counter == 0)?parallel_in:{parallel_in_temp[6:0], 0};
            serial_out <= parallel_in_temp[7];
            counter <= (counter==8)?1:(counter + 1);
        end
    end
endmodule