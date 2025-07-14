module team_06_tremelo_tb;
    input logic clkdiv, rst;  //put all the port ont this module
    input logic [7:0] audio_in;
    input logic enable;
    output logic [7:0] audio_out;


    //instantiate the DUT
    tremelo DUT(.clkdiv(clkdiv), .rst(rst), .audio_in(audio_in), .enable(enable), .audio_out(audio_out));


    //clock generation
    initial begin
        clkdiv = 0;
        forever #10 clk = ~clk // every 10 unit, it toggles
    end

    //stimulus begin
    initial begin

        $dumpfile("tremelo.vcd");
        $dumpvars(0, tremelo_tb);
        audio_in = 8d'100;
        rst = 1;
        enable = 0;

        #25;// we set 25 so rst changes in between rising edge and falling edge. this is to prevent race condition
        rst = 0;
        enable = 1;

        repeat (360) @(posedge clkdiv);

    end
endmodule