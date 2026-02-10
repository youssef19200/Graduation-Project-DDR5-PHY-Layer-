module tb_ddr5_phy_command_address_read ();

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
  wire [2:0]  num_pre_cycle_o;
  wire num_post_cycle_o;
  wire        dram_crc_en_o;

  // Instantiate DUT
  ddr5_phy_command_address_read #(.pNUM_RANK(pNUM_RANK)) Dut (.*);

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
    dfi_address_i = 14'b00000000000000; // BL =00 
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000000000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000000001; // BL=01 
    #10 
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000000000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000000010; // BL = 10
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000000000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000000011; // BL=11
    #10
    // MR8
    dfi_cs_i = {pNUM_RANK{1'b0}}; 
    dfi_address_i = 14'b00000100000101;   
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000000000; // pre = 000 , post =0  
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000100000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000001000; // pre = 001 , post =0    
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000100000101;    
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000010000; // pre = 010 , post =0  
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}}; 
    dfi_address_i = 14'b00000100000101;  
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000011000; // pre = 011 , post =0     
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}}; 
    dfi_address_i = 14'b00000100000101;   
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000000100000; // pre = 100 , post =0    
    #10
    dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000100000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000010000000; // pre = 000 , post =1   
    #10
        dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000100000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000010001000; // pre = 001 , post =1   
    #10
        dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000100000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000010010000; // pre = 010 , post =1   
    #10
        dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000100000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000010011000; // pre = 011 , post =1   
    #10
        dfi_cs_i = {pNUM_RANK{1'b0}};
    dfi_address_i = 14'b00000100000101;
    #10
    dfi_cs_i = {pNUM_RANK{1'b1}}; 
    dfi_address_i = 14'b00000010100000; // pre = 100 , post =1   
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
    // read_command 
    dfi_cs_i = {pNUM_RANK{1'b0}}; 
    dfi_address_i = 14'b00000000001111; 
    #20           
    $stop;                          
    end
  endmodule
