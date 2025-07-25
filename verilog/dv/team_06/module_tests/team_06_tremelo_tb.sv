module team_06_tremelo_tb;
    logic clk, rst;  //put all the port ont this module
    logic [7:0] audio_in;
    logic enable;
    logic [7:0] audio_out;


    //instantiate the DUT
    team_06_tremelo DUT(.clk(clk), .rst(rst), .audio_in(audio_in), .en(enable), .audio_out(audio_out));


    //clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // every 10 unit, it toggles
    end

    //stimulus begin
    initial begin

        $dumpfile("team_06_tremelo.vcd");
        $dumpvars(0, team_06_tremelo_tb);
        audio_in = 8'b11100101;
        rst = 1;
        enable = 0;

        #25;// we set 25 so rst changes in between rising edge and falling edge. this is to prevent race condition
        rst = 0;
        enable = 1;

        #25;// we set 25 so rst changes in between rising edge and falling edge. this is to prevent race condition
        audio_in = 8'b11111111;
        rst = 0;
        enable = 1;

        repeat (360) @(posedge clk);
        audio_in = 8'b00000100;
        rst = 0;
        enable = 1;
        repeat (360) @(posedge clk);
        rst = 1;
        enable = 1;
        repeat (360) @(posedge clk);
        audio_in = 8'b01111111;
        rst = 0;
        enable = 1;
        repeat (360) @(posedge clk);
        audio_in = 8'b000000000;
        rst = 0;
        enable = 0;
        repeat (360) @(posedge clk);
        audio_in = 8'b10000000;
        rst = 0;
        enable = 1;  
        repeat (360) @(posedge clk);
        audio_in = 8'b000000000;
        rst = 0;
        enable = 1;
        repeat (360) @(posedge clk);
        audio_in = 8'b10000000;
        rst = 0;
        enable = 1;    
        $finish;

    end
endmodule