`timescale 100ps / 1ps

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
    logic [31:0] wdati, wdato;
    logic wack;
    logic [31:0] wadr;
    logic [31:0] wdat;
    logic [3:0] wsel;
    logic wwe;
    logic wstb;
    logic wcyc;

    typedef enum int {PTT = 0, MUTE = 1, EFFECTCHANGE = 2, NOISEGATE = 3} button_t;

    // Testbench logics
    logic [7:0] misoVal;
    logic [7:0] micVal;
    int testcase;

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
        .i2sclk(i2sclk),
        .wdati(wdati),
        .wack(wack),
        .wadr(wadr),
        .wdat(wdat),
        .wsel(wsel),
        .wwe(wwe),
        .wstb(wstb),
        .wcyc(wcyc),
        .wdato(wdato)
    );

      sram_WB_Wrapper sram_wrapper(
      .wb_rst_i(reset),
      .wb_clk_i(hwclk),
      .wbs_stb_i(wstb),
      .wbs_cyc_i(wcyc),
      .wbs_we_i(wwe),
      .wbs_sel_i(wsel),
      .wbs_dat_i(wdato),
      .wbs_adr_i(wadr),
      .wbs_ack_o(wack),
      .wbs_dat_o(wdati)
  );

    initial hwclk = 0;
    always #0.5 hwclk = ~hwclk;

    // task toggleSerial ();
    //     begin
    //         repeat(32) @(posedge hwclk);
    //         adc_serial_in = 0;
    //         repeat(32) @(posedge hwclk);
    //         adc_serial_in = 1;
    //     end
    // endtask

    task increaseVolume ();
        begin
            repeat (8) @(posedge hwclk);
            vol = 1;
            repeat (8) @(posedge hwclk);
            vol = 3;
            repeat (8) @(posedge hwclk);
            vol = 2;
            repeat (8) @(posedge hwclk);
            vol = 0;
        end
    endtask

    task decreaseVolume ();
        begin
            repeat (8) @(posedge hwclk);
            vol = 2;
            repeat (8) @(posedge hwclk);
            vol = 3;
            repeat (8) @(posedge hwclk);
            vol = 1;
            repeat (8) @(posedge hwclk);
            vol = 0;
        end
    endtask

    task pressButton (int i);
        begin
            repeat (8) @(posedge hwclk);
            pbs[i] = ~pbs[i];
        end
    endtask

    task simVol (logic [7:0] i);
        logic [2:0] counter;
        logic temp;
        logic done;
        counter = 0;
        done = 0;
        if (reset) begin
            counter = 0;
        end else begin
            while(!reset && !done) begin
                @(posedge i2sclk, posedge reset);
                miso = i[7-counter];
                temp = miso;
                counter = counter + 1;
                if (counter == 0) begin
                    done = 1;
                end else begin
                    done = 0;
                end
            end
        end
    endtask

    task simMic (logic [7:0] i);
    
        logic [4:0] counter;
        logic done;
        logic flag;
        counter = 0;
        adc_serial_in = 0;
        if (reset) begin
            counter = 0;
        end else begin
            done = 0;
            while (!reset && !done) begin // Need to fix so it exists while loop after transmission
                if (counter < 8) begin
                    adc_serial_in = i[7-counter];
                    flag = 1;
                end else begin
                    adc_serial_in = 0;
                end
                counter = counter + 1;
                if (counter == 0) begin
                    done = 1;
                end else begin
                    done = 0;
                end
                @(negedge i2sclk, posedge reset);
            end
        end
    endtask

    // Mem file???

    always begin
        repeat (8) @(posedge hwclk);
        simVol(misoVal); // Choose your input volume
    end

    always begin
        repeat (8) @(posedge hwclk);
        simMic(micVal+128); // Choose your mic input
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

        repeat (6144) @(posedge hwclk);

        reset = 0;
        pbs = 0;
        vol = 0;
        cs = 1;

        repeat (8) @(posedge hwclk); 

        repeat(4) increaseVolume();

        repeat (6144) @(posedge hwclk);

        // Note: for misoVal, zero is 128 (because it is within our system and unsigned)
        // Wheras for mic val zero is actually zero as the mic val is signed, 128 is max, 255 is -1

        // Test case 1: zero volume mic, zero volume speaker, no buttons, full volume
        testcase = 1;
        micVal = 128;
        misoVal = 128;
        repeat (6144) @(posedge hwclk);

        // Test case 2: zero volume mic, full volume speaker, no buttons, full volume
        testcase = 2;
        micVal = 128;
        misoVal = 255;
        repeat (6144) @(posedge hwclk);

        // Test case 3: full volume mic, zero volume speaker, no buttons, full volume
        testcase = 3;
        micVal = 255;
        misoVal = 128;
        repeat (6144) @(posedge hwclk);

        // Test case 4: full volume mic, full volume speaker, no buttons, full volume
        testcase = 4;
        micVal = 255;
        misoVal = 255;
        repeat (6144) @(posedge hwclk);

        // Test case 5: mid operation reset
        testcase = 5;
        reset = 1;
        repeat (6144) @(posedge hwclk);
        reset = 0;

        // Test case 6: zero volume mic, zero volume speaker, PTT, full volume
        testcase = 6;
        micVal = 128;
        misoVal = 128;
        pressButton(PTT);
        repeat(4) increaseVolume();
        repeat (6144) @(posedge hwclk);

        // Test case 7: zero volume mic, full volume speaker, PTT, full volume
        testcase = 7;
        micVal = 128;
        misoVal = 255;
        repeat (6144) @(posedge hwclk);

        // Test case 8: full volume mic, zero volume speaker, PTT, full volume

        testcase = 8;
        micVal = 255;
        misoVal = 128;
        repeat (6144) @(posedge hwclk);

        // Test case 9: full volume mic, full volume speaker, PTT, full volume

        // SENO CHECK
        testcase = 9;
        micVal = 255;
        misoVal = 255;
        repeat (6144) @(posedge hwclk);
        pressButton(PTT);

        // Test case 10: zero volume mic, full volume speaker, noise gate, full volume

        testcase = 10;
        micVal = 128;
        misoVal = 255;
        repeat (2) pressButton(NOISEGATE);
        repeat (6144) @(posedge hwclk);

        // Test case 11: full volume mic, zero volume speaker, noise gate, full volume
        testcase = 11;
        micVal = 255;
        misoVal = 128;
        repeat (6144) @(posedge hwclk);

        // Test case 12: low volume mic, zero volume speaker, noise gate, full volume

        testcase = 12;
        micVal = 110;
        misoVal = 128;
        repeat (6144) @(posedge hwclk);
        repeat (2) pressButton(NOISEGATE);

        // Test case 13: zero volume mic, full volume speaker, mute, full volume
        testcase = 13;
        micVal = 128;
        misoVal = 255;
        repeat (2) pressButton(MUTE);
        pressButton(PTT);
        repeat (6144) @(posedge hwclk);

        // Test case 14: full volume mic, zero volume speaker, mute, full volume
        testcase = 14;
        micVal = 255;
        misoVal = 128;
        repeat (6144) @(posedge hwclk);
        

        // Test case 15: full volume mic, full volume speaker, mute, full volume
        testcase = 15;
        micVal = 255;
        misoVal = 255;
        repeat (6144) @(posedge hwclk);
        repeat (2) pressButton(MUTE);


        // Test case 16: no volume mic, full volume speaker, half volume
        testcase = 16;
        micVal = 128;
        misoVal = 255;
        repeat (2) decreaseVolume();
        repeat (6144) @(posedge hwclk);

        // Test case 17 no volume mic, full volume speaker, no volume
        testcase = 17;
        micVal = 128;
        misoVal = 255;
        repeat (2) decreaseVolume();
        repeat (6144) @(posedge hwclk);
        

        // Test case 18: full volume mic, zero volume speaker, tremelo, full volume
        testcase = 18;
        micVal = 255;
        misoVal = 128;
        repeat (4) increaseVolume();
        repeat (2) pressButton(EFFECTCHANGE);
        repeat (6144) @(posedge hwclk);

        // Test case 19: half volume mic, zero volume speaker, tremelo, full volume
        testcase = 19;
        micVal = 64;
        misoVal = 128;
        repeat (6144) @(posedge hwclk);

        // Test case 20: very low volume mic, zero volume speaker, tremelo, full volume
        testcase = 20;
        micVal = 140; // Check if this is the case
        misoVal = 128;
        repeat (6144) @(posedge hwclk);

        // Test case 21: full echo test with varying volume from mic
        testcase = 21;
        repeat (2) pressButton(EFFECTCHANGE);
        repeat (170000) begin micVal = 200; @(posedge hwclk); end
        repeat (170000) begin micVal = 250; @(posedge hwclk); end
        repeat (170000) begin micVal = 160; @(posedge hwclk); end
        repeat (170000) begin micVal = 210; @(posedge hwclk); end
        repeat (170000) begin micVal = 190; @(posedge hwclk); end
        repeat (170000) begin micVal = 180; @(posedge hwclk); end

        // Test case 22: mid operation reset
        testcase = 22;
        reset = 1;
        repeat (6144) @(posedge hwclk);
        reset = 0;

        // Test case 23: full reverb test with varying volume from mic
 
        // Test case 24: full volume mic, zero volume speaker, soft clipping, full volume
        testcase = 24;
        micVal = 255;
        misoVal = 128;
        repeat (6) pressButton(EFFECTCHANGE);
        repeat (6144) @(posedge hwclk);

        // Test case 25: high volume mic, zero volume speaker, soft clipping, full volume
        testcase = 25;
        micVal = 200;
        misoVal = 128;
        repeat (6144) @(posedge hwclk);

        // Test case 26: zero volume mic, zero volume speaker, soft clipping, full volume
        testcase = 26;
        micVal = 128;
        misoVal = 128;
        repeat (6144) @(posedge hwclk);

        // Test case 27: high opposite amp low volume mic, zero volume speaker, soft clipping, full volume
        testcase = 27;
        micVal = 60;
        misoVal = 128;
        repeat (6144) @(posedge hwclk);

        // Test case 28: full opposite amp low volume mic, zero volume speaker, soft clipping, full volume
        testcase = 28;
        micVal = 0;
        misoVal = 128;
        repeat (6144) @(posedge hwclk);

        // Test case 29: full volume mic, full volume speaker, PTT + noise gate
        testcase = 29;
        micVal = 140;
        misoVal = 128;
        repeat (2) pressButton(NOISEGATE);
        repeat (4) pressButton(EFFECTCHANGE);
        repeat (6144) @(posedge hwclk);

        // Test case 30: full volume mic, full volume speaker, PTT + mute
        testcase = 30;
        micVal = 110;
        misoVal = 128;
        repeat (2) pressButton(NOISEGATE);
        repeat (2) pressButton(MUTE);
        repeat (6144) @(posedge hwclk);

        // Test case 31: full volume mic, full volume speaker, noise gate + mute
        testcase = 31;
        micVal = 110;
        misoVal = 255;
        repeat (2) pressButton(NOISEGATE);
        pressButton(PTT);
        repeat (6144) @(posedge hwclk);

        // Test case 32: full volume mic, full volume speaker, no chip select
        testcase = 32;
        micVal = 255;
        misoVal = 128;
        cs = 0;
        repeat (6144) @(posedge hwclk);

        // Test case 33: max volume mic, zero volume speaker, tremelo, full volume, noise gate
        testcase = 33;
        micVal = 255; // Check if this is the case
        misoVal = 128;
        repeat (2) pressButton(MUTE);
        repeat (2) pressButton(EFFECTCHANGE);
        repeat (6144) @(posedge hwclk);


    $finish;
    end

endmodule