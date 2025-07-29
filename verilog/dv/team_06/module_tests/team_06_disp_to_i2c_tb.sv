`timescale 1ms/10ps

module team_06_disp_to_i2c_tb;

    logic clk;
    logic rst;
    logic talkieState;
    logic [2:0] current_effect;
    logic [2:0] i2cState;
    logic commsError;
    logic ready;
    logic sda_i;
    logic sda_o;
    logic scl;
    logic oeb;
    logic [2:0] state;

team_06_disp_to_i2c KONODIODAKEDA (   
    .clk(clk),
    .rst(rst),
    .sda_i(sda_i),
    .talkieState(talkieState),
    .current_effect(current_effect),
    .sda_o(sda_o),
    .scl(scl),
    .oeb(oeb)
);


    initial clk = 0;
    always #0.5 clk = ~clk;

    // Stimulus
    initial begin
    //waveform dumping 
    $dumpfile ("team_06_disp_to_i2c.vcd");
    $dumpvars (0, team_06_disp_to_i2c_tb);

        rst = 1;
        talkieState = 0;
        current_effect = 3'b000;
        sda_i = 1;

        @(posedge clk);
       #100000
        rst = 0;
        talkieState = 1;
        current_effect = 3'b000;
        
       
        @(posedge clk);
        #100000
        rst = 0;
        talkieState = 1;
        current_effect = 3'b010;
        sda_i = 0;
       
        @(posedge clk);
        #100000
        rst = 0;
        talkieState = 1;
        current_effect = 3'b010;
        sda_i = 1;
       
        @(posedge clk);
        #100000
        rst = 1;
        talkieState = 0;
        current_effect = 3'b010;
       
        @(posedge clk);
        #100000
        rst = 0;
        talkieState = 1;
        current_effect = 3'b001;
       
        @(posedge clk);
        #1000000
        rst = 0;
        talkieState = 1;
        current_effect = 3'b000;

        @(posedge clk);
        #1000000
        
        #2;
        $finish;
    end


endmodule