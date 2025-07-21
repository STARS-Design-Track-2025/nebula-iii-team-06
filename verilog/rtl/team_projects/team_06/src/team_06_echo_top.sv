module team_06_echo_top (
    input logic clk,            // System clock
    input logic rst,            // System reset
    input logic echo_en,        // Enable echo effect
    input logic finished, // Whether or not the SRAM is finished
    input logic [7:0] audio_in, // Input audio sample
    output logic [7:0] echo_out // Output audio with echo effect
);

    // Internal signals for SRAM interface
    logic [31:0] busAudioRead;    // Data read from SRAM
    logic [31:0] busAudioWrite;   // Data to write to SRAM
    logic [31:0] addressOut;      // SRAM address
    logic [3:0] select;           // SRAM byte select
    logic write;                  // SRAM write enable
    logic read;                   // SRAM read enable
    logic busySRAM;               // SRAM busy signal

    // Internal signals for module interconnection
    logic [12:0] offset;          // Offset for past audio sample
    logic search;                 // Search signal for readWrite module
    logic [7:0] past_output;      // Past audio sample from SRAM
    logic [7:0] save_audio;       // Audio to save to SRAM
    logic effect;                 // Effect mode signal


    // Add logic for finished, search, and record

    //Instantiate echo_effect module
    team_06_echo_and_reverb echo (
        .clk(clk), //system's clock
        .rst(rst), // system's reset
        .audio_in(audio_in), // sample coming in
        .echo_en(echo_en), //enable signal
        .reverb_en(!echo_en), //enable signal
        .past_output(past_output), //we get this from SRAM thru Read write module
        .offset(offset),// the offset is released to SRAM
        .echo_out(echo_out), // final output
        .save_audio(save_audio) ,// this is sent to SRAM to be stored for future use
    );

    // Instantiate readWrite module
    team_06_readWrite readWrite (
        .clk(clk), // system' clock
        .rst(rst), // system's reset
        .busAudioRead(busAudioRead), // this is from SRAM
        .offset(offset), // this is from team_06_echo_effect module
        .effectAudioIn(save_audio), // sample coming in
        .search(search), // this is from team_06_echo_effect module
        .record(1'b1), //receives the record signal from  team_06_echo_effect module
        .effect(effect), // This is needed so that when the effect changes, we stop reading from SRAM and wait till it has all been overwritten
        .busySRAM(busySRAM), // This comes from SRAM when it is not done reading or writing
        .busAudioWrite(busAudioWrite), // This is what you want to write to SRAM
        .addressOut(addressOut), // goes to SRAM, where we want to write in memory
        .audioOutput(past_output), // the audio output that goes to the audio effects module
        .select(select), // goes to SRAM, which bytes we want in the four byte word (we always want all of them for efficency)
        .write(write), 
        .read(read)
    );

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            search <= 0;
        end else begin
            search <= finished;
        end
    end

    // SRAM interface stubs (to be connected to actual SRAM module)
    assign busAudioRead = 32'hDEADBEEF;    // Placeholder: connect to actual SRAM read data

endmodule
