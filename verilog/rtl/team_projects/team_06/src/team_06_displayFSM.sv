module team_06_displayFSM (
   input logic clk,
   input logic rst,
   input logic talkieState, // Is the walkie talkie in listen or talk state?
   input logic [2:0] current_effect, // What audio effect is the walkie talkie on?
   input logic [2:0] i2cState, // What state is the i2c in (off, begins, send, ack, wait, ends)
   input logic commsError, // This is a flag that goes high when we do not get an ack from the display
   input logic ready, // This is a flag that goes high when we are ready for new data
   output logic [5:0] lcdOut, // This is the current command for the i2c to send
   output logic trans // This is telling the i2c when to begin transmitting
);


   logic [191:0] lcdData; // This is a group of 16 pairs of 6 bit commands (R/W, RS, DB 7-4)
   logic [35:0] lcdData1; // This is always in the command and tells the screen to basically reset
   logic resetLogic, trans_n; // resetLogic checks if we just reset
   logic [2:0] desiredLCDstate, desiredLCDstate_n, currentLCDstate, currentLCDstate_n; // Current updates when we succesfully update the LCD, desired updates when we are not transmitting
   logic [4:0] counter, counter_n; // What part of our 16 pairs of 6 bit commands are we in?
   logic [5:0] lcdOut_n;


   // This is a modification of the typedef from FSM to include listen and an empty state
   typedef enum logic [2:0] {
      NORMAL = 3'b000,
      ECHO = 3'b001,
      TREMOLO = 3'b010,
      REVERB = 3'b011,
      SOFT = 3'b100,
      NONE = 3'b110,
      LISTEN = 3'b111
   } display_text_t;


   typedef enum logic {
      LIST = 1'b0,
      TALK = 1'b1
  } state_t;


   // See I2C for description
   typedef enum logic [2:0] {BEGINS = 3'b0, SEND = 3'b1, ACK = 3'd2, ENDS = 3'd3, OFF = 3'd4} state_I2C;


   always_ff @(posedge clk, posedge rst) begin
       if (rst) begin
           resetLogic <= 1;
           desiredLCDstate <= NONE;
           currentLCDstate <= NONE;
           trans <= 0;
           counter <= 0;
           lcdOut <= 0;
       end else begin
           resetLogic <= 0;
           desiredLCDstate <= desiredLCDstate_n;
           currentLCDstate <= currentLCDstate_n;
           trans <= trans_n;
           counter <= counter_n;
           lcdOut <= lcdOut_n;
       end
   end


   always_comb begin
       counter_n = counter;
       trans_n = trans;
       currentLCDstate_n = currentLCDstate;
       desiredLCDstate_n = desiredLCDstate;
       lcdOut_n = lcdOut;
       if (!trans && desiredLCDstate != currentLCDstate && i2cState == OFF) begin // If we are not transmitting and the i2c is ready and we want a new LCD state
           counter_n = 0;
           lcdOut_n = lcdData[191-:6]; // This takes bits 191 to 179, inclusive
           trans_n = 1; // transmit
       end else if (trans) begin // If we are currently transmitting
           if (commsError) begin // If we were unable to successfully transmit, our current state remains the same
               counter_n = 0;
               trans_n = 0;
               currentLCDstate_n = currentLCDstate;
           end else if (ready) begin // We change the data if the i2c is ready for another transmission
               counter_n = counter + 1;
               lcdOut_n = lcdData[(185-6*counter)-:6]; // This takes 6 bits, with the MSB bit being 191 - 6 * counter
               if (counter == 31 || lcdOut_n == {6{1'b1}}) begin // If our communication is over or we have met an empty communication, end transmission
                   trans_n = 0;
                   currentLCDstate_n = desiredLCDstate;  // We suceeded, so update our current state to our desired state
               end
           end
       end else begin // If we are not transmitting
           desiredLCDstate_n = (talkieState == LIST) ? LISTEN : current_effect; // We need to convert our talkiestate and effect into just one state machine
       end
   end


   always_comb begin
       lcdData1 = {12'b000000000001, 12'b000000000110, 12'b000000000010}; // CLEAR_DISPLAY, ENTRY_MODE, RETURN_HOME
       if (resetLogic) begin
           lcdData = {12'b000010000000, 12'b000010001000, 12'b000000001110, lcdData1, {120{1'b1}}}; // FUNCTION_SET, FOUR_BIT_2_LINE, DISPLAY_ON
       end else begin
           case(desiredLCDstate)
               ECHO: lcdData = {lcdData1, 12'b100101100111, 12'b100100100011, 12'b100100101000, 12'b100100101111, {108{1'b1}}}; //ECHO
               REVERB: lcdData = {lcdData1, 12'b100101100010, 12'b100101100111, 12'b100101100110, 12'b100101100111, 12'b100101100010, 12'b100100100010, {84{1'b1}}}; //REVERB
               SOFT: lcdData = {lcdData1, 12'b100101100011, 12'b100100101111, 12'b100100100110, 12'b100101100100, 12'b100101101111, 12'b100100100011, 12'b100100101100, 12'b100100101001, 12'b1001010000, 12'b1001010000, 12'b100100101001, 12'b100100101110, 12'b100100100111};
               //SOFT_CLIPPING
               TREMOLO: lcdData = {lcdData1, 12'b100101100100, 12'b100101100010, 12'b100101100111, 12'b100100101101, 12'b100101100111, 12'b100100101100, 12'b100100101111, {72{1'b1}}}; //TREMELO
               NORMAL: lcdData = {lcdData1, 12'b100100101110, 12'b100100101111, 12'b100101100010, 12'b100100101101, 12'b100100100001, 12'b100100101100, {84{1'b1}}}; //NORMAL
               LISTEN: lcdData = {lcdData1, 12'b100100101100, 12'b100100101001, 12'b100101100011, 12'b100101100100, 12'b100101100111, 12'b100100101110, 12'b100100101001, 12'b100100101110, 12'b100100100111, {48{1'b1}}}; //LISTENING
               default: lcdData = {192{1'b1}};
           endcase
       end
   end
endmodule




