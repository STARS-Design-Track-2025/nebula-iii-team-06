module team_06_audio_effect(
    input logic clk, rst,
    input logic [7:0] audio_in,
    input finished,
    input logic [2:0] sel,
    output logic [7:0] audio_out
);

    //tremelo port
    logic clkdiv;
    logic tremelo_en;
    logic [7:0] tremelo_out;
    team_06_tremelo_clkdiv clkdivider(.clk(clk), .rst(rst), .clkdiv(clkdiv));
    team_06_tremelo tremelo(.audio_in(audio_in), .clk(clk), .rst(rst), .en(tremelo_en), .audio_out(tremelo_out));

    //soft clipping ports
    logic soft_clip_en;
    logic [7:0] soft_out;
    team_06_soft_clipping soft_clip(.audio_in(audio_in), .soft_clip_en(soft_clip_en), .soft_out(soft_out));

    //echo & reverb ports
    logic echo_en;
    logic reverb_en;
    logic [7:0] out;
   logic [31:0] busAudioRead;    // Data read from SRAM
    logic [31:0] busAudioWrite;   // Data to write to SRAM
    logic [31:0] addressOut;      // SRAM address
    logic [3:0] select;           // SRAM byte select
    logic write;                  // SRAM write enable
    logic read;                   // SRAM read enable
    logic busySRAM;               // SRAM busy signal

    // Internal signals for module interconnection
    logic [12:0] offset;          // Offset for past audio sample
    logic record;                 // Search signal for readWrite module
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
        .reverb_en(reverb_en), //enable signal
        .past_output(past_output), //we get this from SRAM thru Read write module
        .offset(offset),// the offset is released to SRAM
        .out(out), // final output
        .save_audio(save_audio)
    );

    // Instantiate readWrite module
    team_06_readWrite readWrite (
        .clk(clk), // system' clock
        .rst(rst), // system's reset
        .busAudioRead(busAudioRead), // this is from SRAM
        .offset(offset), // this is from team_06_echo_effect module
        .effectAudioIn(save_audio), // sample coming in
        .search(1'b1), // this is from team_06_echo_effect module
        .record(record), //receives the record signal from  team_06_echo_effect module
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
            record <= 0;
        end else begin
            record <= finished;
        end
    end

    // SRAM interface stubs (to be connected to actual SRAM module)
    //assign busAudioRead = 32'hDEADBEEF;    // Placeholder: connect to actual SRAM read data


    logic [7:0] out_temp;
    assign audio_out = out_temp;



    always_comb begin
        // Default values
        reverb_en = 0;
        tremelo_en = 0;
        echo_en = 0;
        soft_clip_en = 0;
        out_temp = audio_in; // Default to no effect

        case (sel)
            3'b000: out_temp = audio_in; // No effect
            3'b001: begin
                tremelo_en = 1;
                out_temp = tremelo_out;
            end
            3'b010: begin
                echo_en = 1;
                out_temp = out;
            end
            3'b011: begin
                soft_clip_en = 1;
                out_temp = soft_out;
            end
            3'b100: begin reverb_en = 1; out_temp = out; end
            default: out_temp = audio_in; 
        endcase
    end

endmodule

