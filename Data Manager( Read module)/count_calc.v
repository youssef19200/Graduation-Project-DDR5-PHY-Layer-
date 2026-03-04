// File: count_calc.v
`timescale 1ns / 1ps
module count_calc (
    input wire read_crc_en_i,
    input wire phy_crc_mode_i,
    input wire seamless_i,
    input wire [1:0] bl_i,
    output reg [4:0] count_val_o
);
    always @(*) begin
        case ({read_crc_en_i, phy_crc_mode_i, seamless_i, bl_i})
            // BL8 cases
            5'b00000,
            5'b01000,
            5'b11000: count_val_o = 5'd4;
            5'b10000: count_val_o = 5'd9;

            // BL16, seamless = 1
            5'b00101, 5'b00110,
            5'b01101, 5'b01110,
            5'b10101, 5'b10110,
            5'b11101, 5'b11110: count_val_o = 5'd16;

            // BL16, seamless = 0
            5'b00001, 5'b00010,
            5'b01001, 5'b01010,
            5'b11001, 5'b11010: count_val_o = 5'd8;

            5'b10001, 5'b10010: count_val_o = 5'd9;

            default: count_val_o = 5'd0;
        endcase
    end
endmodule