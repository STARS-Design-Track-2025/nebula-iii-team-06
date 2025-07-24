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

    end
endmodule