// correct TB
// File: data_manager_tb.sv (GAP & OVERFLOW TESTING)
`timescale 1ns/1ps

module data_manager_tb;
    
    // Clock and Reset
    reg clk_i;
    reg reset_n_i;
    reg en_i;
    
    // Inputs
    reg [2:0] pre_amble_sett_i;
    reg [1:0] bl_i;
    reg post_amble_sett_i;
    reg read_crc_enable_i;
    reg phy_crc_mode_i;
    reg dfi_rddata_en;
    reg DQS_AD;
    reg [7:0] DQ_AD;
    
    // Outputs
    wire OVF;
    wire [7:0] dfi_rddata;
    wire dfi_rddata_valid;
    wire [2:0] saved_pre_amble_o;
    wire [1:0] saved_bl_o;
    wire saved_post_amble_o;
    wire saved_read_crc_enable_o;
    wire saved_phy_crc_mode_o;
    
    // Debug signals
    wire        pattern_detected;
    wire [1:0]  current_state;
    wire        gap_valid;
    logic [4:0]  gap_count;
    wire        fifo_write;
    
    // Global variables (FIXED DECLARATION ORDER)
    integer marker_file;
    logic [7:0] expected_data[16];
    logic [7:0] captured_data[16];
    logic [7:0] expected_data2[8];
    logic [7:0] captured_data2[8];
    int valid_count, data_errors, idx;
    int valid_count2, data_errors2, idx2;
    
    // DUT instantiation
    data_manager dut (
        .clk_i(clk_i),
        .reset_n_i(reset_n_i),
        .en_i(en_i),
        .pre_amble_sett_i(pre_amble_sett_i),
        .bl_i(bl_i),
        .post_amble_sett_i(post_amble_sett_i),
        .read_crc_enable_i(read_crc_enable_i),
        .phy_crc_mode_i(phy_crc_mode_i),
        .dfi_rddata_en(dfi_rddata_en),
        .DQS_AD(DQS_AD),
        .DQ_AD(DQ_AD),
        .OVF(OVF),
        .dfi_rddata(dfi_rddata),
        .dfi_rddata_valid(dfi_rddata_valid),
        .saved_pre_amble_o(saved_pre_amble_o),
        .saved_bl_o(saved_bl_o),
        .saved_post_amble_o(saved_post_amble_o),
        .saved_read_crc_enable_o(saved_read_crc_enable_o),
        .saved_phy_crc_mode_o(saved_phy_crc_mode_o)
    );
    
    // Debug signal connections
    assign pattern_detected = dut.u_pattern_detector.pattern_detected;
    assign current_state    = dut.current_state;
    assign gap_valid        = dut.u_gap_counter.gap_valid_reg;
   assign gap_count        = dut.u_gap_counter.saved_gap;
    assign fifo_write       = dut.u_gap_counter.fifo_write;
    
    // Clock generation
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end
    
    // Waveform marker task
    task add_marker(input string msg);
        $fdisplay(marker_file, "%0d %s", $time, msg);
    endtask
    
    // Main test program
    initial begin
        // Initialize counters FIRST 
        valid_count = 0; data_errors = 0; idx = 0;
        valid_count2 = 0; data_errors2 = 0; idx2 = 0;
        
        marker_file = $fopen("waveform_markers.txt", "w");
        $display("==========================================");
        $display("  DDR5 PHY DATA MANAGER TESTBENCH");
        $display("==========================================");
        add_marker("SIMULATION START");
        
        // Initialize inputs
        reset_n_i = 0; en_i = 0;
        pre_amble_sett_i = 3'b000; bl_i = 2'b00;
        post_amble_sett_i = 0; read_crc_enable_i = 0; phy_crc_mode_i = 0;
        dfi_rddata_en = 0; DQS_AD = 0; DQ_AD = 8'h00;
        
        #50; reset_n_i = 1; #20; en_i = 1; #30;

       
        
        
        // ========================================
        // TEST CASE 1: First Read (Baseline)
        // ========================================
        $display("\n=== TC1: FIRST READ (BL16, Preamble '10') ===");
        add_marker("TC1 START");
        
        pre_amble_sett_i = 3'b000;  // "10" preamble
        bl_i = 2'b00;               // BL16
        post_amble_sett_i = 0;
        read_crc_enable_i = 0;
        phy_crc_mode_i = 0;
        
        @(posedge clk_i); dfi_rddata_en = 1;
        @(posedge clk_i); dfi_rddata_en = 0;
        repeat(3) @(posedge clk_i);
        
     
        
        // Drive preamble "10"
        @(posedge clk_i); DQS_AD = 1; DQ_AD = 8'hAA;
        @(posedge clk_i); DQS_AD = 0; DQ_AD = 8'h00;
        repeat(2) @(posedge clk_i);
        
        
        for (int i = 0; i < 5; i++) begin
            @(posedge clk_i); DQS_AD = 1; DQ_AD = 8'hAA + i;
            @(posedge clk_i); DQS_AD = 0;
        end
        
        repeat(4) @(posedge clk_i);
        add_marker("TC1 COMPLETE");




        // =====================================================
        // TEST CASE 2
        // =====================================================
        $display("\nTEST CASE 2: BL16, PREAMBLE 10");
        add_marker("TEST CASE 2 START");
 
        pre_amble_sett_i = 3'b001; //0010
        bl_i = 2'b01;
       post_amble_sett_i = 0;
        read_crc_enable_i = 1;
        phy_crc_mode_i = 0;

        @(posedge clk_i);
        dfi_rddata_en = 1;
        @(posedge clk_i);
        dfi_rddata_en = 0;

        repeat(4) @(posedge clk_i);

    

        // preamble 0010
        @(posedge clk_i);
        DQS_AD = 0; DQ_AD = 8'h00;
        @(posedge clk_i);
        DQS_AD = 0; DQ_AD = 8'h00;
        @(posedge clk_i);
        DQS_AD = 1; DQ_AD = 8'hAA;
        @(posedge clk_i);
        DQS_AD = 0; DQ_AD = 8'h00;

       // repeat(2) @(posedge clk_i);

      
 
        for (int i = 0; i < 10; i++) begin
            @(posedge clk_i); DQS_AD = 1; DQ_AD = 8'hAA + i;
            @(posedge clk_i); DQS_AD = 0;
        end
        
        repeat(3) @(posedge clk_i);
        


        
        // ========================================
        // TEST CASE 3: Large Gap (min+3)
        // ========================================
        $display("\n=== TC3: LARGE GAP (min+3) ===");
        add_marker("TC3 START");
        
     
        
        pre_amble_sett_i = 3'b100;  // "00001010" preamble
        bl_i = 2'b00;               // BL16
        post_amble_sett_i = 0;
        read_crc_enable_i = 0;
        phy_crc_mode_i = 1; 

        @(posedge clk_i); dfi_rddata_en = 1;
        @(posedge clk_i); dfi_rddata_en = 0;
        repeat(3) @(posedge clk_i);
        
        
        // Drive preamble "10"
        @(posedge clk_i); DQS_AD = 1; DQ_AD = 8'hDD;
        @(posedge clk_i); DQS_AD = 0; DQ_AD = 8'h00;
         @(posedge clk_i); DQS_AD = 1; DQ_AD = 8'hDD;
        @(posedge clk_i); DQS_AD = 0; DQ_AD = 8'h00;
        repeat(2) @(posedge clk_i);
        
        
        
        for (int i = 0; i < 5; i++) begin
            @(posedge clk_i); DQS_AD = 1; DQ_AD = 8'hDD + i;
            @(posedge clk_i); DQS_AD = 0;
        end
   
       repeat(6) @(posedge clk_i);
        add_marker("TC4 COMPLETE");
        
        // ========================================
        // TEST CASE 4: OVERFLOW GAP (32+ cycles)
        // ========================================
        $display("\n=== TC4: OVERFLOW GAP (32 cycles) ===");
        add_marker("TC4 START - OVERFLOW TEST");
        
      
    
        pre_amble_sett_i = 3'b001;  // "10" preamble
        bl_i = 2'b10;               // BL16
        post_amble_sett_i = 0;
        read_crc_enable_i = 1;
        phy_crc_mode_i = 1;

        @(posedge clk_i); dfi_rddata_en = 1;
        @(posedge clk_i); dfi_rddata_en = 0;
        repeat(2) @(posedge clk_i);
        
        // Drive preamble "10"
        @(posedge clk_i); DQS_AD = 1; DQ_AD = 8'hEE;
        @(posedge clk_i); DQS_AD = 0; DQ_AD = 8'h00;
        repeat(2) @(posedge clk_i);
        
        
        for (int i = 0; i < 7; i++) begin
            @(posedge clk_i); DQS_AD = 1; DQ_AD = 8'hEE + i;
            @(posedge clk_i); DQS_AD = 0;
        end
       // repeat(15) @(posedge clk_i);
        add_marker("TC5 COMPLETE");
   
        #100; $stop;
    end
    
    // Valid counter with edge detection
    logic prev_valid;
    always @(posedge clk_i) begin
        prev_valid <= dfi_rddata_valid;
        if (!prev_valid && dfi_rddata_valid) 
            $display("[TIME %0t] >>> VALID START (state=%d) <<<", $time, current_state);
        if (dfi_rddata_valid) valid_count++;
        if (prev_valid && !dfi_rddata_valid) 
            $display("[TIME %0t] >>> VALID END (duration=%0d cycles) <<<", $time, valid_count);
    end
    

    
    // Waveform dump
    initial begin
        $dumpfile("data_manager_tb.vcd");
        $dumpvars(0, data_manager_tb);
    end


endmodule