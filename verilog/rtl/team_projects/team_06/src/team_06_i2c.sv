module team_06_i2c
(
    input logic clk, rst, sda_i,
    input logic [1:0] effect,
    input logic [7:0] lcdData,
    output logic sda_o, scl, oeb
);

    // CLOCK DIVIDER

    logic [8:0] counter, counter_n;
    logic clkdiv, clkdiv_temp;
    logic [1:0] effect_store, effect_n;
    
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= 0;
            clkdiv <= 0;
            effect_store <= 0;
        end else begin
            counter <= counter_n;
            clkdiv <= clkdiv_temp;
            effect_store <= effect_n;
        end 
    end

    always_comb begin
        counter_n = counter + 1;
        clkdiv_temp = clkdiv;
        if(counter == 9'd511) begin
            clkdiv_temp = ~clkdiv;
        end
    end

    // STATE MACHINE

    logic [2:0] state, state_n;
    logic ack, ack_n, complete, sda_o_n, scl_n, oeb_n;
    logic count, count_n;

    typedef enum logic [2:0] {BEGINS = 0, SEND = 1, ACK = 2, WAIT = 3, ENDS = 4, OFF = 5} state_I2C;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= OFF;
            sda_o <= 0;
            scl <= 0;
            oeb <= 0;
            ack <= 0;
        end else begin
            state <= state_n;
            sda_o <= sda_o_n;
            scl <= scl_n;
            oeb <= oeb_n;
            ack <= ack_n;
        end 
    end

    always_comb begin
        case (state)
        OFF: 
        begin 
            if (effect != effect_store) begin // If the effect has changed, we start a transmission
                state_n = BEGINS;
                count_n = 1'd1;
            end else begin
                state_n = OFF;
            end 
        end
        WAIT: 
        begin
            if (ack && complete && transmissionCount != 1) begin // If we have recieved an ack from the slave and 
                                                                 //we are done and we have not transmitted enough times
                state_n = BEGINS;
            end else begin
                state_n = ENDS;
            end
        end
        default:
        begin
            if (complete) begin
                state_n = state + 1;
            end else begin
                state_n = state; 
            end
            end
        endcase
    end

    // Counters
    logic beginCounter, beginCounter_n, endCounter, endCounter_n, transmissionCount, transmissionCount_n;
    logic [1:0] ackCounter, ackCounter_n, waitCounter, waitCounter_n;
    logic [5:0] sendCounter, sendCounter_n;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            beginCounter <= 0;
            sendCounter <= 0;
            ackCounter <= 0;
            transmissionCount <= 0;
            waitCounter <= 0;
        end else begin
            beginCounter <= beginCounter_n;
            sendCounter <= sendCounter_n;
            ackCounter <= ackCounter_n;
            transmissionCount <= transmissionCount_n;
            waitCounter <= waitCounter_n;
        end
    end

    always_comb begin
        sda_o_n = 0;
        scl_n = 0;
        endCounter_n= 0;
        beginCounter_n = 0;
        sendCounter_n = 0;
        ackCounter_n = 0;
        waitCounter_n = 0;
        transmissionCount_n = transmissionCount;
        complete = 0;
        oeb_n = 0;
        ack_n = ack;

        if (clkdiv && !clkdiv_temp) begin
            case (state)
            OFF: 
            begin 
                sda_o_n = 1;
                scl_n = 1;
            end
            BEGINS: 
            begin
                beginCounter_n = beginCounter + 1;
                if (beginCounter == 0) begin // Lower SDA 
                    sda_o_n = 0; 
                    scl_n = 1;
                end else if (beginCounter == 1) begin // Then SCL
                    sda_o_n = 0;
                    scl_n = 0;
                end
                if (beginCounter == 1) begin // After one transmission (1x2), complete
                    complete = 1;
                end
            end
            SEND:
            begin
                sendCounter_n = sendCounter + 1;
                if (sendCounter[1:0] == 0) begin        // First, update the data
                    sda_o_n = lcdData[sendCounter[3:1]];
                end else if (sendCounter[1:0] == 3) begin // Finally, turn clock off
                    scl_n = 0;
                    sda_o_n = sda_o;
                end else begin  // In the middle, clock is on
                    scl_n = 1;
                    sda_o_n = sda_o;
                end
                if (sendCounter == 31) begin // After 8 (8x4) transmissions, complete
                    complete = 1;
                end
            end
            ACK:
            begin
                if (sda_i == 1) begin
                    ack_n = 1;
                end
                ackCounter_n = ackCounter + 1; 
                if (ackCounter <= 1) begin // For first half, tell the peripheral to write
                    oeb_n = 1;
                    scl_n = 0;
                    sda_o_n = 1;
                end else if (ackCounter == 2) begin // Then, clock on
                    scl_n = 1;
                    sda_o_n = 1;
                    oeb_n = 1; 
                end else begin // Then, clock off (after ack, we will stop requesting)
                    scl_n = 0;
                    sda_o_n = 1;
                    oeb_n = 1;
                end
                if (sendCounter == 3) begin // After 1 (1x4) transmissions, complete
                    complete = 1;
                end
            end
            WAIT:
            begin
                ack_n = ack;
                waitCounter_n = waitCounter + 1;
                scl_n = 0;
                sda_o_n = 1;
                if (waitCounter == 3) begin // After one transmission (1x4), complete
                    complete = 1;
                    transmissionCount_n = transmissionCount + 1;
                end 
            end
            ENDS:
            begin
                endCounter_n = endCounter + 1;
                if (endCounter == 0) begin // Raise SCL
                    sda_o_n = 0; 
                    scl_n = 1;
                end else if (endCounter == 1) begin // Then SDA
                    sda_o_n = 1;
                    scl_n = 1;
                end
                if (endCounter == 1) begin // After one transmission (1x2), complete
                    complete = 1;
                end 
            end
            default: 
            begin
            end
            endcase
        end
    end


endmodule;