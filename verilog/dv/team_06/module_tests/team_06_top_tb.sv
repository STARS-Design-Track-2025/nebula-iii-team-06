module team_06_top_tb;
    logic hwclk;
    logic reset;
    logic adc_serial_in;
    logic [3:0] pbs;
    logic [1:0] vol;
    logic miso;
    logic wsADC;
    logic cs;
    logic mosi;
    logic dac_out;

    typedef enum int {PTT = 0, MUTE = 1, EFFECTCHANGE = 2, NOISEGATE = 3} button_t;

    //Instantiation of the top module 
    team_06_top toptime (
        .hwclk(hwclk),
        .reset(reset),
        .adc_serial_in(adc_serial_in),
        .pbs(pbs),
        .vol(vol),
        .miso(miso),
        .wsADC(wsADC),
        .cs(cs),
        .mosi(mosi),
        .dac_out(dac_out)
    );

    initial hwclk = 0;
    always #0.5 hwclk = ~hwclk;

    task toggleSerial ();
        begin
            repeat(32) @(posedge hwclk)
            adc_serial_in = 0;
            repeat(32) @(posedge hwclk)
            adc_serial_in = 1;
        end
    endtask

    task increaseVolume ();
        begin
            repeat (10) @(posedge hwclk)
            vol = 1;
            repeat (10) @(posedge hwclk)
            vol = 3;
            repeat (10) @(posedge hwclk)
            vol = 2;
            repeat (10) @(posedge hwclk)
            vol = 0;
        end
    endtask

    task pressButton (int i);
        begin
            pbs[i] = ~pbs[i];
        end
    endtask

    // Mem file???

    initial begin
        //waveform dumping 
        $dumpfile ("team_06_top.vcd");
        $dumpvars (0, team_06_top_tb);

        reset = 1;

        @(posedge hwclk);

        reset = 0;
        pbs = 0;
        vol = 0;
        miso = 1;
        cs = 1;
        adc_serial_in = 1;

        repeat(4) increaseVolume();

        repeat (100) toggleSerial();

        pressButton(NOISEGATE);

        repeat (100) toggleSerial();

    $finish;
    end

endmodule

