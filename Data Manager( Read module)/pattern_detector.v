// File: pattern_detector.v 
`timescale 1ns/1ps
module pattern_detector (
    input clk_i,
    input reset_n_i,
    input en_i,
    input DQS_AD,
    input [2:0] pre_amble_sett_i,
    input post_amble_sett_i,
    output reg pattern_detected
);
    reg [8:1] shift_reg;
    reg [1:0] current_state;
    localparam IDLE = 2'b00, SHIFTING = 2'b01, DETECTED = 2'b10;
    
    // CRITICAL FIX: Use REG instead of WIRE for procedural assignment
    reg [8:0] selected_pattern;
    reg [3:0] pattern_length;
    
    // Pattern configuration for all preamble types
    wire [8:0] pattern_10       = 9'b10_0000000;      // "10"
    wire [8:0] pattern_0010     = 9'b0010_00000;      // "0010"  
    wire [8:0] pattern_1110     = 9'b1110_00000;      // "1110"
    wire [8:0] pattern_000010   = 9'b000010_000;      // "000010"
    wire [8:0] pattern_00001010 = 9'b00001010_0;      // "00001010"

    // Select pattern based on input (procedural assignment → must be REG)
    always @(*) begin
        case (pre_amble_sett_i)
            3'b000: begin selected_pattern = pattern_10;       pattern_length = 4'd2; end
            3'b001: begin selected_pattern = pattern_0010;     pattern_length = 4'd4; end
            3'b010: begin selected_pattern = pattern_1110;     pattern_length = 4'd4; end
            3'b011: begin selected_pattern = pattern_000010;   pattern_length = 4'd6; end
            3'b100: begin selected_pattern = pattern_00001010; pattern_length = 4'd8; end
            default: begin selected_pattern = pattern_10;       pattern_length = 4'd2; end
        endcase
    end

    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            shift_reg <= 8'h00;
            current_state <= IDLE;
            pattern_detected <= 1'b0;
        end else begin
            pattern_detected <= 1'b0; 
            
            case (current_state)
                IDLE: begin
                    shift_reg <= 8'h00;
                    current_state <= SHIFTING;
                end
                
                SHIFTING: begin
                    shift_reg[8:2] <= shift_reg[7:1];
                    shift_reg[1] <= DQS_AD;
                    
                    // Compare based on pattern length (using REG variables)
                    case (pattern_length)
                        4'd2: if (shift_reg[2:1] == selected_pattern[8:7]) 
                                  current_state <= DETECTED;
                        4'd4: if (shift_reg[4:1] == selected_pattern[8:5]) 
                                  current_state <= DETECTED;
                        4'd6: if (shift_reg[6:1] == selected_pattern[8:3]) 
                                  current_state <= DETECTED;
                        4'd8: if (shift_reg[8:1] == selected_pattern[8:1]) 
                                  current_state <= DETECTED;
                        default: if (shift_reg[2:1] == selected_pattern[8:7]) 
                                    current_state <= DETECTED;
                    endcase
                end
                
                DETECTED: begin
                    pattern_detected <= 1'b1; 
                    current_state <= IDLE;    
                end
                
                default: current_state <= IDLE;
            endcase
        end
    end
endmodule



