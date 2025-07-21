module team_06_i2s_to_dac_tb;
    logic [15:0] parallel_in;
    logic clk, rst;
    logic serial_out;
    logic i2sclk;
    
    team_06_i2sclkdivider div_i2sclk(.clk(clk), .rst(rst), .i2sclk(i2sclk));
    team_06_i2s_to_dac DUT(.parallel_in(parallel_in), .clk(clk), .rst(rst), .serial_out(serial_out));

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        $dumpfile("team_06_i2s_to_dac.vcd");
        $dumpvars(0, team_06_i2s_to_dac_tb);

        //power-on reset
        rst = 1;
        parallel_in = 16'b1101100111010011; //@(negedge i2sclk);
        #400;

       //normal operatopm
        rst = 0;
      #10000000;
        
        
        //mid operation reset
        rst = 1;
        parallel_in = 16'b1001100110110011; //@(negedge i2sclk);
        #1000;
        rst = 0;
        parallel_in = 16'b1111100110111111;
        #10000000;
        $finish;


    end



endmodule