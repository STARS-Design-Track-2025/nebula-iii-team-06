`timescale 1ns / 1ps

module tb_team_06_audio_effect;
    // Inputs
    logic clk;
    logic rst;
    logic [7:0] audio_in;
    logic [2:0] sel;
    // Outputs
    logic [7:0] audio_out;
    logic [31:0] busAudioWrite;
    logic [31:0] addressOut;
    logic [3:0] select;
    logic write;
    logic read;
    logic busySRAM;
    logic [31:0] busAudioRead;

    // Instantiate DUT
    team_06_audio_effect ae (
        .clk(clk),
        .rst(rst),
        .audio_in(audio_in),
        .sel(sel),
        .busAudioRead(busAudioRead),
        .audio_out(audio_out),
        .busAudioWrite(busAudioWrite),
        .addressOut(addressOut),
        .select(select),
        .write(write),
        .read(read),
        .busySRAM(busySRAM)
    );

    // Instantiate SRAM model
    team_06_sram_sim sram (
        .clk(clk),
        .rst(rst),
        .address(addressOut),
        .write_data(busAudioWrite),
        .write_en(write),
        .read_en(read),
        .byte_select(select),
        .read_data(busAudioRead),
        .busy(busySRAM)
    );

    // Clock generation: 25 MHz (40 ns period)
    initial begin
        clk = 0;
        forever #20 clk = ~clk; // 20 ns half-period
    end

    // Test stimulus
    initial begin
        $dumpfile("team_06_audio_effect.vcd");
        $dumpvars(0, tb_team_06_audio_effect);

        // Initialize
        rst = 1;
        audio_in = 8'd128;
        sel = 3'b000;
        #200; // Reset for 5 clock cycles

        // Release reset
        rst = 0;
        #200;

        // Generate 1 kHz sine wave for non-SRAM effects (48 kHz sampling rate)
        fork
            forever begin
                for (int i = 0; i < 360; i = i + 7.5) begin // 360/7.5 = 48 steps per 1 kHz cycle
                    audio_in = 128 + $rtoi(64 * $sin(2 * 3.14159 * i / 360));
                    #20833; // 20.83 µs per sample (48 kHz)
                end
            end
        join_none

        // Test no effect
        sel = 3'b000;
        #50000; // 50 ms

        // Test tremolo (50 Hz)
        sel = 3'b001;
        #50000; // 50 ms (2.5 cycles at 50 Hz)

        // Test echo with random samples
        sel = 3'b010;
        repeat (24000) begin // 500 ms at 48 kHz
            audio_in = $urandom_range(0, 255); // Random 8-bit value
            #2083; // 20.83 µs per sample
        end

        // Test soft clipping
        sel = 3'b011;
        #50000; // 50 ms

        // Test reverb with random samples
        sel = 3'b100;
        repeat (2400) begin // 500 ms at 48 kHz
            audio_in = $urandom_range(0, 255); // Random 8-bit value
            #2083; // 20.83 µs per sample
        end

        $finish;
    end
endmodule