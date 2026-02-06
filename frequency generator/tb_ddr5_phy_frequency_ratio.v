module tb_ddr5_phy_frequency_ratio;

  // ------------------------------------------------
  // 1. Parameters & Signals
  // ------------------------------------------------
  parameter pNUM_RANK  = 1;
  parameter pDRAM_SIZE = 8; // x8 Device

  // Inputs
  reg clk_i;
  reg rst_i;
  reg enable_i;
  reg [1:0] dfi_freq_ratio_i;

  // Write Path Inputs (Parallel phases)
  reg [pNUM_RANK-1:0] dfi_cs_n_p0_i, dfi_cs_n_p1_i, dfi_cs_n_p2_i, dfi_cs_n_p3_i;
  reg [pNUM_RANK-1:0] dfi_reset_n_p0_i, dfi_reset_n_p1_i, dfi_reset_n_p2_i, dfi_reset_n_p3_i;
  reg [13:0]          dfi_address_p0_i, dfi_address_p1_i, dfi_address_p2_i, dfi_address_p3_i;
  reg                 dfi_wrdata_en_p0_i, dfi_wrdata_en_p1_i, dfi_wrdata_en_p2_i, dfi_wrdata_en_p3_i;
  reg [(2*pDRAM_SIZE)-1:0] dfi_wrdata_p0_i, dfi_wrdata_p1_i, dfi_wrdata_p2_i, dfi_wrdata_p3_i;
  reg [(pDRAM_SIZE/4)-1:0] dfi_wrdata_mask_p0_i, dfi_wrdata_mask_p1_i, dfi_wrdata_mask_p2_i, dfi_wrdata_mask_p3_i;

  // Read Path Inputs (Serial) - THE FOCUS
  reg [(2*pDRAM_SIZE)-1:0] dfi_rddata_i;
  reg                      dfi_rddata_valid_i;
  reg                      dfi_alert_n_i;

  // Outputs
  wire [pNUM_RANK-1:0] dfi_cs_n_o;
  wire [pNUM_RANK-1:0] dfi_reset_n_o;
  wire [13:0]          dfi_address_o;
  wire                 dfi_wrdata_en_o;
  wire [(2*pDRAM_SIZE)-1:0] dfi_wrdata_o;
  wire [(pDRAM_SIZE/4)-1:0] dfi_wrdata_mask_o;

  // Read Path Outputs (Parallel) - THE FOCUS
  wire [(2*pDRAM_SIZE)-1:0] dfi_rddata_w0_o, dfi_rddata_w1_o, dfi_rddata_w2_o, dfi_rddata_w3_o;
  wire                      dfi_rddata_valid_w0_o, dfi_rddata_valid_w1_o, dfi_rddata_valid_w2_o, dfi_rddata_valid_w3_o;
  wire                      dfi_alert_n_a0_o, dfi_alert_n_a1_o, dfi_alert_n_a2_o, dfi_alert_n_a3_o;

  // ------------------------------------------------
  // 2. Instantiate the DUT (Device Under Test)
  // ------------------------------------------------
  ddr5_phy_frequency_ratio #(
      .pNUM_RANK(pNUM_RANK),
      .pDRAM_SIZE(pDRAM_SIZE)
  ) dut (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .enable_i(enable_i),
      .dfi_freq_ratio_i(dfi_freq_ratio_i),
      
      // Write Path Inputs
      .dfi_cs_n_p0_i(dfi_cs_n_p0_i), .dfi_cs_n_p1_i(dfi_cs_n_p1_i), .dfi_cs_n_p2_i(dfi_cs_n_p2_i), .dfi_cs_n_p3_i(dfi_cs_n_p3_i),
      .dfi_reset_n_p0_i(dfi_reset_n_p0_i), .dfi_reset_n_p1_i(dfi_reset_n_p1_i), .dfi_reset_n_p2_i(dfi_reset_n_p2_i), .dfi_reset_n_p3_i(dfi_reset_n_p3_i),
      .dfi_address_p0_i(dfi_address_p0_i), .dfi_address_p1_i(dfi_address_p1_i), .dfi_address_p2_i(dfi_address_p2_i), .dfi_address_p3_i(dfi_address_p3_i),
      .dfi_wrdata_en_p0_i(dfi_wrdata_en_p0_i), .dfi_wrdata_en_p1_i(dfi_wrdata_en_p1_i), .dfi_wrdata_en_p2_i(dfi_wrdata_en_p2_i), .dfi_wrdata_en_p3_i(dfi_wrdata_en_p3_i),
      .dfi_wrdata_p0_i(dfi_wrdata_p0_i), .dfi_wrdata_p1_i(dfi_wrdata_p1_i), .dfi_wrdata_p2_i(dfi_wrdata_p2_i), .dfi_wrdata_p3_i(dfi_wrdata_p3_i),
      .dfi_wrdata_mask_p0_i(dfi_wrdata_mask_p0_i), .dfi_wrdata_mask_p1_i(dfi_wrdata_mask_p1_i), .dfi_wrdata_mask_p2_i(dfi_wrdata_mask_p2_i), .dfi_wrdata_mask_p3_i(dfi_wrdata_mask_p3_i),
      
      // Read Path Inputs
      .dfi_rddata_i(dfi_rddata_i),
      .dfi_rddata_valid_i(dfi_rddata_valid_i),
      .dfi_alert_n_i(dfi_alert_n_i),
      
      // Write Path Outputs
      .dfi_cs_n_o(dfi_cs_n_o),
      .dfi_reset_n_o(dfi_reset_n_o),
      .dfi_address_o(dfi_address_o),
      .dfi_wrdata_en_o(dfi_wrdata_en_o),
      .dfi_wrdata_o(dfi_wrdata_o),
      .dfi_wrdata_mask_o(dfi_wrdata_mask_o),
      
      // Read Path Outputs
      .dfi_rddata_w0_o(dfi_rddata_w0_o), .dfi_rddata_w1_o(dfi_rddata_w1_o), .dfi_rddata_w2_o(dfi_rddata_w2_o), .dfi_rddata_w3_o(dfi_rddata_w3_o),
      .dfi_rddata_valid_w0_o(dfi_rddata_valid_w0_o), .dfi_rddata_valid_w1_o(dfi_rddata_valid_w1_o), .dfi_rddata_valid_w2_o(dfi_rddata_valid_w2_o), .dfi_rddata_valid_w3_o(dfi_rddata_valid_w3_o),
      .dfi_alert_n_a0_o(dfi_alert_n_a0_o), .dfi_alert_n_a1_o(dfi_alert_n_a1_o), .dfi_alert_n_a2_o(dfi_alert_n_a2_o), .dfi_alert_n_a3_o(dfi_alert_n_a3_o)
  );

  // ------------------------------------------------
  // 3. Clock Generation
  // ------------------------------------------------
  initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i; // 100MHz clock (Period 10ns)
  end

  // ------------------------------------------------
  // 4. Test Sequence
  // ------------------------------------------------
  initial begin
    // Initialize Inputs
    rst_i = 1;
    enable_i = 0;
    dfi_freq_ratio_i = 2'b10; // 1:4 
    dfi_rddata_i = 0;
    dfi_rddata_valid_i = 0;
    dfi_alert_n_i = 1; 
    
    // Init Write inputs to 0...
    dfi_address_p0_i = 0; dfi_address_p1_i = 0; dfi_address_p2_i = 0; dfi_address_p3_i = 0;
    // ... (Assume other write inputs 0 for simplicity)

    // Apply Reset
    #10 rst_i = 0; // Active Low Reset
    #20 rst_i = 1; // Release Reset
    #10;

    $display("--- Starting Test Case 1: Read Path (1:4 Ratio) ---");
    
    enable_i = 1;
    dfi_freq_ratio_i = 2'b10;
    dfi_address_p0_i = 14'h0001;
    dfi_address_p1_i = 14'h0002;
    dfi_address_p2_i = 14'h0003;
    dfi_address_p3_i = 14'h0004;
    @(negedge clk_i);
    // Cycle 0 (Phase 0)
    dfi_rddata_valid_i = 1;
    dfi_rddata_i = 16'hAAAA; // Data for W0
    dfi_alert_n_i = 0;       // Alert Active for W0
    @(negedge clk_i); 

    // Cycle 1 (Phase 1)
    dfi_rddata_i = 16'hBBBB; // Data for W1
    dfi_alert_n_i = 1;       // Alert Inactive for W1
    @(negedge clk_i);

    // Cycle 2 (Phase 2)
    dfi_rddata_i = 16'hCCCC; // Data for W2
    dfi_alert_n_i = 0;       // Alert Active for W2
    @(negedge clk_i);

    // Cycle 3 (Phase 3) - LAST PHASE
    dfi_rddata_i = 16'hDDDD; // Data for W3
    dfi_alert_n_i = 1;       // Alert Inactive for W3
    @(negedge clk_i);
    dfi_address_p0_i = 14'h000A;
    dfi_address_p1_i = 14'h000B;
    dfi_address_p2_i = 14'h000C;
    dfi_address_p3_i = 14'h000D;
    dfi_rddata_i = 16'h1111;
    @(negedge clk_i);
    
    // Cycle 4: Idle Input
    dfi_rddata_valid_i = 0;
    dfi_rddata_i = 16'h0000;
    
    @(negedge clk_i); // Wait for registered output

    repeat(5) @(negedge clk_i);
    
    // Reset Data Inputs
    dfi_rddata_valid_i = 1;
    
    // Send 2 words
    dfi_rddata_i = 16'h1111; // Phase 0
    @(negedge clk_i);
    dfi_rddata_i = 16'h2222; // Phase 1
    @(negedge clk_i);
    
    dfi_rddata_valid_i = 0;
    @(negedge clk_i); 
    @(negedge clk_i);

    $display("--- Test Completed ---");
    $stop;
  end

endmodule