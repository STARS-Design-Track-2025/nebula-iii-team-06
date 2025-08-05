// $Id: $
// File name:   team_06.sv
// Created:     
// Author:      
// Description: 

`default_nettype none

module team_06 (
    `ifdef USE_POWER_PINS
        inout vccd1,	// User area 1 1.8V supply
        inout vssd1,	// User area 1 digital ground
    `endif
    // HW
    input logic clk, nrst,
    
    input logic en, //This signal is an enable signal for your chip. Your design should disable if this is low.
    
    // Logic Analyzer - Grant access to all 128 LA
    // input logic [31:0] la_data_in,
    // output logic [31:0] la_data_out,
    // input logic [31:0] la_oenb,


    // Wishbone master interface
    output wire [31:0] ADR_O,
    output wire [31:0] DAT_O,
    output wire [3:0]  SEL_O,
    output wire        WE_O,
    output wire        STB_O,
    output wire        CYC_O,
    input wire [31:0]  DAT_I,
    input wire         ACK_I,

    // 34 out of 38 GPIOs (Note: if you need up to 38 GPIO, discuss with a TA)
    input  logic [33:0] gpio_in, // Breakout Board Pins
    output logic [33:0] gpio_out, // Breakout Board Pins
    output logic [33:0] gpio_oeb // Active Low Output Enable
    
    /*
    * Add other I/O ports that you wish to interface with the
    * Wishbone bus to the management core. For examples you can 
    * add registers that can be written to with the Wishbone bus
    */

    // You can also have input registers controlled by the Caravel Harness's on chip processor
);

    // Assign OEBs for inputs and outputs
    assign gpio_oeb[8:0] = '1;
    assign gpio_oeb[20:9] = '0;
    assign gpio_oeb[33:21] = '1;  // Unused pins are set as inputs

    // Unused outputs are set to 0
    assign gpio_out[33:21] = '0;

    team_06_top t06top (
    .hwclk(clk),
    .reset(~nrst | ~en),
    .adc_serial_in(gpio_in[0]),
    .pbs(gpio_in[4:1]),
    .vol(gpio_in[6:5]),
    .miso(gpio_in[7]),  // ESP pin 19 / B5
    .cs(gpio_in[8]), // ESP pin 5 / A5
    .wsADC(gpio_out[9]),
    .mosi(gpio_out[10]),  // ESP pin 23 / C6
    .dac_out(gpio_out[11]),
    .i2sclk(gpio_out[12]), // ESP pin 18 / C7
    .i2sclk_out_chip(gpio_out[13]),
    .spiclk(gpio_out[14]),
    .word_select(gpio_out[15]), 
    .wdati(DAT_I),
    .wack(ACK_I),
    .wadr(ADR_O),
    .wdato(DAT_O),
    .wsel(SEL_O),
    .wwe(WE_O),
    .wstb(STB_O),
    .wcyc(CYC_O),
    .doneDisplay(gpio_out[16]), 
    .sdoDisplay(gpio_out[17]), 
    .sclkDisplay(gpio_out[18]), 
    .cs_nDisplay(gpio_out[19]), 
    .busyDisplay(gpio_out[20])   
  );

endmodule