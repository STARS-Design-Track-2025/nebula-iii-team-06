module team_06_volume_shifter(
    input logic clk, rst,
    input logic [7:0] audio_in,
    input logic [3:0] volume,
    input logic enable_volume,
    output logic [7:0] audio_out
);
    logic [7:0] scale;
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            audio_out <= '0;
        end
        else begin
            if(enable_volume) begin
                audio_out <= (audio_in * scale)>>4;
            end else begin
                audio_out <= '0;
            end
        end
    end
    
        always_comb begin
        case (volume)
            4'd0:  scale = 8'd0;
            4'd1:  scale = 8'd4;
            4'd2:  scale = 8'd7;
            4'd3:  scale = 8'd11;
            4'd4:  scale = 8'd16;
            4'd5:  scale = 8'd23;
            4'd6:  scale = 8'd32;
            4'd7:  scale = 8'd45;
            4'd8:  scale = 8'd64;
            4'd9:  scale = 8'd90;
            4'd10: scale = 8'd128;
            4'd11: scale = 8'd180;
            4'd12: scale = 8'd200;
            4'd13: scale = 8'd220;
            4'd14: scale = 8'd240;
            4'd15: scale = 8'd255;
            default: scale = 8'd0;
        endcase
    end

endmodule
