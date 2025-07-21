module team_06_sram_sim (
    input logic clk,
    input logic rst,
    input logic [31:0] address,
    input logic [31:0] write_data,
    input logic write_en,
    input logic read_en,
    input logic [3:0] byte_select,
    output logic [31:0] read_data,
    output logic busy
);
    reg [31:0] memory [0:8191];
    logic [31:0] read_data_n;
    logic busy_n;
    logic [1:0] state, state_n;
    localparam IDLE = 2'b00, READ = 2'b01, WRITE = 2'b10;

    // Initialize memory
    initial begin
        for (int i = 0; i < 8192; i++) begin
            memory[i] = 32'h0;
        end
    end

    // State machine and data handling
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            read_data <= 32'h0;
            busy <= 0;
        end else begin
            state <= state_n;
            read_data <= read_data_n;
            busy <= busy_n;
            if (state == WRITE && write_en) begin
                if (byte_select[0]) memory[address[12:0]][7:0]   <= write_data[7:0];
                if (byte_select[1]) memory[address[12:0]][15:8]  <= write_data[15:8];
                if (byte_select[2]) memory[address[12:0]][23:16] <= write_data[23:16];
                if (byte_select[3]) memory[address[12:0]][31:24] <= write_data[31:24];
            end
        end
    end

    // Combinational logic for state transitions
    always_comb begin
        state_n = state;
        read_data_n = read_data;
        busy_n = busy;
        case (state)
            IDLE: begin
                busy_n = 0;
                if (read_en) begin
                    state_n = READ;
                    busy_n = 1;
                    read_data_n = memory[address[12:0]];
                end else if (write_en) begin
                    state_n = WRITE;
                    busy_n = 1;
                end
            end
            READ: begin
                state_n = IDLE;
                busy_n = 0;
            end
            WRITE: begin
                state_n = IDLE;
                busy_n = 0;
            end
            default: state_n = IDLE;
        endcase
    end
endmodule
// module team_06_sram_sim (
//     input logic clk,
//     input logic rst,
//     input logic [31:0] address,
//     input logic [31:0] write_data,
//     input logic write_en,
//     input logic read_en,
//     input logic [3:0] byte_select,
//     output logic [31:0] read_data,
//     output logic busy
// );
//     reg [31:0] memory [0:8191];
//     logic [31:0] read_data_n;
//     logic busy_n;
//     logic [1:0] state, state_n;
//     localparam IDLE = 2'b00, READ = 2'b01, WRITE = 2'b10;

//     // Initialize memory
//     initial begin
//         for (int i = 0; i < 8192; i++) begin
//             memory[i] = 32'h0;
//         end
//     end

//     // State machine and data handling
//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             state <= IDLE;
//             read_data <= 32'h0;
//             busy <= 0;
//         end else begin
//             state <= state_n;
//             read_data <= read_data_n;
//             busy <= busy_n;
//             if (state == WRITE && write_en) begin
//                 if (byte_select[0]) memory[address[12:0]][7:0]   <= write_data[7:0];
//                 if (byte_select[1]) memory[address[12:0]][15:8]  <= write_data[15:8];
//                 if (byte_select[2]) memory[address[12:0]][23:16] <= write_data[23:16];
//                 if (byte_select[3]) memory[address[12:0]][31:24] <= write_data[31:24];
//             end
//         end
//     end

//     // Combinational logic for state transitions
//     always_comb begin
//         state_n = state;
//         read_data_n = read_data;
//         busy_n = busy;
//         case (state)
//             IDLE: begin
//                 busy_n = 0;
//                 if (read_en) begin
//                     state_n = READ;repeat (24000) begin // 500 ms at 48 kHz (24,000 samples)
//         audio_in = $urandom_range(0, 255); // Random 8-bit value
//         #208; // 20.83 µs per sample (48 kHz)
//     end
//                     busy_n = 1;
//                     read_data_n = memory[address[12:0]];
//                 end else if (write_en) begin
//                     state_n = WRITE;
//                     busy_n = 1;
//                 end
//             end
//             READ: begin
//                 state_n = IDLE;
//                 busy_n = 0;
//             end
//             WRITE: begin
//                 state_n = IDLE;
//                 busy_n = 0;
//             end
//             default: state_n = IDLE;
//         endcase
//     end
// endmodule