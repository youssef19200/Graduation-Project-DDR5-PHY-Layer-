
// File: pattern_detector.v
// BY: Youssef Mohamed Makboul
`timescale 1ns/1ps
module pattern_detector (
    input clk_i,
    input reset_n_i,
    input en_i,                    // Enable signal (active high)
    input DQS_AD,                  // DQS signal from DDR5 bus
    input [2:0] pre_amble_sett_i,  // Preamble setting: 000="10", 001="0010", etc.
    input post_amble_sett_i,       // Post-amble setting (0=0.5tCK, 1=1.5tCK)
    input [4:0] gap_i,             // Gap between reads (for interamble detection)
    input pre_or_inter,            // 1=preamble, 0=interamble
    output reg pattern_detected    // Single-cycle pulse when pattern detected
);
    reg [9:1] shift_reg;           // 9-bit shift register for DQS history tracking
    reg [1:0] current_state;       // FSM state register (3 states)
    localparam IDLE = 2'b00, SHIFTING = 2'b01, DETECTED = 2'b10;
    
    reg [9:0] selected_pattern;    // Selected pattern based on all inputs (10 bits)
    reg [3:0] pattern_length;      // Pattern length in bits (2-9 bits)
    
    // Predefined DDR5 patterns (constants)
    wire [9:0] pattern_10        = 10'b10_00000000;     // "10" (2 bits)
    wire [9:0] pattern_0010      = 10'b0010_000000;     // "0010" (4 bits)
    wire [9:0] pattern_1110      = 10'b1110_000000;     // "1110" (4 bits)
    wire [9:0] pattern_000010    = 10'b000010_0000;     // "000010" (6 bits)
    wire [9:0] pattern_00001010  = 10'b00001010_00;     // "00001010" (8 bits)
    wire [9:0] pattern_01010     = 10'b01010_000000;    // "01010" (5 bits)
    wire [9:0] pattern_0100010   = 10'b0100010_0000;    // "0100010" (7 bits)
    wire [9:0] pattern_010001010 = 10'b010001010_0;     // "010001010" (9 bits)
    wire [9:0] pattern_001010    = 10'b001010_00000;    // "001010" (6 bits)

    // Select pattern based on ALL inputs (preamble/interamble + gap + settings)
    always @(*) begin
        case ({pre_or_inter, pre_amble_sett_i, post_amble_sett_i, gap_i})
            // ========== PREAMBLE CASES (pre_or_inter = 1) ==========
            {1'b1, 3'b000, 1'b?, 5'b?????}: begin  // "10"
                selected_pattern = pattern_10;
                pattern_length = 4'd2;
            end
            {1'b1, 3'b001, 1'b?, 5'b?????}: begin  // "0010"
                selected_pattern = pattern_0010;
                pattern_length = 4'd4;
            end
            {1'b1, 3'b010, 1'b?, 5'b?????}: begin  // "1110"
                selected_pattern = pattern_1110;
                pattern_length = 4'd4;
            end
            {1'b1, 3'b011, 1'b?, 5'b?????}: begin  // "000010"
                selected_pattern = pattern_000010;
                pattern_length = 4'd6;
            end
            {1'b1, 3'b100, 1'b?, 5'b?????}: begin  // "00001010"
                selected_pattern = pattern_00001010;
                pattern_length = 4'd8;
            end
            
            // ========== INTERAMBLE CASES (pre_or_inter = 0) ==========
            // gap = min+1 (gap_i = 5'd1)
            {1'b0, 3'b???, 1'b?, 5'b00001}: begin  // seamless → "10"
                selected_pattern = pattern_10;
                pattern_length = 4'd2;
            end
            
            // gap = min+2 (gap_i = 5'd2)
            {1'b0, 3'b???, 1'b0, 5'b00010}: begin  // post=0.5 → "0010"
                selected_pattern = pattern_0010;
                pattern_length = 4'd4;
            end
            {1'b0, 3'b???, 1'b1, 5'b00010}: begin  // post=1.5 → "01010"
                selected_pattern = pattern_01010;
                pattern_length = 4'd5;
            end
            
            // gap = min+3 (gap_i = 5'd3)
            {1'b0, 3'b011, 1'b1, 5'b00011}: begin  // pre=3, post=1.5 → "0100010"
                selected_pattern = pattern_0100010;
                pattern_length = 4'd7;
            end
            {1'b0, 3'b100, 1'b0, 5'b00011}: begin  // pre=4, post=0.5 → "0001010" (mapped to "0100010")
                selected_pattern = pattern_0100010;
                pattern_length = 4'd7;
            end
            {1'b0, 3'b100, 1'b1, 5'b00011}: begin  // pre=4, post=1.5 → "0101010" (mapped to "001010")
                selected_pattern = pattern_001010;
                pattern_length = 4'd6;
            end
            
            // gap = min+4 (gap_i = 5'd4)
            {1'b0, 3'b100, 1'b1, 5'b00100}: begin  // pre=4, post=1.5, gap=min+4 → "010001010"
                selected_pattern = pattern_010001010;
                pattern_length = 4'd9;
            end
            
            default: begin  // Fallback to "10" preamble
                selected_pattern = pattern_10;
                pattern_length = 4'd2;
            end
        endcase
    end

    // Main FSM with proper reset and enable handling
    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            shift_reg <= 9'h00;
            current_state <= IDLE;
            pattern_detected <= 1'b0;
        end else if (!en_i) begin
            shift_reg <= 9'h00;
            current_state <= IDLE;
            pattern_detected <= 1'b0;
        end else begin
            pattern_detected <= 1'b0;  // Single-cycle pulse guarantee
            
            case (current_state)
                IDLE: begin
                    shift_reg <= 9'h00;
                    current_state <= SHIFTING;
                end
                
                SHIFTING: begin
                    // Shift DQS bit into LSB position (MSB-first pattern matching)
                    shift_reg[9:2] <= shift_reg[8:1];
                    shift_reg[1] <= DQS_AD;
                    
                    // Pattern matching based on length
                    case (pattern_length)
                        4'd2: if (shift_reg[2:1] == selected_pattern[9:8]) 
                                  current_state <= DETECTED;
                        4'd4: if (shift_reg[4:1] == selected_pattern[9:6]) 
                                  current_state <= DETECTED;
                        4'd5: if (shift_reg[5:1] == selected_pattern[9:5]) 
                                  current_state <= DETECTED;
                        4'd6: if (shift_reg[6:1] == selected_pattern[9:4]) 
                                  current_state <= DETECTED;
                        4'd7: if (shift_reg[7:1] == selected_pattern[9:3]) 
                                  current_state <= DETECTED;
                        4'd8: if (shift_reg[8:1] == selected_pattern[9:2]) 
                                  current_state <= DETECTED;
                        4'd9: if (shift_reg[9:1] == selected_pattern[9:1]) 
                                  current_state <= DETECTED;
                        default: if (shift_reg[2:1] == selected_pattern[9:8]) 
                                    current_state <= DETECTED;
                    endcase
                end
                
                DETECTED: begin
                    pattern_detected <= 1'b1;  // Single-cycle pulse
                    current_state <= IDLE;     // Return to IDLE immediately
                end
                
                default: current_state <= IDLE;
            endcase
        end
    end
endmodule
