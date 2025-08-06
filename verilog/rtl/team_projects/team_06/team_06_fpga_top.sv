`default_nettype none

// FPGA top module for Team 06

module top (
// I/O ports
input logic hwclk, reset,
input logic [20:0] pb,
output logic [7:0] left, right,
ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
output logic red, green, blue,

// UART ports
output logic [7:0] txdata,
input logic [7:0] rxdata,
output logic txclk, rxclk,
input logic txready, rxready
);
  assign green = reset;
  assign gpio_in[8:0] = pb[8:0];
  assign gpio_out[20:9] = pb[20:9];
  
  // GPIOs
  // Don't forget to assign these to the ports above as needed
  logic [33:0] gpio_in, gpio_out, gpio_oeb;
  logic [31:0] ADR_O;
  logic [31:0] DAT_O;
  logic [3:0]  SEL_O;
  logic        WE_O;
  logic        STB_O;
  logic        CYC_O;
  logic [31:0] DAT_I;
  logic         ACK_I;
  

// Team 06 Design Instance
team_06 team_06_inst (
.clk(hwclk),
.nrst(~reset),
.en(1'b1),

.gpio_in(gpio_in),
.gpio_out(gpio_out),
.gpio_oeb(gpio_oeb), // don't really need it her since it is an output

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

sram_WB_Wrapper sram_wrapper(
.wb_rst_i(reset),
.wb_clk_i(hwclk),
.wbs_stb_i(STB_O),
.wbs_cyc_i(CYC_O),
.wbs_we_i(WE_O),
.wbs_sel_i(SEL_O),
.wbs_dat_i(DAT_O),
.wbs_adr_i(ADR_O),
.wbs_ack_o(ACK_I),
.wbs_dat_o(DAT_I)
);


endmodule



