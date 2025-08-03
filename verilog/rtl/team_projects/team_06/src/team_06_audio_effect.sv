module team_06_audio_effect (
    input logic clk, rst,
    input logic [7:0] audio_in, // From i2s to audio effects
    input logic finished, // from i2s
    input logic [2:0] sel, // from fsm
    input logic audio_enable,
    input logic goodData, // Whehter or not we are ready to read from memory
    output logic [7:0] audio_out, // What goes to SPI
    //ports interacts read write SRAM for echo and reverb
    input logic [7:0] past_output, // What came from SRAM
    output logic search, // To R/W
    output logic record, // To R/W
    output logic [7:0] save_audio // To SRAM
);

    //tremelo port
    logic clkdiv;
    logic tremelo_en;
    logic [7:0] tremelo_out;
    team_06_tremelo tremelo(.audio_in(audio_in), .clk(clk), .rst(rst), .en(tremelo_en), .audio_out(tremelo_out));

    //soft clipping ports
    logic soft_clip_en;
    logic [7:0] soft_out;
    team_06_soft_clipping soft_clip(.audio_in(audio_in), .soft_clip_en(soft_clip_en), .soft_out(soft_out));

    //echo & reverb ports
    logic echo_en;
    logic reverb_en;
    logic record_n;
    logic [7:0] echo_reverb_out;

    // Add logic for finished, search, and record

    //Instantiate echo_effect module
    team_06_echo_and_reverb echo (
        .clk(clk), //system's clock
        .rst(rst), // system's reset
        .audio_in(audio_in), // sample coming in
        .echo_en(echo_en), //enable signal
        .reverb_en(reverb_en), //enable signal
        .past_output(past_output), //we get this from SRAM thru Read write module
        .echo_reverb_out(echo_reverb_out), // final output
        .save_audio(save_audio), // What goes to SRAM
        .goodData(goodData) // Whehter or not we are ready to read from memory
    );

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            record <= 0;
        end else begin
            record <= record_n;
        end
    end

    always_comb begin
        if( (echo_en ^ reverb_en) && finished) begin // If just echo or just reverb is on and we have recieved new data, record should be on
            record_n = 1;
        end else begin
            record_n = 0;
        end
    end

    always_comb begin
        // Default values
        reverb_en = 0;
        tremelo_en = 0;
        echo_en = 0;
        soft_clip_en = 0;
        audio_out = audio_in; // Default to no effect
        search = 0;

        if (audio_enable) begin
            case (sel)
                3'b000: audio_out = audio_in; // No effect
                3'b001: begin
                    tremelo_en = 1;
                    audio_out = tremelo_out;
                    search = 0;            end
                3'b010: begin
                    echo_en = 1;
                    audio_out = echo_reverb_out;
                    search = 1;
                end
                3'b011: begin
                    soft_clip_en = 1;
                    audio_out = soft_out;
                    search = 0;
                end
                3'b100: begin 
                    reverb_en = 1; 
                    audio_out = echo_reverb_out; 
                    search = 1;
                end
                default: audio_out = audio_in; 
            endcase
        end else begin
            audio_out = 8'd128;
        end
    end

endmodule

