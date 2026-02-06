/*********************************************************************************************
** File Name   : ddr5_deserializer_unit.v
** Author      : Youssef Ehab
** Created on  : Jan 2026
** Edited on   : 
** description : Desrialize serial data into parallel data
**********************************************************************************************/
module ddr5_deserializer_unit #(parameter WIDTH = 1, parameter IS_ALERT = 0) (
    input  wire              clk_i,
    input  wire              rst_i,
    input  wire              enable_i,
    input  wire [1:0]        phase_sel_i,
    input  wire              count_done_i,
    input  wire [WIDTH-1:0]  serial_i,
    output reg  [WIDTH-1:0]  p0_o,
    output reg  [WIDTH-1:0]  p1_o,
    output reg  [WIDTH-1:0]  p2_o,
    output reg  [WIDTH-1:0]  p3_o
);
    reg [WIDTH-1:0] temp_p0, temp_p1, temp_p2, temp_p3;
    reg             count_done_q;

    always @(posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            temp_p0 <= IS_ALERT ? {WIDTH{1'b1}} : {WIDTH{1'b0}};
            temp_p1 <= IS_ALERT ? {WIDTH{1'b1}} : {WIDTH{1'b0}};
            temp_p2 <= IS_ALERT ? {WIDTH{1'b1}} : {WIDTH{1'b0}};
            temp_p3 <= IS_ALERT ? {WIDTH{1'b1}} : {WIDTH{1'b0}};
            count_done_q <= 1'b0;
        end else if (enable_i) begin
            case (phase_sel_i)
                2'b00: temp_p0 <= serial_i;
                2'b01: temp_p1 <= serial_i;
                2'b10: temp_p2 <= serial_i;
                2'b11: temp_p3 <= serial_i;
            endcase
            count_done_q <= count_done_i;
        end
    end

    always @(posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            p0_o <= IS_ALERT ? {WIDTH{1'b1}} : {WIDTH{1'b0}};
            p1_o <= IS_ALERT ? {WIDTH{1'b1}} : {WIDTH{1'b0}};
            p2_o <= IS_ALERT ? {WIDTH{1'b1}} : {WIDTH{1'b0}};
            p3_o <= IS_ALERT ? {WIDTH{1'b1}} : {WIDTH{1'b0}};
        end else if (enable_i && count_done_q) begin
            p0_o <= temp_p0;
            p1_o <= temp_p1;
            p2_o <= temp_p2;
            p3_o <= temp_p3;
        end else if (IS_ALERT == 0) begin
            // Clear valid signals if not in a valid output cycle
            // This assumes WIDTH=1 for valid signals
            p0_o <= {WIDTH{1'b0}};
            p1_o <= {WIDTH{1'b0}};
            p2_o <= {WIDTH{1'b0}};
            p3_o <= {WIDTH{1'b0}};
        end
    end
endmodule