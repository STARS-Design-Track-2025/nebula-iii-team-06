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
    assign gpio_oeb[7:0] = '1;
    assign gpio_oeb[18:8] = '0;
    assign gpio_oeb[33:19] = '1;  // Unused pins are set as inputs

    // Unused outputs are set to 0
    assign gpio_out[33:19] = '0;

    team_06_top t06top (
    .hwclk(clk),
    .reset(~nrst | ~en),
    .adc_serial_in(gpio_in[0]), // C3 - ADC serial input - goes to serial data
    .pbs(gpio_in[4:1]), // 1 - B3 (PTT), 2 - C4 (Mute), 3 - C5 (effect), 4 - A1 (noise gate)
    .vol(gpio_in[6:5]), // 5 - A2, 6 - B4, 
    .miso(gpio_in[7]),  //  B5 - ESP pin 19 - MISO
    .cs(gpio_out[8]), //  B2 - ESP pin 5 - CS
    .wsADC(gpio_out[9]), // D1 - ADC word select
    .mosi(gpio_out[10]),  // H1 - ESP pin 23 - MOSI  
    .dac_out(gpio_out[11]), // K1 - DAC DIN
    .i2sclk(gpio_out[12]), // M2 - ADC I2s clock
    .i2sclk_out_chip(gpio_out[13]), // R1 - DAC I2s clock
    .spiclk(gpio_out[14]), // T13 - ESP pin 18 - SPI clock
    .word_select(gpio_out[15]), // P10 - DAC LRclk 
    .wdati(DAT_I),
    .wack(ACK_I),
    .wadr(ADR_O),
    .wdato(DAT_O),
    .wsel(SEL_O),
    .wwe(WE_O),
    .wstb(STB_O),
    .wcyc(CYC_O),
    .sdoDisplay(gpio_out[16]), // R5 - Pin 14
    .sclkDisplay(gpio_out[17]), // R2 - Pin 12
    .cs_nDisplay(gpio_out[18]) // P15 - Pin 16  
    );

endmodule