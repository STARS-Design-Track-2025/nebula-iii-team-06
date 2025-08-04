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

assign green = reset;

  

  team_06_top t06top (
    .hwclk(hwclk),
    .reset(pb[14]),
    .adc_serial_in(pb[0]),
    .pbs(pb[4:1]),
    .vol(pb[6:5]),
    .miso(pb[7]),
    .cs(pb[8]),
    .wsADC(pb[9]),
    .mosi(pb[10]),
    .dac_out(pb[11]),
    .i2sclk(pb[12]),
    .spiclk(pb[13]),
    .wdati(gpio_in[1]),
    .wack(gpio_in[2]),
    .wadr(gpio_out[3]),
    .wdat(gpio_out[4]),
    .wsel(gpio_out[5]),
    .wwe(gpio_out[6]),
    .wstb(gpio_out[7]),
    .wcyc(gpio_out[8])
  );

  
  // GPIOs
  // Don't forget to assign these to the ports above as needed
  logic [33:0] gpio_in, gpio_out, gpio_oeb;
  wire [31:0] ADR_O;
  wire [31:0] DAT_O;
  wire [3:0]  SEL_O;
  wire        WE_O;
  wire        STB_O;
  wire        CYC_O;
  wire [31:0] DAT_I;
  wire         ACK_I;

  wire wstb;
  wire wcyc;
  wire wwe;
  wire [3:0] wsel;
  wire [31:0] wdati;
  wire [31:0] wadr;
  wire wack;
  wire [31:0] wdato;
  

  // Team 06 Design Instance
  team_06 team_06_inst (
    .clk(hwclk),
    .nrst(~pb[19]),
    .en(1'b1),

    .gpio_in(gpio_in),
    .gpio_out(gpio_out),
    .gpio_oeb(gpio_oeb),  // don't really need it her since it is an output

    // Uncomment only if using LA
    // .la_data_in(),
    // .la_data_out(),
    // .la_oenb(),

    // Uncomment only if using WB Master Ports (i.e., CPU teams)
    // You could also instantiate RAM in this module for testing
    .ADR_O(ADR_O),
    .DAT_O(DAT_O),
    .SEL_O(SEL_O),
    .WE_O(WE_O),
    .STB_O(STB_O),
    .CYC_O(CYC_O),
    .ACK_I(ACK_I),
    .DAT_I(DAT_I)

  );
    // Add other I/O connections to WB bus here

// // Instantiate SRAM model
//   wishbone_manager wishbone_manager(
//   // User design
//   .nRST(!reset),
//   .CLK(hwclk),
//   .CPU_DAT_I(busAudioWrite),
//   .ADR_I(addressOut),
//   .SEL_I(select), // all 1s 
//   .WRITE_I(write),
//   .READ_I(readEdge),
//   .CPU_DAT_O(busAudioRead),
//   .BUSY_O(busySRAM),
//   // Wishbone interconnect inputs
//   .DAT_I(wdati),
//   .ACK_I(wack),
//   // Wishbone interconnect outputs
//   .ADR_O(wadr),
//   .DAT_O(wdato),
//   .SEL_O(wsel),
//   .WE_O(wwe),
//   .STB_O(wstb),
//   .CYC_O(wcyc)
//   );
 
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


endmodule
