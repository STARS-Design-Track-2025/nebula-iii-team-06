`default_nettype none

// FPGA top module for Team 06

module top (
  // I/O ports
  input  logic hwclk, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  // GPIOs
  // Don't forget to assign these to the ports above as needed
  logic [33:0] gpio_in, gpio_out;
  

  // Team 06 Design Instance
  team_06 team_06_inst (
    .clk(hwclk),
    .nrst(~reset),
    .en(1'b1),

    .gpio_in(gpio_in),
    .gpio_out(gpio_out),
    .gpio_oeb()  // don't really need it her since it is an output

    // Uncomment only if using LA
    // .la_data_in(),
    // .la_data_out(),
    // .la_oenb(),

    // Uncomment only if using WB Master Ports (i.e., CPU teams)
    // You could also instantiate RAM in this module for testing
    // .ADR_O(ADR_O),
    // .DAT_O(DAT_O),
    // .SEL_O(SEL_O),
    // .WE_O(WE_O),
    // .STB_O(STB_O),
    // .CYC_O(CYC_O),
    // .ACK_I(ACK_I),
    // .DAT_I(DAT_I),

    // Add other I/O connections to WB bus here
  );

    // ADC, i2sclk, edge_detection section
    logic i2sclk, past_i2sclk; 
    logic adc_serial_in;
    logic [7:0] i2s_parallel_out;
    logic finished; 
    logic ws;

    // assign adc_serial_in = GPIO pin
    // assign ws = GPIO pin

    team_06_i2sclkdivider div_i2sclk (.clk(hwclk), .rst(reset), // Inputs from top
    .i2sclk(i2sclk)); // Outputs

    team_06_edge_detection_i2s edgeDetector (.i2sclk(i2sclk), .clk(hwclk), .rst(reset), // Inputs from top
    .past_i2sclk(past_i2sclk)); // Input from i2sclkdivider

    team_06_adc_to_i2s adc (.clk(hwclk), .rst(reset), .adc_serial_in(adc_serial_in), // Inputs from top
    .i2sclk(i2sclk), .past_i2sclk(past_i2sclk), // Inputs from i2sclkdivider + edge_detection
    .i2s_parallel_out(i2s_parallel_out), .finished(finished), // Output to audio effects, misc.
    .ws(ws)); // Output to GPIO adc

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
    team_06_audio_effect ae (.clk(hwclk), .rst(reset),  // Inputs from top
    .audio_in(i2s_parallel_out), .finished(finished), // Inputs from adc
    .sel(current_effect), // Input from FSM
    .past_output(past_output), // Input from readWrite
    .offset(offset), .search(search), .record(record), .save_audio(save_audio), // Output to readWrite
    .audio_out(audio_effect_out)); // Output to SPI to ESP
    
    team_06_readWrite sahur (
    .clk(hwclk), .rst(reset), // Inputs from top
    .effect(current_effect),  // Input from FSM
    .offset(offset), .effectAudioIn(save_audio), .search(search), .record(record), // Input from audio_effect
    .busAudioRead(busAudioRead), .busySRAM(busySRAM), // Input from manager
    .busAudioWrite(busAudioWrite), .addressOut(addressOut),   // Output to manager
    .select(select), .write(write), .readEdge(readEdge), // Output to manager
    .audioOutput(past_output) // Output to audio_effect
    );

    logic [7:0] spk_aud;
    logic ng_en;
    logic ptt_en;
    logic effect;
    logic mute;
    logic state;
    logic eff_en;
    logic vol_en;
    logic mute_tog;
    logic noise_gate_tog;

    // Instantiation of the FSM module
    team_06_FSM trung_trung (
    .clk(hwclk), .rst(reset), // Inputs from top
    .mic_aud(i2s_parallel_out), // Input from ADC
    .spk_aud(spk_aud), // Input from ESP -> SPI
    .ng_en(ng_en), .ptt_en(ptt_en), .vol_en(vol_en),     .eff_en(eff_en),// Input from synckey
    .state(state), 
     .effect(effect),
     .mute(mute), 
    .current_effect(current_effect),
    .mute_tog(mute_tog),
    .noise_gate_tog(noise_gate_tog)
    );




    //wishbone's stuff
    logic [31:0] wdati;
    logic wack;
    logic [31:0] wadr;
    logic [31:0] wdato;
    logic [3:0] wsel;
    logic wwe;
    logic wstb;
    logic wcyc;
    // Instantiate SRAM model
    wishbone_manager wishbone_manager(
    // User design
    .nRST(!rst),
    .CLK(clk),
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

sram_WB_Wrapper sram_wrapper(
    .wb_rst_i(rst),
    .wb_clk_i(clk),
    .wbs_stb_i(wstb),
    .wbs_cyc_i(wcyc),
    .wbs_we_i(wwe),
    .wbs_sel_i(wsel),
    .wbs_dat_i(wdato),
    .wbs_adr_i(wadr),
    .wbs_ack_o(wack),
    .wbs_dat_o(wdati)
);

endmodule
