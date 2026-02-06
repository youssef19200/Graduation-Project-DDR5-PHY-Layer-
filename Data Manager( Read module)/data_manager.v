









// File: data_manager.v (FINAL CORRECTED)
`timescale 1ns/1ps

module data_manager (
    input clk_i,
    input reset_n_i,
    input en_i,

    input [2:0] pre_amble_sett_i,
    input [1:0] bl_i,
    input post_amble_sett_i,
    input read_crc_enable_i,
    input phy_crc_mode_i,

    input dfi_rddata_en,
    input DQS_AD,
    input [7:0] DQ_AD,

    output wire OVF,                
    output reg [7:0] dfi_rddata,
    output reg dfi_rddata_valid,

    output reg [2:0] saved_pre_amble_o,
    output reg [1:0] saved_bl_o,
    output reg saved_post_amble_o,
    output reg saved_read_crc_enable_o,
    output reg saved_phy_crc_mode_o
);

    // =====================================================
    // FSM states
    // =====================================================
    localparam IDLE         = 2'b00;
    localparam WAIT_PATTERN = 2'b01;
    localparam SAMPLING     = 2'b10;
    localparam HOLD         = 2'b11;

    reg [1:0] current_state;
    reg [1:0] next_state;

    // =====================================================
    // Internal wires
    // =====================================================
    wire pattern_detected;
    wire gap_valid;
    wire [4:0] gap_count;
    wire fifo_write;
    wire gap_reset;
    
    // Count calculation signals
    wire [4:0] count_val;
    reg seamless_flag;              
    wire valid_counter_done;

    // =====================================================
    // GAP COUNTER (CORRECT PORT CONNECTIONS)
    // =====================================================
    gap_counter u_gap_counter (
        .clk(clk_i),
        .reset_n(reset_n_i),
        .rddata_en(dfi_rddata_en),
        .gap_valid(gap_valid),
        .gap_count(gap_count),
        .fifo_write(fifo_write),
        .overflow(OVF),             
        .reset(gap_reset)
    );
    
    // =====================================================
    // PATTERN DETECTOR (MATCHES YOUR ACTUAL MODULE PORTS)
    // =====================================================
    pattern_detector u_pattern_detector (
        .clk_i(clk_i),
        .reset_n_i(reset_n_i),
        .en_i(en_i),
        .DQS_AD(DQS_AD),            
        .pre_amble_sett_i(saved_pre_amble_o),
        .pattern_detected(pattern_detected)
        
    );

   //pattern_detector u_pattern_detector (
   // .clk_i(clk_i),
   // .reset_n_i(reset_n_i),
   // .en_i(en_i),
   // .DQS_AD(DQS_AD),
   // .pre_amble_sett_i(saved_pre_amble_o),  // Use SAVED settings
   // .pattern_detected(pattern_detected)
   //  );

    // =====================================================
    // COUNT CALCULATOR
    // =====================================================
    count_calc u_count_calc (
        .read_crc_en_i(saved_read_crc_enable_o),
        .phy_crc_mode_i(saved_phy_crc_mode_o),
        .seamless_i(seamless_flag),
        .bl_i(saved_bl_o),
        .count_val_o(count_val)
    );

    // =====================================================
    // VALID COUNTER
    // =====================================================
    valid_counter u_valid_counter (
        .clk(clk_i),
        .reset_n(reset_n_i),
        .en(current_state == SAMPLING),
        .count(count_val),
        .done(valid_counter_done),
        .reset(current_state != SAMPLING)
    );

    // =====================================================
    // SEAMLESS FLAG (gap < 3 cycles)
    // =====================================================
    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            seamless_flag <= 1'b0;
        end else if (fifo_write && gap_valid) begin
            seamless_flag <= (gap_count < 3'd3);
        end
    end

    // =====================================================
    // FIFO SETTINGS SAVE
    // =====================================================
    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            saved_pre_amble_o        <= 3'b000;
            saved_bl_o               <= 2'b00;
            saved_post_amble_o       <= 1'b0;
            saved_read_crc_enable_o  <= 1'b0;
            saved_phy_crc_mode_o     <= 1'b0;
        end
        else if (en_i && fifo_write && gap_valid) begin
            saved_pre_amble_o        <= pre_amble_sett_i;
            saved_bl_o               <= bl_i;
            saved_post_amble_o       <= post_amble_sett_i;
            saved_read_crc_enable_o  <= read_crc_enable_i;
            saved_phy_crc_mode_o     <= phy_crc_mode_i;
        end
    end

    // =====================================================
    // FSM sequential logic
    // =====================================================
    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i)
            current_state <= IDLE;
        else if (!en_i)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // =====================================================
    // FSM combinational logic
    // =====================================================
    always @(*) begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (dfi_rddata_en && gap_valid)
                    next_state = WAIT_PATTERN;
                else
                    next_state = IDLE;
            end

            WAIT_PATTERN: begin
                if (pattern_detected)
                    next_state = SAMPLING;
                else
                    next_state = WAIT_PATTERN;    
            end

            SAMPLING: begin
                if (valid_counter_done)
                    next_state = HOLD;
                else
                    next_state = SAMPLING;
            end

            HOLD: begin
                if (dfi_rddata_en && gap_valid)
                    next_state = WAIT_PATTERN;
                else
                    next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // =====================================================
    // DATA CAPTURE on DQS rising edge
    // =====================================================
    always @(posedge DQS_AD or negedge reset_n_i) begin
        if (!reset_n_i) begin
            dfi_rddata <= 8'h00;
        end
        else if (current_state == SAMPLING) begin
            dfi_rddata <= DQ_AD;
            
        end
    end

    // =====================================================
    // VALID generation
    // =====================================================
    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            dfi_rddata_valid <= 1'b0;
        end
        else begin
            if (current_state == SAMPLING && !valid_counter_done)
                dfi_rddata_valid <= 1'b1;
            else
                dfi_rddata_valid <= 1'b0;
        end
    end

endmodule
