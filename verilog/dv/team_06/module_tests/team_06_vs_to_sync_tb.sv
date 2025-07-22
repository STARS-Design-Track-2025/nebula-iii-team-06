`timescale 1ms/10ps
module team_06_vs_to_sync_tb;

logic clk;
logic rst;
logic [3:0] pbs;
logic [1:0]vol;  
logic enable_volume;
logic [7:0] audio_in;
logic [7:0] audio_out;

//Instantiation of team_06_vs_to_sync module
team_06_vs_to_sync tolu (
    .clk(clk),
    .rst(rst),
    .pbs(pbs),
    .vol(vol),
    .audio_out(audio_out),
    .audio_in(audio_in),
    .enable_volume(enable_volume)
);

// // For synckey
// logic [3:0] pbs;
// logic [1:0] vol;
// logic [3:0] volume; // Shared signal
// logic ptt;
// logic noise_gate;
// logic effect;
// logic mute;

// // For volume shifter
// logic enable_volume;
// logic [7:0] audio_in;
// logic [7:0] audio_out;


// Clock generation
initial clk = 0;
always #0.5 clk = ~clk;

// Test sequence
initial begin
    // Waveform Dumping
    $dumpfile("team_06_vs_to_sync.vcd");
    $dumpvars(0, team_06_vs_to_sync_tb);

    // ➤ Test 0: Reset (done)
    @(posedge clk);
    rst = 1;
    pbs = 0;
    vol = 2'b00;
    enable_volume = 0;
    audio_in = 8'd0;
    #5
//Disregard all comments from here on the testcases:
    // ➤ Test 1: Basic volume input with button 1 and vol 0 (done)
    @(posedge clk);
    rst = 0;
    pbs = 1;
    vol = 2'b01;
    enable_volume = 0;
    audio_in = 8'd60;
    #5

     @(posedge clk);
    rst = 0;
    pbs = 1;
    vol = 2'b11;
    enable_volume = 0;
    audio_in = 8'd60;
    #5

    // ➤ Test 2: Switch to button 2 and vol 0 (done)
    @(posedge clk);
    rst = 0;
    pbs = 2;
    vol = 2'b10;
    enable_volume = 0;
    audio_in = 8'd100;
    #5

    // ➤ Test 3: Increase vol knob to 1 (done)
    @(posedge clk);
    rst = 0;
    pbs = 3;
    vol = 2'b00;
    enable_volume = 1;
    audio_in = 8'd255;
    #5

     @(posedge clk);
    rst = 1;
    pbs = 0;
    vol = 2'b00;
    enable_volume = 0;
    audio_in = 8'd00;
    #5

    // ➤ Test 4: Disable volume shifting temporarily (done)
    @(posedge clk);
    rst = 0;
    pbs = 4;
    vol = 2'b01;
    enable_volume = 0;
    audio_in = 8'd150;
    #5

     @(posedge clk);
    rst = 0;
    pbs = 1;
    vol = 2'b11;
    enable_volume = 0;
    audio_in = 8'd103;
    #5
    

    // ➤ Test 5: Try mute toggle ON (done)
    @(posedge clk);
    rst = 0;
    pbs = 5;
    vol = 2'b10;
    enable_volume = 1;
    audio_in = 8'd189;
    #5

    // ➤ Test 6: Reset during operation (done)
    @(posedge clk);
    rst = 0;
    pbs = 8;
    vol = 2'b00;
    enable_volume = 1;
    audio_in = 8'd0;
    #5

    // // ➤ Test 7: After reset, resume with high volume (done)
    // @(posedge clk);
    // rst = 0;
    // pbs = 4'd4;
    // vol = 2'b11;
    // enable_volume = 0;
    // audio_in = 8'd255;
    // #4;

    // // ➤ Test 8: Volume off while audio is high
    // @(posedge clk);
    // rst = 0;
    // pbs = 4'd5;
    // vol = 2'b11;
    // enable_volume = 0;
    // audio_in = 8'd255;
    // #4;

    // ➤ Final reset and idle state
    @(posedge clk);
    rst = 1;
    pbs = 0;
    vol = 2'b01;
    enable_volume = 0;
    audio_in = 8'd0;
    #5

    $finish;
end

endmodule

