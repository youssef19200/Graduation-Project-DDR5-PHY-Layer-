/*********************************************************************************************
** File Name   : ddr5_serializer_unit.v
** Author      : Youssef Ehab
** Created on  : Jan 2026
** Edited on   : 
** description : serialize parallel data into serial data
**********************************************************************************************/
module ddr5_serializer_unit #(parameter WIDTH = 1) (
    input  wire              clk_i,
    input  wire              rst_i,
    input  wire              enable_i,
    input  wire [1:0]        phase_sel_i,
    input  wire [WIDTH-1:0]  p0_i,
    input  wire [WIDTH-1:0]  p1_i,
    input  wire [WIDTH-1:0]  p2_i,
    input  wire [WIDTH-1:0]  p3_i,
    output reg  [WIDTH-1:0]  data_o
);
    always @(posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            data_o <= {WIDTH{1'b0}};
        end else if (enable_i) begin
            case (phase_sel_i)
                2'b00:   data_o <= p0_i;
                2'b01:   data_o <= p1_i;
                2'b10:   data_o <= p2_i;
                2'b11:   data_o <= p3_i;
                default: data_o <= p0_i;
            endcase
        end
    end
endmodule