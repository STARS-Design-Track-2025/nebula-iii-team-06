// module team_06_disp_to_i2c(
//     input logic clk,
//     input logic rst,
//     input logic sda_i,
//     input logic talkieState, // Is the walkie talkie in listen or talk state?
//     input logic [2:0] current_effect, // What audio effect is the walkie talkie on?
//     output logic sda_o, scl, oeb  //sda_o is data, scl is the clock line, and oeb is whether we are sending or recieving on the sda
// );

//     logic ready;
//     logic [5:0] lcdData;
//     logic trans, commsError;
//     logic noise_gate;
//     logic [2:0] state;
//     logic [2:0]currnt_effect;
//     logic [5:0] lcdOut;
//     logic [2:0] i2cState;
//     team_06_displayFSM display (
//         .clk(clk),
//         .rst(rst),
//         .talkieState(talkieState),
//         .current_effect(current_effect),
//         .i2cState(state),
//         .commsError(commsError),
//         .ready(ready),
//         .lcdOut(lcdData),
//         .trans(trans)
//     );

//     team_06_i2c i2c (
//         .clk(clk),
//         .rst(rst),
//         .sda_i(sda_i),
//         .trans(trans),
//         .lcdData(lcdData),
//         .sda_o(sda_o),
//         .scl(scl),
//         .oeb(oeb),
//         .state(state),
//         .commsError(commsError),
//         .ready(ready)
//     );

// endmodule