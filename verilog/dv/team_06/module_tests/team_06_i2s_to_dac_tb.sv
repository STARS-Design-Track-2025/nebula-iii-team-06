module team_06_i2s_to_dac_tb;
    logic [7:0] parallel_in;
    logic clk, clkdiv, past_clkdiv, rst, en;
    logic serial_out;

    team_06_i2s_to_dac DUT(.parallel_in(parallel_in), .clk(clk), .rst(rst), .serial_out(serial_out), .en(en));
    team_06_clkdivider #(.COUNT(24), .WIDTH(5)) div_i2sclk(.clk(clk), .rst(rst), .clkOut(clkdiv), .past_clkOut(past_clkdiv));


    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        $dumpfile("team_06_i2s_to_dac.vcd");
        $dumpvars(0, team_06_i2s_to_dac_tb);

        //power-on reset
        en = 1;
        rst = 1;
        parallel_in = 8'b11011011; //@(negedge i2sclk);
        

       //normal operatop
       @(posedge clk);
        rst = 0;
        repeat(8) @(negedge clkdiv);
        parallel_in = 8'b00101001; 

     #10000000;
        en = 0;
      #10000;

        //mid operation reset
        en = 1;
        rst = 1;
        parallel_in = 8'b10011001; //@(negedge i2sclk);
        #1000;
        rst = 0;
        parallel_in = 8'b11111001;
        #10000000;
        $finish;

    end

endmodule