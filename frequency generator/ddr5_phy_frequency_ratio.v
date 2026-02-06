/*********************************************************************************************
** File Name   : ddr5_phy_frequency_ratio.v
** Author      : Youssef Ehab
** Created on  : Jan 2026
** Edited on   : 
** description : FREQUENCY RATIO Block that maps the input signal phases into one phase
                 at the output according to the frequency ratio determined at initialization
**********************************************************************************************/
module ddr5_phy_frequency_ratio #(
    parameter pNUM_RANK  = 1,
    parameter pDRAM_SIZE = 8   // x4, x16, *x8* DDR5
) (
    input  wire                         clk_i, rst_i, enable_i,
    input  wire [1:0]                   dfi_freq_ratio_i,

    // Command/Address Phased Inputs
    input  wire [pNUM_RANK-1:0]         dfi_cs_n_p0_i, dfi_cs_n_p1_i, dfi_cs_n_p2_i, dfi_cs_n_p3_i,
    input  wire [pNUM_RANK-1:0]         dfi_reset_n_p0_i, dfi_reset_n_p1_i, dfi_reset_n_p2_i, dfi_reset_n_p3_i,
    input  wire [13:0]                  dfi_address_p0_i, dfi_address_p1_i, dfi_address_p2_i, dfi_address_p3_i,
    
    // Write Data Phased Inputs
    input  wire                         dfi_wrdata_en_p0_i, dfi_wrdata_en_p1_i, dfi_wrdata_en_p2_i, dfi_wrdata_en_p3_i,
    input  wire [(2*pDRAM_SIZE)-1:0]    dfi_wrdata_p0_i, dfi_wrdata_p1_i, dfi_wrdata_p2_i, dfi_wrdata_p3_i,
    input  wire [(pDRAM_SIZE/4)-1:0]    dfi_wrdata_mask_p0_i, dfi_wrdata_mask_p1_i, dfi_wrdata_mask_p2_i, dfi_wrdata_mask_p3_i,

    // Serial Inputs from PHY Internal
    input  wire [(2*pDRAM_SIZE)-1:0]    dfi_rddata_i,
    input  wire                         dfi_rddata_valid_i,
    input  wire                         dfi_alert_n_i,

    // Serialized Outputs
    output wire [pNUM_RANK-1:0]         dfi_cs_n_o,
    output wire [pNUM_RANK-1:0]         dfi_reset_n_o,
    output wire [13:0]                  dfi_address_o,
    output wire                         dfi_wrdata_en_o,
    output wire [(2*pDRAM_SIZE)-1:0]    dfi_wrdata_o,
    output wire [(pDRAM_SIZE/4)-1:0]    dfi_wrdata_mask_o,

    // Phased Outputs to Controller
    output wire [(2*pDRAM_SIZE)-1:0]    dfi_rddata_w0_o, dfi_rddata_w1_o, dfi_rddata_w2_o, dfi_rddata_w3_o,
    output wire                         dfi_rddata_valid_w0_o, dfi_rddata_valid_w1_o, dfi_rddata_valid_w2_o, dfi_rddata_valid_w3_o,
    output wire                         dfi_alert_n_a0_o, dfi_alert_n_a1_o, dfi_alert_n_a2_o, dfi_alert_n_a3_o
);

    // Phase Control Logic
    reg  [1:0] phase_select;
    wire [1:0] last_phase;
    wire       count_done;

    assign last_phase[0] = dfi_freq_ratio_i[1] | dfi_freq_ratio_i[0];
    assign last_phase[1] = dfi_freq_ratio_i[1];
    assign count_done    = (phase_select == last_phase);
/*

    Ratio              dfi_freq_ratio_i             last_phase
                         [1]    [0]                  [1]  [0]
     1:1                  0      0                    0    0
     1:2                  0      1                    0    1
     1:4                  1      0                    1    1

*/


    always @(posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            phase_select <= 2'b00;
        end else if (enable_i) begin
            if (count_done) phase_select <= 2'b00;
            else            phase_select <= phase_select + 2'b01;
        end
    end

    // --- Serializer Instantiations (TX Path) ---

    ddr5_serializer_unit #(.WIDTH(pNUM_RANK)) u_ser_cs (
        .clk_i(clk_i), .rst_i(rst_i), .enable_i(enable_i), .phase_sel_i(phase_select),
        .p0_i(dfi_cs_n_p0_i), .p1_i(dfi_cs_n_p1_i), .p2_i(dfi_cs_n_p2_i), .p3_i(dfi_cs_n_p3_i),
        .data_o(dfi_cs_n_o)
    );

    ddr5_serializer_unit #(.WIDTH(pNUM_RANK)) u_ser_rst (
        .clk_i(clk_i), .rst_i(rst_i), .enable_i(enable_i), .phase_sel_i(phase_select),
        .p0_i(dfi_reset_n_p0_i), .p1_i(dfi_reset_n_p1_i), .p2_i(dfi_reset_n_p2_i), .p3_i(dfi_reset_n_p3_i),
        .data_o(dfi_reset_n_o)
    );

    ddr5_serializer_unit #(.WIDTH(14)) u_ser_addr (
        .clk_i(clk_i), .rst_i(rst_i), .enable_i(enable_i), .phase_sel_i(phase_select),
        .p0_i(dfi_address_p0_i), .p1_i(dfi_address_p1_i), .p2_i(dfi_address_p2_i), .p3_i(dfi_address_p3_i),
        .data_o(dfi_address_o)
    );

    ddr5_serializer_unit #(.WIDTH(1)) u_ser_wren (
        .clk_i(clk_i), .rst_i(rst_i), .enable_i(enable_i), .phase_sel_i(phase_select),
        .p0_i(dfi_wrdata_en_p0_i), .p1_i(dfi_wrdata_en_p1_i), .p2_i(dfi_wrdata_en_p2_i), .p3_i(dfi_wrdata_en_p3_i),
        .data_o(dfi_wrdata_en_o)
    );

    ddr5_serializer_unit #(.WIDTH(2*pDRAM_SIZE)) u_ser_wrdata (
        .clk_i(clk_i), .rst_i(rst_i), .enable_i(enable_i), .phase_sel_i(phase_select),
        .p0_i(dfi_wrdata_p0_i), .p1_i(dfi_wrdata_p1_i), .p2_i(dfi_wrdata_p2_i), .p3_i(dfi_wrdata_p3_i),
        .data_o(dfi_wrdata_o)
    );

    ddr5_serializer_unit #(.WIDTH(pDRAM_SIZE/4)) u_ser_mask (
        .clk_i(clk_i), .rst_i(rst_i), .enable_i(enable_i), .phase_sel_i(phase_select),
        .p0_i(dfi_wrdata_mask_p0_i), .p1_i(dfi_wrdata_mask_p1_i), .p2_i(dfi_wrdata_mask_p2_i), .p3_i(dfi_wrdata_mask_p3_i),
        .data_o(dfi_wrdata_mask_o)
    );

    // --- Deserializer Instantiations (RX Path) ---

    ddr5_deserializer_unit #(.WIDTH(2*pDRAM_SIZE)) u_des_rddata (
        .clk_i(clk_i), .rst_i(rst_i), .enable_i(enable_i), .phase_sel_i(phase_select), .count_done_i(count_done),
        .serial_i(dfi_rddata_i),
        .p0_o(dfi_rddata_w0_o), .p1_o(dfi_rddata_w1_o), .p2_o(dfi_rddata_w2_o), .p3_o(dfi_rddata_w3_o)
    );

    ddr5_deserializer_unit #(.WIDTH(1)) u_des_valid (
        .clk_i(clk_i), .rst_i(rst_i), .enable_i(enable_i), .phase_sel_i(phase_select), .count_done_i(count_done),
        .serial_i(dfi_rddata_valid_i),
        .p0_o(dfi_rddata_valid_w0_o), .p1_o(dfi_rddata_valid_w1_o), .p2_o(dfi_rddata_valid_w2_o), .p3_o(dfi_rddata_valid_w3_o)
    );

    ddr5_deserializer_unit #(.WIDTH(1), .IS_ALERT(1)) u_des_alert (
        .clk_i(clk_i), .rst_i(rst_i), .enable_i(enable_i), .phase_sel_i(phase_select), .count_done_i(count_done),
        .serial_i(dfi_alert_n_i),
        .p0_o(dfi_alert_n_a0_o), .p1_o(dfi_alert_n_a1_o), .p2_o(dfi_alert_n_a2_o), .p3_o(dfi_alert_n_a3_o)
    );

endmodule