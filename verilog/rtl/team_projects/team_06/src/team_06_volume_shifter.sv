module team_06_volume_shifter(
    input logic clk, rst,
    input logic [7:0] audio_in,
    input logic [3:0] volume, //coming from synckey
    input logic enable_volume, //coming from FSM 
    output logic [7:0] audio_out,
    output logic en
);

    logic [7:0] scale;
    logic [15:0] audio_in_16, audio_out_16, audio_out_16_n;
    logic en_n;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            audio_out_16 <= 16'd128;
            en<=0;
        end
        else begin
            audio_out_16 <= audio_out_16_n;
            en <= en_n;
        end
    end
    
    always_comb begin
        audio_in_16 = {8'b0, audio_in};

        if(enable_volume) begin
            if (audio_in >= 128)
                audio_out_16_n = 128 + ( (audio_in_16 - 16'd128) * scale ) / 255;
            else 
               audio_out_16_n = 127 - ( (16'd127 - audio_in_16) * scale ) / 255;
               en_n = 1;
        end else begin
            audio_out_16_n = 16'd128;
            en_n = 0;
        end
        audio_out = audio_out_16[7:0];
    end

    always_comb begin  // Logarithmic volume control
        case (volume)
            4'd0:  scale = 8'd0;
            4'd1:  scale = 8'd1;
            4'd2:  scale = 8'd2;
            4'd3:  scale = 8'd4;
            4'd4:  scale = 8'd7;
            4'd5:  scale = 8'd10;
            4'd6:  scale = 8'd15;
            4'd7:  scale = 8'd21;
            4'd8:  scale = 8'd29;
            4'd9:  scale = 8'd40;
            4'd10: scale = 8'd55;
            4'd11: scale = 8'd76;
            4'd12: scale = 8'd103;
            4'd13: scale = 8'd139;
            4'd14: scale = 8'd189;
            4'd15: scale = 8'd255;
            default: scale = 8'd0;
        endcase
    end

endmodule