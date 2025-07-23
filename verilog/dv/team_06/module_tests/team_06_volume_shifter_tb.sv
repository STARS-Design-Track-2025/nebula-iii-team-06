module team_06_volume_shifter_tb;
    logic clk, rst;
    logic [7:0] audio_in;
    logic [3:0] volume;
    logic enable_volume;
    logic [7:0] audio_out;
    team_06_volume_shifter DUT(.clk(clk), .rst(rst), .audio_in(audio_in), .volume(volume), .enable_volume(enable_volume), .audio_out(audio_out));

    //clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        $dumpfile("team_06_volume_shifter.vcd");
        $dumpvars(0, team_06_volume_shifter_tb);
        rst = 1;
        #10

        enable_volume = 0;
        volume = 4'd6;
        rst = 0;
        audio_in = 8'd64;
        #50;
        enable_volume = 1;
        volume = 4'd6;
        audio_in = 8'd64;
        #50;
        volume = 4'd15;
        audio_in = 8'd255;
        #50;
        rst = 0;
        enable_volume = 1;
        #50;
        rst = 0;
        enable_volume = 0;
        #50;
        rst = 0;
        enable_volume = 1;
        #50;
        rst = 1;
        enable_volume = 1;
        #50;
        rst = 0;
        enable_volume = 1;
        #50;
        rst = 0;
        enable_volume = 1;
        volume = 4'd8;
        audio_in = 8'd0;
        #50;
        volume = 4'd15;
        #50;
        $finish;
    end

endmodule