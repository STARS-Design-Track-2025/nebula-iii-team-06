`timescale 1ns / 1ps

module team_06_audio_effect_tb;

    // Indep. of RW
    // Inputs
    logic clk;
    logic rst;
    logic [7:0] audio_in;
    logic [2:0] sel;
    logic finished;
    // Outputs
    logic [7:0] audio_out;
    
    //audio_effect interacts with read write module
    logic [7:0] past_output; // What came from SRAM
    logic [12:0] offset;// For readwrite, where in memory
    logic search; // To R/W
    logic record; // To R/W
    logic [7:0] save_audio; // To SRAM
    
    //read write to sram
    logic [31:0] busAudioWrite;
    logic [31:0] addressOut;
    logic [3:0] select;
    logic write;
    logic readEdge;
    logic busySRAM;
    logic [31:0] busAudioRead;
    logic [7:0] effectAudioIn;

    //wishbone's stuff
    logic [31:0] wdati;
    logic wack;
    logic [31:0] wadr;
    logic [31:0] wdato;
    logic [3:0] wsel;
    logic wwe;
    logic wstb;
    logic wcyc;


    // Instantiate DUT
    team_06_audio_effect ae (.clk(clk), .rst(rst), .audio_in(audio_in), .finished(finished), .sel(sel), .audio_out(audio_out), 
        .past_output(past_output), .offset(offset), .search(search), .record(record), .save_audio(save_audio)); // ADD PORTS OR ELSE!
    
    team_06_readWrite sahur (
    .clk(clk),
    .rst(rst),
    .busAudioRead(busAudioRead),
    .offset(offset),
    .effectAudioIn(save_audio),
    .search(search),
    .record(record),
    .effect(sel),
    .busySRAM(busySRAM),
    .busAudioWrite(busAudioWrite),
    .addressOut(addressOut),
    .audioOutput(past_output),
    .select(select),
    .write(write),
    .readEdge(readEdge)
    );

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
    
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

task toggleFinished ();
    finished = 1;
    repeat(4) @(posedge clk);
    finished = 0;
    repeat(4) @(posedge clk);
endtask

initial begin
    $dumpfile("team_06_audio_effect.vcd");
    $dumpvars(0, team_06_audio_effect_tb);

    audio_in = 8'd64;
    finished = 1;
    sel = '0;
    //power on rst
    rst = 1;

    #300;
    //normal operation
    rst = 0;
    #100000;
    sel = 3'b001;
    #100000;
    sel = 3'b010;
    #100000;
    sel = 3'b011;
    #100000;
    sel = 3'b100;
    
    #10000000;
    repeat (1000) toggleFinished;
    #100
    //reset
    rst = 1;
    $finish;



end
    
endmodule