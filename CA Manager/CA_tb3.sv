module tb_ddr5_phy_command_address();

  // Parameters
  parameter pNUM_RANK = 1;

  // Signals
  logic clk_i;
  logic rst_i;
  logic enable_i;
  logic [13:0] dfi_address_i;
  logic [pNUM_RANK-1:0] dfi_cs_i;

  // Outputs
  wire [pNUM_RANK-1:0] chip_select_o;
  wire [13:0] command_address_o;
  wire [1:0]  burst_length_o;
  wire [7:0]  pre_pattern_o;
  wire [2:0]  num_pre_cycle_o;
  wire [1:0]  num_post_cycle_o;
  wire        dram_crc_en_o;

  // Instantiate DUT
  ddr5_phy_command_address #(.pNUM_RANK(pNUM_RANK)) Dut (.*);

  // Clock Generation 
  initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
  end
    initial begin
    // Initialize
    rst_i = 0;
    enable_i = 0;
    dfi_address_i = 14'b00000000000000;
    dfi_cs_i = {pNUM_RANK{1'b1}};
    #10
    // disable reset , Activate enable
    rst_i =1;
    enable_i = 1;
    // MR0
    dfi_cs_i = {pNUM_RANK{1'b0}}; 
    dfi_address_i = 14'b00000000000101;   
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000000000; // BL =0  
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000000000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000000001; // BL=1  
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000000000101;    
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000000010; // BL=2  
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}}; 
    dfi_address_i = 14'b00000000000101;  
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000000011; // BL=3  
    #10
    // MR8
    dfi_cs_i = {pNUM_RANK{1'b0}}; 
    dfi_address_i = 14'b00000100000101;   
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000001000; // BL =0  
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000100000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000010000; // BL=1  
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000100000101;    
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000011000; // BL=2  
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}}; 
    dfi_address_i = 14'b00000100000101;  
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000010001000; // BL=3    
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}}; 
    dfi_address_i = 14'b00000100000101;   
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000010010000; // BL =0  
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000100000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000010011000; // BL=1  
    #10
    //MR50
    dfi_cs_i = {pNUM_RANK{1'b0}}; 
    dfi_address_i = 14'b00011001000101;   
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000000000; // CRC_en = 0 
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00011001000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000000001; // CRC_en = 1 
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00011001000101;    
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000000010; // CRC_en = 1
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}}; 
    dfi_address_i = 14'b00011001000101;  
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000000011; // CRC_en = 1 
    #10   
    // write_read_command 
    dfi_cs_i = {pNUM_RANK{1'b0}}; 
    dfi_address_i = 14'b00000000001101; // CRC_en = 1 
    #20           
    $stop;                          
    end
  endmodule