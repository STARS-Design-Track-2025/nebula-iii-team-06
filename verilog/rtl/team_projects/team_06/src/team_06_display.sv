// module team_06_display (
//     input  logic        clk,
//     input  logic        rst,
//     input  logic [1:0]  state,
//     input  logic [2:0]  current_effect,
//     input logic ack,
//     output logic [11:0]  lcdOut,
//     // output logic        valid
// );

//     logic [3:0] counter, counter_n;
//     logic lcdData;

//     always_ff @(posedge clk, posedge rst) begin
//         if (rst) begin
//             x <= 1;
//             counter <= 0;
//         end else begin
//             x <= 0;
//             counter <= counter_n;
//         end
//     end

//     always_comb begin
//         counter_n = ack ? counter + 1 : counter;
//         lcdOut = lcdData[12*counter+:12];
//     end

//     always_comb begin 

//         if (x) begin
//             lcdData = {}
//         end
//         case(state)
//             ECHO: lcdData = {12'b100101100111, 12'b100100100011, 12'b100100101000, 12'b100100101111}; //ECHO
//             REVERB: lcdData = {12'b100101100010, 12'b100101100111, 12'b100101100110, 12'b100101100111, 12'b100101100010, 12'b100100100010}; //REVERB
//             SOFT_CLIPPING: lcdData = { 12'b100101100011, 12'b100100101111, 12'b100100100110, 12'b100101100100, 12'b100101101111, 12'b100100100011, 12'b100100101100, 12'b100100101001, 12'b1001010000, 12'b1001010000, 12'b100100101001, 12'b100100101110, 12'b100100100111}; //SOFT_CLIPPING 
//             TREMELO: lcdData = {12'b100101100100, 12'b100101100010, 12'b100101100111, 12'b100100101101, 12'b100101100111, 12'b100100101100, 12'b100100101111}; //TREMELO
//             LISTENING: lcdData = {12'b100100101100, 12'b100100101001, 12'b100101100011, 12'b100101100100, 12'b100101100111, 12'b100100101110, 12'b100100101001, 12'b100100101110, 12'b100100100111}; //LISTENING
//             NORMAL: lcdData = { 12'b100100101110, 12'b100100101111, 12'b100101100010, 12'b100100101101, 12'b100100100001, 12'b100100101100 }; //NORMAL 
//         endcase
//     end

//     // CLEAR_DISPLAY: lcdData = {12'b000000000001}; 
//     // RETURN_HOME: lcdData = {12'b000000000010 };
//     // FOUR_BIT_2_LINE: lcdData = {12'b000010001000};
//     // DISPLAY_ON: lcdData = {12'b000000001110};
//     // ENTRY_MODE: lcdData = {12'b000000000110};

// //edge detector
// // always_ff @(posedge clk, posedge rst) begin
// //     if(rst) begin
// //         CLEAR_DISPLAY =0;
// //         RETURN_HOME = 0;
// //         current_effect = 0;
// //     end else if (rising_edge) begin
// //         CLEAR_DISPLAY = 1;
// //         RETURN_HOME = 1;
// //         current_effect 1;

// //     end
// // end

// endmodule



































// //     logic [7:0] line_buffer [0:31]; // 2 lines x 16 chars
// //     logic [5:0] index;

// //     logic [1:0] prev_state;
// //     logic [2:0] prev_effect;
// //     logic update_needed;

// //     // Detect change in state/effect
// //     always_ff @(posedge clk or posedge rst) begin
// //         if (rst) begin
// //             prev_state <= 0;
// //             prev_effect <= 0;
// //             update_needed <= 1;
// //         end else begin
// //             if (state != prev_state || current_effect != prev_effect) begin
// //                 update_needed <= 1;
// //                 prev_state <= state;
// //                 prev_effect <= current_effect;
// //             end else begin
// //                 update_needed <= 0;
// //             end
// //         end
// //     end

// //     // Build the lines when update is needed
// //     always_ff @(posedge clk or posedge rst) begin
// //         if (rst) begin
// //             index <= 0;
// //         end else if (update_needed) begin
// //             string line1, line2;

// //             case (state)
// //                 2'b00: line1 = "LISTENING       ";
// //                 2'b01: line1 = "TALKING         ";
// //                 default: line1 = "UNKNOWN         ";
// //             endcase

// //             if (state == 2'b01) begin
// //                 case (current_effect)
// //                     3'b001: line2 = "ECHO            ";
// //                     3'b010: line2 = "TREMOLO         ";
// //                     3'b011: line2 = "REVERB          ";
// //                     3'b100: line2 = "CLIP            ";
// //                     default: line2 = "NORMAL          ";
// //                 endcase
// //             end else begin
// //                 line2 = "                "; // blank
// //             end

// //             // Fill buffer
// //             integer i;
// //             for (i = 0; i < 16; i++) begin
// //                 line_buffer[i]     = line1[i*8 +: 8];
// //                 line_buffer[i+16]  = line2[i*8 +: 8];
// //             end
// //             index <= 0;
// //         end
// //     end

// //     // Output on `next`
// //     always_ff @(posedge clk or posedge rst) begin
// //         if (rst) begin
// //             lcdData <= 8'h20;
// //             valid <= 0;
// //         end else if (next && index < 32) begin
// //             lcdData <= line_buffer[index];
// //             valid <= 1;
// //             index <= index + 1;
// //         end else begin
// //             valid <= 0;
// //         end
// //     end

// // endmodule
