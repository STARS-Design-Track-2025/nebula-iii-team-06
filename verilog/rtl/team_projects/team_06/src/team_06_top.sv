  module team_06_top (
    input logic hwclk,
    input logic reset,
    input logic adc_serial_in,
    input logic [3:0] pbs,
    input logic [1:0] vol,
    input logic miso,
    input logic cs,
    output logic wsADC,
    output logic mosi,
    output logic dac_out,
    output logic i2sclk,
    output logic spiclk,
    // output logic busAudioWrite,
    //wishbone's stuff
    input logic [31:0] wdati,
    input logic wack,
    output logic [31:0] wadr,
    output logic [31:0] wdat,
    output logic [3:0] wsel,
    output logic wwe,
    output logic wstb,
    output logic wcyc,
    output logic [31:0] wdato
  );
  
  // ADC, i2sclk, edge_detection section
  logic past_i2sclk; 
  logic [7:0] i2s_parallel_out;
  logic finished; 

  team_06_i2sclkdivider div_i2sclk (.clk(hwclk), .rst(reset), // Inputs from top
  .i2sclk(i2sclk)); // Outputs

  team_06_edge_detection_i2s edgeDetector (.i2sclk(i2sclk), .clk(hwclk), .rst(reset), // Inputs from top
  .past_i2sclk(past_i2sclk)); // Input from i2sclkdivider

  team_06_adc_to_i2s adc (.clk(hwclk), .rst(reset), .adc_serial_in(adc_serial_in), // Inputs from top
  .i2sclk(i2sclk), .past_i2sclk(past_i2sclk), // Inputs from i2sclkdivider + edge_detection
  .i2s_parallel_out(i2s_parallel_out), .finished(finished), // Output to audio effects, misc.
  .ws(wsADC)); // Output to GPIO adc
  // NEED clock signal!!!

  logic [2:0] current_effect;

  // Between audio effect and readwrite
  logic [7:0] audio_effect_out;
  logic [7:0] past_output;
  logic [12:0] offset;
  logic search;
  logic record;
  logic [7:0] save_audio; 
  
  //read write to sram
  logic [31:0] busAudioWrite;
  logic [31:0] addressOut;
  logic [3:0] select;
  logic write;
  logic readEdge;
  logic busySRAM;
  logic [31:0] busAudioRead;
  logic [7:0] effectAudioIn;


  // Instantiate DUT
  team_06_audio_effect audio (.clk(hwclk), .rst(reset),  // Inputs from top
  .audio_in(i2s_parallel_out), .finished(finished), // Inputs from adc
  .sel(current_effect), // Input from FSM
  .past_output(past_output), // Input from readWrite
  .offset(offset), .search(search), .record(record), .save_audio(save_audio), // Output to readWrite
  .audio_out(audio_effect_out), .audio_enable(audio_enable)); // Output to SPI to ESP
    
  team_06_readWrite sramRW (
  .clk(hwclk), .rst(reset), // Inputs from top
  .effect(current_effect),  // Input from FSM
  .offset(offset), .effectAudioIn(save_audio), .search(search), .record(record), // Input from audio_effect
  .busAudioRead(busAudioRead), .busySRAM(busySRAM), // Input from manager
  .busAudioWrite(busAudioWrite), .addressOut(addressOut),   // Output to manager
  .select(select), .write(write), .readEdge(readEdge), // Output to manager
  .audioOutput(past_output) // Output to audio_effect
  );

  logic effect;
  logic mute;
  logic state;
  logic eff_en;
  logic vol_en;
  logic mute_tog;
  logic noise_gate_tog;
  logic audio_enable;

  // Instantiation of the FSM module
  team_06_FSM FSMmain(
  .clk(hwclk), .rst(reset), // Inputs from top
  .mic_aud(i2s_parallel_out), // Input from ADC
  .spk_aud(spi_parallel_out), // Input from ESP -> SPI
  .ng_en(noise_gate), .ptt_en(ptt),  .mute(mute), .effect(effect), // Input from synckey
  .state(state), .vol_en(vol_en), .current_effect(current_effect), .mute_tog(mute_tog), .effect_en(audio_enable) // Output from FSM
  );

  logic clk;
  logic rst;
  logic [3:0] volume;
  logic ptt;
  logic noise_gate;
 
  team_06_synckey buttons (
  .pbs(pbs), .clk(hwclk), .rst(reset), .vol(vol), // Inputs from top
  .volume(volume), .ptt(ptt), .noise_gate(noise_gate), .effect(effect), .mute(mute) // Outputs from snyckey
  );

  logic [7:0] parallel_in;
  logic past_spiclk;

  //Instantiation of the module
  team_06_spi_to_esp spiESP (
  .clk(hwclk), .rst(reset), // Inputs from top
  .parallel_in(audio_effect_out), // Input from audio effects
  .cs(cs), .serial_out(mosi) // Output to ESP32
  ); // clock signal!!

  logic [7:0] spi_parallel_out;
  logic done;

  //Instantiation of the module
  team_06_esp_to_spi espSPI (
    .clk(hwclk), .rst(reset), .esp_serial_in(miso), // Inputs from top
    .spiclk (i2sclk), .past_spiclk (past_i2sclk), // Input from i2sclk, edge detector 
    .spi_parallel_out(spi_parallel_out), .finished(done) // Output from esp to SPI
  );

  logic [7:0] audio_to_I2S;
  logic en;

  team_06_volume_shifter volumeShifter (
  .clk(hwclk), .rst(reset), // Inputs from top
  .audio_in(spi_parallel_out), // Input from esp to SPI
  .volume(volume), // Input from synckey
  .enable_volume(!mute_tog), // Input from FSM
  .audio_out(audio_to_I2S), .en(en) // Output to i2c
  );

  team_06_i2s_to_dac i2sDAC (
  .clk(hwclk), .rst(reset), // Inputs from top
  .i2sclk (i2sclk), .past_i2sclk (past_i2sclk), // Input from i2sclk, edge detector 
  .parallel_in(audio_to_I2S), .en(en), // Input from volume shifter
  .serial_out(dac_out)); // Output to DAC
  // NEED ws + clock signal!!!

  // // Instantiate SRAM model
  wishbone_manager wishbone_manager(
  // User design
  .nRST(!reset),
  .CLK(hwclk),
  .CPU_DAT_I(busAudioWrite),
  .ADR_I(addressOut),
  .SEL_I(select), // all 1s 
  .WRITE_I(write),
  .READ_I(readEdge),
  .CPU_DAT_O(busAudioRead),
  .BUSY_O(busySRAM),
  // Wishbone interconnect inputs
  .DAT_I(wdati),
  .ACK_I(wack),
  // Wishbone interconnect outputs
  .ADR_O(wadr),
  .DAT_O(wdato),
  .SEL_O(wsel),
  .WE_O(wwe),
  .STB_O(wstb),
  .CYC_O(wcyc)
  );
 
  // sram_WB_Wrapper sram_wrapper(
  //     .wb_rst_i(reset),
  //     .wb_clk_i(hwclk),
  //     .wbs_stb_i(wstb),
  //     .wbs_cyc_i(wcyc),
  //     .wbs_we_i(wwe),
  //     .wbs_sel_i(wsel),
  //     .wbs_dat_i(wdato),
  //     .wbs_adr_i(wadr),
  //     .wbs_ack_o(wack),
  //     .wbs_dat_o(wdati)
  // );
// input logic [31:0] wdati,
//     input logic wack,
//     output logic [31:0] wadr,
//     output logic [31:0] wdat,
//     output logic [3:0] wsel,
//     output logic wwe,
//     output logic wstb,
//     output logic wcyc
endmodule