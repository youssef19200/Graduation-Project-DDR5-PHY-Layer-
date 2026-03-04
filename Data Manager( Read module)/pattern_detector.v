/*

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

*/

// File: pattern_detector.v (FULL INTERAMBLE SUPPORT)
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
        // gap = 1001 (5'b01001)
        {1'b0, 3'b???, 1'b0, 5'b01001}: begin  // "10" (seamless)
            selected_pattern = pattern_10;
            pattern_length = 4'd2;
        end
        
        // gap = 1010 (5'b01010)
        {1'b0, 3'b011, 1'b0, 5'b01010}: begin  // pre=3, post=0.5 → "0010"
            selected_pattern = pattern_0010;
            pattern_length = 4'd4;
        end
        {1'b0, 3'b100, 1'b0, 5'b01010}: begin  // pre=4, post=0.5 → "01010"
            selected_pattern = pattern_01010;
            pattern_length = 4'd5;
        end
        {1'b0, 3'b???, 1'b1, 5'b01010}: begin  // any pre, post=1.5 → "01010"
            selected_pattern = pattern_01010;
            pattern_length = 4'd5;
        end
        
        // gap = 1011 (5'b01011)
        {1'b0, 3'b011, 1'b1, 5'b01011}: begin  // pre=3, post=1.5 → "0100010"
            selected_pattern = pattern_0100010;
            pattern_length = 4'd7;
        end
        {1'b0, 3'b100, 1'b1, 5'b01011}: begin  // pre=4, post=1.5 → "0100010"
            selected_pattern = pattern_0100010;
            pattern_length = 4'd7;
        end
        
        // gap = 1100 (5'b01100)
        {1'b0, 3'b100, 1'b1, 5'b01100}: begin  // pre=4, post=1.5 → "010001010"
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








/*
// File: pattern_detector.v (FULL 5-BIT GAP SUPPORT)
`timescale 1ns/1ps
module pattern_detector (
    input clk_i,
    input reset_n_i,
    input en_i,                    // Enable signal (active high)
    input DQS_AD,                  // DQS signal from DDR5 bus
    input [2:0] pre_amble_sett_i,  // Preamble setting: 000="10", 001="0010", etc.
    input post_amble_sett_i,       // Post-amble setting (0=0.5tCK, 1=1.5tCK)
    input [4:0] gap_i,             // 5-bit gap counter (0-31 cycles)
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
            // gap = min+1 (gap_i = 5'b00001)
            {1'b0, 3'b???, 1'b?, 5'b00001}: begin  // seamless → "10"
                selected_pattern = pattern_10;
                pattern_length = 4'd2;
            end
            
            // gap = min+2 (gap_i = 5'b00010)
            {1'b0, 3'b???, 1'b0, 5'b00010}: begin  // post=0.5 → "0010"
                selected_pattern = pattern_0010;
                pattern_length = 4'd4;
            end
            {1'b0, 3'b???, 1'b1, 5'b00010}: begin  // post=1.5 → "01010"
                selected_pattern = pattern_01010;
                pattern_length = 4'd5;
            end
            
            // gap = min+3 (gap_i = 5'b00011)
            {1'b0, 3'b011, 1'b1, 5'b00011}: begin  // pre=3, post=1.5 → "0100010"
                selected_pattern = pattern_0100010;
                pattern_length = 4'd7;
            end
            {1'b0, 3'b100, 1'b0, 5'b00011}: begin  // pre=4, post=0.5 → "0100010"
                selected_pattern = pattern_0100010;
                pattern_length = 4'd7;
            end
            {1'b0, 3'b100, 1'b1, 5'b00011}: begin  // pre=4, post=1.5 → "001010"
                selected_pattern = pattern_001010;
                pattern_length = 4'd6;
            end
            
            // gap = min+4 (gap_i = 5'b00100)
            {1'b0, 3'b100, 1'b1, 5'b00100}: begin  // pre=4, post=1.5 → "010001010"
                selected_pattern = pattern_010001010;
                pattern_length = 4'd9;
            end
            
            // ========== SATURATED PATTERNS (gap >= min+4) ==========
            // For all gaps 5-30 (5'b00101 to 5'b11110), patterns saturate
            // pre=000, post=0 → always "10"
            {1'b0, 3'b000, 1'b0, 5'b00101},
            {1'b0, 3'b000, 1'b0, 5'b00110},
            {1'b0, 3'b000, 1'b0, 5'b00111},
            {1'b0, 3'b000, 1'b0, 5'b01000},
            {1'b0, 3'b000, 1'b0, 5'b01001},
            {1'b0, 3'b000, 1'b0, 5'b01010},
            {1'b0, 3'b000, 1'b0, 5'b01011},
            {1'b0, 3'b000, 1'b0, 5'b01100},
            {1'b0, 3'b000, 1'b0, 5'b01101},
            {1'b0, 3'b000, 1'b0, 5'b01110},
            {1'b0, 3'b000, 1'b0, 5'b01111},
            {1'b0, 3'b000, 1'b0, 5'b10000},
            {1'b0, 3'b000, 1'b0, 5'b10001},
            {1'b0, 3'b000, 1'b0, 5'b10010},
            {1'b0, 3'b000, 1'b0, 5'b10011},
            {1'b0, 3'b000, 1'b0, 5'b10100},
            {1'b0, 3'b000, 1'b0, 5'b10101},
            {1'b0, 3'b000, 1'b0, 5'b10110},
            {1'b0, 3'b000, 1'b0, 5'b10111},
            {1'b0, 3'b000, 1'b0, 5'b11000},
            {1'b0, 3'b000, 1'b0, 5'b11001},
            {1'b0, 3'b000, 1'b0, 5'b11010},
            {1'b0, 3'b000, 1'b0, 5'b11011},
            {1'b0, 3'b000, 1'b0, 5'b11100},
            {1'b0, 3'b000, 1'b0, 5'b11101},
            {1'b0, 3'b000, 1'b0, 5'b11110}: begin
                selected_pattern = pattern_10;
                pattern_length = 4'd2;
            end
            
            // pre=011, post=0 → always "0010"
            {1'b0, 3'b011, 1'b0, 5'b00101},
            {1'b0, 3'b011, 1'b0, 5'b00110},
            {1'b0, 3'b011, 1'b0, 5'b00111},
            {1'b0, 3'b011, 1'b0, 5'b01000},
            {1'b0, 3'b011, 1'b0, 5'b01001},
            {1'b0, 3'b011, 1'b0, 5'b01010},
            {1'b0, 3'b011, 1'b0, 5'b01011},
            {1'b0, 3'b011, 1'b0, 5'b01100},
            {1'b0, 3'b011, 1'b0, 5'b01101},
            {1'b0, 3'b011, 1'b0, 5'b01110},
            {1'b0, 3'b011, 1'b0, 5'b01111},
            {1'b0, 3'b011, 1'b0, 5'b10000},
            {1'b0, 3'b011, 1'b0, 5'b10001},
            {1'b0, 3'b011, 1'b0, 5'b10010},
            {1'b0, 3'b011, 1'b0, 5'b10011},
            {1'b0, 3'b011, 1'b0, 5'b10100},
            {1'b0, 3'b011, 1'b0, 5'b10101},
            {1'b0, 3'b011, 1'b0, 5'b10110},
            {1'b0, 3'b011, 1'b0, 5'b10111},
            {1'b0, 3'b011, 1'b0, 5'b11000},
            {1'b0, 3'b011, 1'b0, 5'b11001},
            {1'b0, 3'b011, 1'b0, 5'b11010},
            {1'b0, 3'b011, 1'b0, 5'b11011},
            {1'b0, 3'b011, 1'b0, 5'b11100},
            {1'b0, 3'b011, 1'b0, 5'b11101},
            {1'b0, 3'b011, 1'b0, 5'b11110}: begin
                selected_pattern = pattern_0010;
                pattern_length = 4'd4;
            end
            
            // pre=100, post=0 → always "01010"
            {1'b0, 3'b100, 1'b0, 5'b00101},
            {1'b0, 3'b100, 1'b0, 5'b00110},
            {1'b0, 3'b100, 1'b0, 5'b00111},
            {1'b0, 3'b100, 1'b0, 5'b01000},
            {1'b0, 3'b100, 1'b0, 5'b01001},
            {1'b0, 3'b100, 1'b0, 5'b01010},
            {1'b0, 3'b100, 1'b0, 5'b01011},
            {1'b0, 3'b100, 1'b0, 5'b01100},
            {1'b0, 3'b100, 1'b0, 5'b01101},
            {1'b0, 3'b100, 1'b0, 5'b01110},
            {1'b0, 3'b100, 1'b0, 5'b01111},
            {1'b0, 3'b100, 1'b0, 5'b10000},
            {1'b0, 3'b100, 1'b0, 5'b10001},
            {1'b0, 3'b100, 1'b0, 5'b10010},
            {1'b0, 3'b100, 1'b0, 5'b10011},
            {1'b0, 3'b100, 1'b0, 5'b10100},
            {1'b0, 3'b100, 1'b0, 5'b10101},
            {1'b0, 3'b100, 1'b0, 5'b10110},
            {1'b0, 3'b100, 1'b0, 5'b10111},
            {1'b0, 3'b100, 1'b0, 5'b11000},
            {1'b0, 3'b100, 1'b0, 5'b11001},
            {1'b0, 3'b100, 1'b0, 5'b11010},
            {1'b0, 3'b100, 1'b0, 5'b11011},
            {1'b0, 3'b100, 1'b0, 5'b11100},
            {1'b0, 3'b100, 1'b0, 5'b11101},
            {1'b0, 3'b100, 1'b0, 5'b11110}: begin
                selected_pattern = pattern_01010;
                pattern_length = 4'd5;
            end
            
            // pre=011, post=1 → always "0100010"
            {1'b0, 3'b011, 1'b1, 5'b00101},
            {1'b0, 3'b011, 1'b1, 5'b00110},
            {1'b0, 3'b011, 1'b1, 5'b00111},
            {1'b0, 3'b011, 1'b1, 5'b01000},
            {1'b0, 3'b011, 1'b1, 5'b01001},
            {1'b0, 3'b011, 1'b1, 5'b01010},
            {1'b0, 3'b011, 1'b1, 5'b01011},
            {1'b0, 3'b011, 1'b1, 5'b01100},
            {1'b0, 3'b011, 1'b1, 5'b01101},
            {1'b0, 3'b011, 1'b1, 5'b01110},
            {1'b0, 3'b011, 1'b1, 5'b01111},
            {1'b0, 3'b011, 1'b1, 5'b10000},
            {1'b0, 3'b011, 1'b1, 5'b10001},
            {1'b0, 3'b011, 1'b1, 5'b10010},
            {1'b0, 3'b011, 1'b1, 5'b10011},
            {1'b0, 3'b011, 1'b1, 5'b10100},
            {1'b0, 3'b011, 1'b1, 5'b10101},
            {1'b0, 3'b011, 1'b1, 5'b10110},
            {1'b0, 3'b011, 1'b1, 5'b10111},
            {1'b0, 3'b011, 1'b1, 5'b11000},
            {1'b0, 3'b011, 1'b1, 5'b11001},
            {1'b0, 3'b011, 1'b1, 5'b11010},
            {1'b0, 3'b011, 1'b1, 5'b11011},
            {1'b0, 3'b011, 1'b1, 5'b11100},
            {1'b0, 3'b011, 1'b1, 5'b11101},
            {1'b0, 3'b011, 1'b1, 5'b11110}: begin
                selected_pattern = pattern_0100010;
                pattern_length = 4'd7;
            end
            
            // pre=100, post=1 → always "010001010"
            {1'b0, 3'b100, 1'b1, 5'b00101},
            {1'b0, 3'b100, 1'b1, 5'b00110},
            {1'b0, 3'b100, 1'b1, 5'b00111},
            {1'b0, 3'b100, 1'b1, 5'b01000},
            {1'b0, 3'b100, 1'b1, 5'b01001},
            {1'b0, 3'b100, 1'b1, 5'b01010},
            {1'b0, 3'b100, 1'b1, 5'b01011},
            {1'b0, 3'b100, 1'b1, 5'b01100},
            {1'b0, 3'b100, 1'b1, 5'b01101},
            {1'b0, 3'b100, 1'b1, 5'b01110},
            {1'b0, 3'b100, 1'b1, 5'b01111},
            {1'b0, 3'b100, 1'b1, 5'b10000},
            {1'b0, 3'b100, 1'b1, 5'b10001},
            {1'b0, 3'b100, 1'b1, 5'b10010},
            {1'b0, 3'b100, 1'b1, 5'b10011},
            {1'b0, 3'b100, 1'b1, 5'b10100},
            {1'b0, 3'b100, 1'b1, 5'b10101},
            {1'b0, 3'b100, 1'b1, 5'b10110},
            {1'b0, 3'b100, 1'b1, 5'b10111},
            {1'b0, 3'b100, 1'b1, 5'b11000},
            {1'b0, 3'b100, 1'b1, 5'b11001},
            {1'b0, 3'b100, 1'b1, 5'b11010},
            {1'b0, 3'b100, 1'b1, 5'b11011},
            {1'b0, 3'b100, 1'b1, 5'b11100},
            {1'b0, 3'b100, 1'b1, 5'b11101},
            {1'b0, 3'b100, 1'b1, 5'b11110}: begin
                selected_pattern = pattern_010001010;
                pattern_length = 4'd9;
            end
            
            // Overflow case (gap_i = 31)
            {1'b0, 3'b???, 1'b?, 5'b11111}: begin
                // Use longest pattern for overflow condition
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
endmodule */