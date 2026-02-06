
// File: pattern_detector_fixed.v
`timescale 1ns/1ps
module pattern_detector (
    input clk_i,
    input reset_n_i,
    input en_i,
    input DQS_AD,
    input [2:0] pre_amble_sett_i,
    output reg pattern_detected
);
    reg [3:0] shift_reg;
    reg [1:0] current_state;
    localparam IDLE = 2'b00, SHIFTING = 2'b01, DETECTED = 2'b10;
    
    wire [1:0] expected_pattern;
    assign expected_pattern = 2'b10; // "10" = MSB=1, LSB=0
    
    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            shift_reg <= 4'b0000;
            current_state <= IDLE;
            pattern_detected <= 1'b0;
        end else begin
            pattern_detected <= 1'b0; 
            
            case (current_state)
                IDLE: begin
                    shift_reg <= 4'b0000;
                    current_state <= SHIFTING;
                end
                
                SHIFTING: begin
                    shift_reg <= {shift_reg[2:0], DQS_AD};
                    
                    if (shift_reg[1:0] == expected_pattern) begin
                        current_state <= DETECTED;
                    end
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
