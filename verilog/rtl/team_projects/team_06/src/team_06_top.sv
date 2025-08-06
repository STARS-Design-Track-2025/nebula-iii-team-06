module team_06_top (
    input logic hwclk,
    input logic reset,
    input logic adc_serial_in,
    input logic [3:0] pbs,
    input logic [1:0] vol,
    input logic miso,
    output logic cs,
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
    output logic [3:0] wsel,
    output logic wwe,
    output logic wstb,
    output logic wcyc,
    output logic [31:0] wdato,
    output logic i2sclk_out_chip,
    output logic word_select,
    output logic sdoDisplay,   // Serial data out (MOSI)
    output logic sclkDisplay,  // SPI clock
    output logic cs_nDisplay  // Chip select (active low)
  );
  
  // ADC, i2sclk, edge_detection section
  logic past_i2sclk; 
  logic [7:0] i2s_parallel_out;
  logic finished; 
  logic [11:0] offset = 4088; // Cannot be less than 4 or more than 4088

  team_06_clkdivider #(.COUNT(7), .WIDTH(3)) div_i2sclk (.clk(hwclk), .rst(reset), // Inputs from top
  .clkOut(i2sclk), .past_clkOut(past_i2sclk)); // Outputs

  team_06_adc_to_i2s adc (.clk(hwclk), .rst(reset), .adc_serial_in(adc_serial_in), // Inputs from top
  .i2sclk(i2sclk), .past_i2sclk(past_i2sclk), // Inputs from i2sclkdivider + edge_detection
  .i2s_parallel_out(i2s_parallel_out), .finished(finished), // Output to audio effects, misc.
  .ws(wsADC)); // Output to GPIO adc
  // NEED clock signal!!!

  logic [2:0] current_effect;

  // Between audio effect and readwrite
  logic [7:0] audio_effect_out;
  logic [7:0] past_output;
  logic search;
  logic record;
  logic [7:0] save_audio; 
  logic goodData;
  
  //read write to sram
  logic [31:0] busAudioWrite;
  logic [31:0] addressOut;
  logic [3:0] select;
  logic write;
  logic readEdge;
  logic busySRAM;
  logic [31:0] busAudioRead;

  // Instantiate DUT
  team_06_audio_effect audio (.clk(hwclk), .rst(reset),  // Inputs from top
  .audio_in(i2s_parallel_out), .finished(finished), // Inputs from adc
  .sel(current_effect), // Input from FSM
  .past_output(past_output), // Input from readWrite
  .search(search), .record(record), .save_audio(save_audio), // Output to readWrite
  .audio_out(audio_effect_out), .audio_enable(audio_enable), .goodData(goodData)); // Output to SPI to ESP
    
  team_06_readWrite sramRW (
  .clk(hwclk), .rst(reset), // Inputs from top
  .effect(current_effect),  // Input from FSM
  .offset(offset), .effectAudioIn(save_audio), .search(search), .record(record), // Input from audio_effect
  .busAudioRead(busAudioRead), .busySRAM(busySRAM), // Input from manager
  .busAudioWrite(busAudioWrite), .addressOut(addressOut),   // Output to manager
  .select(select), .write(write), .readEdge(readEdge), // Output to manager
  .audioOutput(past_output), .goodData(goodData) // Output to audio_effect
  );

  logic effect;
  logic mute;
  logic state; // Eventually used for display
  logic vol_en;
  logic audio_enable;

  // Instantiation of the FSM module
  team_06_FSM FSMmain(
  .clk(hwclk), .rst(reset), // Inputs from top
  .mic_aud(i2s_parallel_out), // Input from ADC
  .spk_aud(spi_parallel_out), // Input from ESP -> SPI
  .ng_en(noise_gate), .ptt_en(ptt),  .mute(mute), .effect(effect), // Input from synckey
  .state(state), 
  .vol_en(vol_en), .current_effect(current_effect), .effect_en(audio_enable) // Output from FSM
  );

  logic [127:0] row_1, row_2;
  logic [9:0] out;
  logic out_valid;
  logic busyDisplay;  // Transmission in progress
  logic doneDisplay;   // Transmission complete (pulse)

  team_06_newDisplay Display(
    .talkieState(state), .enable_volume(!mute), .current_effect(current_effect), // Inputs from FSM
    .volume(volume), // Input from synckey
    .row_1(row_1), .row_2(row_2)
  );

  team_06_driver_1602 #(.clk_div(24_000)) drive(
    .clk(hwclk), .rst(!reset), // Inputs from top
    .row_1(row_1), .row_2(row_2), // Inputs from newDisplay
    .out(out), .out_valid(out_valid)
  );

  team_06_1602_spi #( .WIDTH(10), .CLK_DIV(40) ) spiDisplay(
    .clk(hwclk), .rst_n(!reset),      
    .start(out_valid), .data_in(out), // Inputs from driver
    .done(doneDisplay), // Outputs to driver
    .sdo(sdoDisplay), .sclk(sclkDisplay), .cs_n(cs_nDisplay), .busy(busyDisplay)   // Outputs to chip   
  );

  logic [3:0] volume;
  logic ptt;
  logic noise_gate;
 
  team_06_synckey buttons (
  .pbs(pbs), .clk(hwclk), .rst(reset), .vol(vol), // Inputs from top
  .volume(volume), .ptt(ptt), .noise_gate(noise_gate), .effect(effect), .mute(mute) // Outputs from snyckey
  );

  logic past_spiclk;

  team_06_clkdivider #(.COUNT(24), .WIDTH(5)) spi_clock (.clk(hwclk), .rst(reset), // Inputs from top
  .clkOut(spiclk), .past_clkOut(past_spiclk)); // Outputs

  //Instantiation of the module
  team_06_spi_to_esp spiESP (
  .clk(hwclk), .rst(reset), // Inputs from top
  .parallel_in(audio_effect_out), // Input from audio effects
  .cs(cs), .serial_out(mosi) // Output to ESP32
  ); // clock signal!!

  logic [7:0] spi_parallel_out;
  logic done; // Need to add logic 

  //Instantiation of the module
  team_06_esp_to_spi espSPI (
    .clk(hwclk), .rst(reset), .esp_serial_in(miso), // Inputs from top
    .spiclk (i2sclk), .past_spiclk (past_i2sclk), // Input from i2sclk, edge detector 
    .spi_parallel_out(spi_parallel_out), .finished(done) // Output from esp to SPI
  );

  logic [7:0] audio_to_I2S;
  logic en;

  logic i2sclk_out;
  logic past_i2sclk_out;
  logic past_i2sclk_out_chip;

  team_06_clkdivider #(.COUNT(7), .WIDTH(3)) div_i2sclk_out (.clk(hwclk), .rst(reset), // Inputs from top
  .clkOut(i2sclk_out), .past_clkOut(past_i2sclk_out)); // Outputs
  assign i2sclk_out_chip = i2sclk_out && en; // This is so that when we disable, we put the chip in standby mode
  assign past_i2sclk_out_chip = past_i2sclk_out && en;

  team_06_volume_shifter volumeShifter (
  .clk(hwclk), .rst(reset), // Inputs from top
  .audio_in(spi_parallel_out), // Input from esp to SPI
  .volume(volume), // Input from synckey
  .enable_volume(vol_en), // Input from FSM
  .audio_out(audio_to_I2S), .en(en) // Output to i2c
  );

  team_06_i2s_to_dac i2sDAC (
  .clk(hwclk), .rst(reset), // Inputs from top
  .i2sclk (i2sclk_out_chip), .past_i2sclk (past_i2sclk_out_chip), // Input from i2sclk, edge detector 
  .parallel_in(audio_to_I2S), // Input from volume shifter
  .serial_out(dac_out), .word_select(word_select)); // Output to DAC


  // NEED ws + clock signal!!!

  // // // Instantiate SRAM model
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

endmodule