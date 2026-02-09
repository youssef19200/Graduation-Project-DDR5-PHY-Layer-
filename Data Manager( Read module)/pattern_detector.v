// File: pattern_detector.v (CORRECTED - PROPER BIT ORDERING)
`timescale 1ns/1ps
module pattern_detector (
    input clk_i,
    input reset_n_i,
    input en_i,                    // Enable signal (active high)
    input DQS_AD,                  // DQS signal from DDR5 bus
    input [2:0] pre_amble_sett_i,  // Preamble setting: 000="10", 001="0010", etc.
    input post_amble_sett_i,       // Not used for preamble detection (required for port compatibility)
    output reg pattern_detected    // Single-cycle pulse when pattern detected
);
    reg [8:1] shift_reg;           // 8-bit shift register for DQS history tracking
    reg [1:0] current_state;       // FSM state register (3 states)
    localparam IDLE = 2'b00, SHIFTING = 2'b01, DETECTED = 2'b10;
    
    // CRITICAL FIX: Use REG instead of WIRE for procedural assignment
    reg [8:0] selected_pattern;    // Selected pattern based on preamble setting (9 bits)
    reg [3:0] pattern_length;      // Pattern length in bits (2, 4, 6, or 8 bits)
    
    // Predefined DDR5 preamble patterns (constants)
    wire [8:0] pattern_10       = 9'b10_0000000;      // "10" pattern (2 bits)
    wire [8:0] pattern_0010     = 9'b0010_00000;      // "0010" pattern (4 bits)
    wire [8:0] pattern_1110     = 9'b1110_00000;      // "1110" pattern (4 bits)
    wire [8:0] pattern_000010   = 9'b000010_000;      // "000010" pattern (6 bits)
    wire [8:0] pattern_00001010 = 9'b00001010_0;      // "00001010" pattern (8 bits)

    // Select pattern and length based on preamble setting input
    always @(*) begin
        case (pre_amble_sett_i)
            3'b000: begin selected_pattern = pattern_10;       pattern_length = 4'd2; end  // "10"
            3'b001: begin selected_pattern = pattern_0010;     pattern_length = 4'd4; end  // "0010"
            3'b010: begin selected_pattern = pattern_1110;     pattern_length = 4'd4; end  // "1110"
            3'b011: begin selected_pattern = pattern_000010;   pattern_length = 4'd6; end  // "000010"
            3'b100: begin selected_pattern = pattern_00001010; pattern_length = 4'd8; end  // "00001010"
            default: begin selected_pattern = pattern_10;       pattern_length = 4'd2; end  // Default to "10"
        endcase
    end

    // Main FSM with proper reset and enable handling
    always @(posedge clk_i or negedge reset_n_i) begin
        
        if (!reset_n_i) begin          // Active-low reset
            shift_reg <= 8'h00;
            current_state <= IDLE;
            pattern_detected <= 1'b0;
        end else if (!en_i) begin      // Handle enable signal properly
            shift_reg <= 8'h00;        // Clear shift register when disabled
            current_state <= IDLE;     // Return to idle state
            pattern_detected <= 1'b0;  // Ensure output is low when disabled
        end else begin
            pattern_detected <= 1'b0;  // Reset output every cycle for single-cycle pulse
            
            case (current_state)
                IDLE: begin
                    shift_reg <= 8'h00;      // Clear shift register before starting detection
                    pattern_detected <= 1'b0; 
                    current_state <= SHIFTING;
                end
                
                SHIFTING: begin
                    pattern_detected <= 1'b0; 
                    // Shift DQS bit into LSB position (MSB-first pattern matching)
                    shift_reg[8:2] <= shift_reg[7:1];
                   
                    shift_reg[1] <= DQS_AD;
                    
                    // CRITICAL FIX: Proper bit ordering comparison
                    // After N cycles, the pattern bits are in shift_reg[N:1] (LSB-aligned)
                    case (pattern_length)
                        4'd2: if (shift_reg[2:1] == selected_pattern[8:7]) 
                                  current_state <= DETECTED;  // 2-bit pattern match
                        4'd4: if (shift_reg[4:1] == selected_pattern[8:5]) 
                                  current_state <= DETECTED;  // 4-bit pattern match
                        4'd6: if (shift_reg[6:1] == selected_pattern[8:3]) 
                                  current_state <= DETECTED;  // 6-bit pattern match
                        4'd8: if (shift_reg[8:1] == selected_pattern[8:1]) 
                                  current_state <= DETECTED;  // 8-bit pattern match
                        default: if (shift_reg[2:1] == selected_pattern[8:7]) 
                                    current_state <= DETECTED;  // Default 2-bit match
                    endcase
                end
                
                DETECTED: begin
                    pattern_detected <= 1'b1;  // Generate single-cycle pulse
                    current_state <= IDLE;     // Return to IDLE immediately for next detection

                end
                
                default: current_state <= IDLE;
            endcase
        end
    end
endmodule