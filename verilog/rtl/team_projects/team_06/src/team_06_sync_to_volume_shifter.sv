module team_06_sync_to_volume_shifter (
   input logic [3:0] pbs,    // 4 pushbuttons
   input logic clk,          // 25 mHz clock
   input logic rst,          // Active-high reset
   input logic [1:0] vol,      // volume input for the volume knob
   input logic enable_volume,
   input logic [7:0] audio_in,
   output logic [7:0] audio_out
);

logic [3:0] volume;
logic ptt;
logic noise_gate;
logic effect;
logic mute;
// logic enable_volume;
// logic [7:0] audio_in;


// Instantiate synckey module
team_06_synckey seno (
    .pbs(pbs),
    .clk(clk),
    .rst(rst),
    .vol(vol),
    .volume(volume),
    .ptt(ptt),
    .noise_gate(noise_gate),
    .effect(effect),
    .mute(mute)
);

// Instantiate volume shifter module
team_06_volume_shifter kamsi (
    .clk(clk),
    .rst(rst),
    .audio_in(audio_in),
    .volume(volume),           // Connected to synckey
    .enable_volume(enable_volume),
    .audio_out(audio_out)
);

// always_ff @(posedge clk or posedge rst) begin
//     if(rst)begin
//         volume <= 0;
//     end else begin
//         volume <= temp_volume;
//     end
//     end

// always_comb begin 
//     temp_volume = volume;
//     if(!enable_volume)begin
//         temp_volume =  0;
//     end else begin
//         temp_volume =  0;
//     end

// end

endmodule