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
    logic i2sclk;

    typedef enum int {PTT = 0, MUTE = 1, EFFECTCHANGE = 2, NOISEGATE = 3} button_t;

    // Testbench logics
    logic [7:0] misoVal;
    logic [7:0] micVal;

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
        .dac_out(dac_out),
        .i2sclk(i2sclk)
    );

    initial hwclk = 0;
    always #0.5 hwclk = ~hwclk;

    // task toggleSerial ();
    //     begin
    //         repeat(32) @(posedge hwclk)
    //         adc_serial_in = 0;
    //         repeat(32) @(posedge hwclk)
    //         adc_serial_in = 1;
    //     end
    // endtask

    task increaseVolume ();
        begin
            repeat (8) @(posedge hwclk)
            vol = 1;
            repeat (8) @(posedge hwclk)
            vol = 3;
            repeat (8) @(posedge hwclk)
            vol = 2;
            repeat (8) @(posedge hwclk)
            vol = 0;
        end
    endtask

    task decreaseVolume ();
        begin
            repeat (8) @(posedge hwclk)
            vol = 2;
            repeat (8) @(posedge hwclk)
            vol = 3;
            repeat (8) @(posedge hwclk)
            vol = 1;
            repeat (8) @(posedge hwclk)
            vol = 0;
        end
    endtask

    task pressButton (int i);
        begin
            pbs[i] = ~pbs[i];
        end
    endtask

    task simVol (logic [7:0] i);
        logic [2:0] counter;
        logic temp;
        counter = 0;
        repeat (8) begin
            repeat(48) @(posedge hwclk);
            miso = i[7-counter];
            temp = miso;
            counter = counter + 1;
        end
    endtask

    task simMic (logic [7:0] i);
        logic [4:0] counter;
        logic temp;
        counter = 0;
        adc_serial_in = 0;
        repeat (32) begin
            if (counter > 1 && counter < 10) begin
                adc_serial_in = i[9-counter];
                temp = adc_serial_in;
                counter = counter + 1;
            end else begin
                adc_serial_in = 0;
                temp = 0;
                counter = counter + 1;
            end
            @(posedge i2sclk);
        end
        adc_serial_in = 0;
    endtask

    // Mem file???

    always begin
        #1;
        simVol(misoVal); // Choose your input volume
    end

    always begin
        #1;
        simMic(micVal); // Choose your mic input
    end
    // BEN SISKKKK, YOU HAVE TO CALL THESE TWO FUNCTIONS IN INITIAL BEGIN

    initial begin
        //waveform dumping 
        $dumpfile ("team_06_top.vcd");
        $dumpvars (0, team_06_top_tb);

        // pressButton(NOISEGATE);
        // misoVal = 255;
        // repeat (128) toggleSerial();
        // misoVal = 0;
        // repeat (128) @(posedge hwclk);
        
        reset = 1;
        misoVal = 8'd0;
        micVal = 8'd0;

        repeat (8) @(posedge hwclk);

        reset = 0;
        pbs = 0;
        vol = 0;
        cs = 1;

        repeat (8) @(posedge hwclk);

        repeat(4) increaseVolume();

        repeat (2048) @(posedge hwclk);

        // Test case 1: zero volume mic, zero volume speaker, no buttons, full volume

        misoVal = 0;
        micVal = 0;
        repeat (2048) @(posedge hwclk);
        // Test case 2: zero volume mic, full volume speaker, no buttons, full volume

        misoVal = 146;
        micVal = 0;
        repeat (2048) @(posedge hwclk);

        // Test case 3: full volume mic, zero volume speaker, no buttons, full volume

        // Test case 4: full volume mic, full volume speaker, no buttons, full volume

        // Test case 5: mid operation reset

        // Test case 6: zero volume mic, full volume speaker, PTT, full volume

        // Test case 8: full volume mic, zero volume speaker, PTT, full volume

        // Test case 9: full volume mic, full volume speaker, PTT, full volume

        // Test case 6: zero volume mic, full volume speaker, noise gate, full volume

        // Test case 8: full volume mic, zero volume speaker, noise gate, full volume

        // Test case 9: low volume mic, full volume speaker, noise gate, full volume

        // Test case 10: zero volume mic, full volume speaker, mute, full volume

        // Test case 11: full volume mic, zero volume speaker, mute, full volume

        // Test case 12: full volume mic, full volume speaker, mute, full volume

        // Test case 13: full volume mic, full volume speaker, half volume

        // Test case 14: full volume mic, full volume speaker, no volume

        // Test case 15: full volume mic, zero volume speaker, tremelo, full volume

        // Test case 16: half volume mic, zero volume speaker, tremelo, full volume

        // Test case 17: very low volume mic, zero volume speaker, tremelo, full volume

        // Test case 18: full echo test with varying volume from mic

        // Test case 19: mid operation reset

        // Test case 20: full echo test with varying volume from mic

        // Test case 21: full volume mic, zero volume speaker, soft clipping, full volume

        // Test case 22: high volume mic, zero volume speaker, soft clipping, full volume

        // Test case 23: zero volume mic, zero volume speaker, soft clipping, full volume

        // Test case 24: high opposite amp low volume mic, zero volume speaker, soft clipping, full volume

        // Test case 25: full opposite amp low volume mic, zero volume speaker, soft clipping, full volume

        // Test case 26: full reverb test with varying volume from mic

        // Test case 27: mid operation reset

        // Test case 28: full reverb test with varying volume from mic

        // Test case 29: full volume mic, full volume speaker, PTT + noise gate

        // Test case 30: full volume mic, full volume speaker, PTT + mute

        // Test case 31: full volume mic, full volume speaker, noise gate + mute

        // Test case 32: full volume mic, full volume speaker, no chip select

    $finish;
    end

endmodule

