/*************************************************************************************************************
File Name : ddr5_write_module testbench 
Author : Yousef Gamal Saber 
Created on : Jan 2026 
**************************************************************************************************************/
module test_bench () ;
parameter pDRAM_SIZE = 4 ;
// inputs
    logic clk_i;
    logic rst_i;
    logic enable_i;
    logic wr_en;
    logic phy_crc_mode;
    logic dram_crc_en;
    logic [1:0] burstlength;
    logic [2:0] precycle;
    logic [1:0] postcycle;
    logic [2*pDRAM_SIZE-1:0] wr_data;
    logic [(pDRAM_SIZE/4-1):0] wr_datamask;
    logic [7:0] pre_pattern;
    logic [2*pDRAM_SIZE-1:0] crc_code;   // start 
    logic preamble_done_i ; 
    logic crc_generate_i ;
    logic data_burst_done_i ; 
    logic wrdata_done_i ;
    logic interamble_i ;
// outputs
    logic [2*pDRAM_SIZE-1:0] dq;
    logic dq_valid;
    logic [(pDRAM_SIZE/4-1):0] dm;
    logic [1:0] dqs;
    logic dqs_valid;
    logic [2*pDRAM_SIZE-1:0] crc_data;
    logic crc_enable;     /// start 
    logic interamble_valid_o ;
    logic data_state_O ;
    logic preamble_state_o ;

  // Instantiate DUT
write_manager #(.pDRAM_SIZE( pDRAM_SIZE )) Dut (
.clk_i          (clk_i),
.rst_i          (rst_i),

.enable_i       (enable_i),
.wr_en_i        (wr_en),
.phy_crc_mode_i (phy_crc_mode),
.dram_crc_en_i  (dram_crc_en),
.burstlength_i  (burstlength),
.precycle_i     (precycle),
.postcycle_i    (postcycle),
.wr_data_i      (wr_data),
.wr_datamask_i  (wr_datamask),
.pre_pattern_i  (pre_pattern),
.crc_code_i     (crc_code),
.dq_o           (dq),
.dq_valid_o     (dq_valid),
.dm_o           (dm),
.dqs_o          (dqs),
.dqs_valid_o    (dqs_valid),
.crc_data_o     (crc_data),
.crc_enable_o   (crc_enable)
// .preamble_done_i (preamble_done_i),
// .crc_generate_i (crc_generate_i) ,
// .data_burst_done_i (data_burst_done_i) ,
 // .wrdata_done_i (wrdata_done_i) ,
//.interamble_i(interamble_i) ,
//.interamble_valid_o (interamble_valid_o),
//.data_state_O (data_state_O) ,
//.preamble_state_o (preamble_state_o) 
);
// Clock Generation 
  initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
  end

 initial begin
// Initialize
        rst_i = 0;
        enable_i = 0;
        wr_en = 0;
        phy_crc_mode = 0;
        dram_crc_en = 0;
        burstlength = 2'b00;
        precycle = 3'd2;
        postcycle = 2'd1;
        wr_data = 8'hA5;
        wr_datamask = 1'b0;
        pre_pattern = 8'b10101000;
        crc_code = 8'h3C;
    #10
 // disable reset , Activate enable
    rst_i =1;
    enable_i = 1;
    wr_en = 0;
          /*  dq  = {(2*pDRAM_SIZE){1'b0}} ;
		   dq_valid = 1'b0 ;
		   dm = {(pDRAM_SIZE /4){1'b0}} ;			
		   dqs = 2'b00 ;
		   interamble_valid_o= 1'b0 ;
		   dqs_valid = 1'b0 ;	
		   data_state_o  = 1'b0 ;
		   preamble_state_o = 1'b0 ;
		   crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
           crc_enable_o = 1'b0 ;  */
    #10 
  wr_en = 1 ;
             /*  dq = {(2*pDRAM_SIZE){1'b0}};
		        dq_valid = 1'b0 ;
			    dm = {(pDRAM_SIZE /4){1'b0}} ;				      
             	dqs = preamble_bits_i ;
				interamble_valid_o= 1'b0 ;
			    dqs_valid = preamble_valid_i ;
				data_state_o  = 1'b0 ;
				preamble_state_o = 1'b1 ;
			    crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
                crc_enable_o = 1'b0 ; */
#10 
preamble_done_i = 1 ;
crc_generate_i = 0 ;
                 /*   dq= wr_data_i ;
		            dq_valid = 1'b1 ;
			        dm = wr_datamask_i  ;			         
					dqs = 2'b10 ;
				    interamble_valid_o= 1'b0 ;
			        dqs_valid = 1'b1 ;	
					data_state_o  = 1'b1 ;
					preamble_state_o = 1'b0 ;
			        crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
                    crc_enable_o = 1'b0 ; */

#10 
preamble_done_i = 1 ;
crc_generate_i = 1 ;
                 /*   dq= wr_data_i ;              
		            dq_valid = 1'b1 ;
			        dm = {(pDRAM_SIZE /4){1'b0}}  ;			      
			        dqs = 2'b10 ;
				    interamble_valid_o= 1'b0 ;
			        dqs_valid = 1'b1 ;	
                    crc_data_o = wr_data_i ;
                    crc_enable_o = 1'b1 ;	
				    data_state_o = 1'b1 ;
				    preamble_state_o = 1'b0 ; */
#10
burstlength = 2'b01 ;
data_burst_done_i = 1 ;
                  /*  dq  = {(2*pDRAM_SIZE){1'b1}} ;   // rest of wr_data will be completed with ones and sent it on dq bus because the default is 16 so we fill the remaining 8 its with 1 and send this ones to crc block to calculate the crc code 
                    dq_valid = 1'b1 ; 
                    dm = {(pDRAM_SIZE /4){1'b0}}  ;			       
					dqs = 2'b10 ;
					interamble_valid_o= 1'b0 ;
					dqs_valid = 1'b1 ;	
				    crc_data_o = {(2*pDRAM_SIZE){1'b1}} ;
                    crc_enable_o = 1'b1 ;
					data_state_o = 1'b1 ;
					preamble_state_o= 1'b0 ; */
#10 
wrdata_done_i = 1 ;
                   /*  dq  = crc_code_i ;            				 
		            dq_valid = 1'b1 ;
			        dm = {(pDRAM_SIZE /4){1'b0}} ;			    
			        dqs = 2'b10 ;
				    interamble_valid_o = 1'b1 ;    // prepare interamble pattern  
			        dqs_valid = 1'b1 ;	
				    crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
				    crc_enable_o = 1'b1 ;
				    data_state_o = 1'b0 ;
			    	preamble_state_o = 1'b0 ; */
#10 
interamble_i = 1 ; 
                   /* dq = {(2*pDRAM_SIZE){1'b0}} ;
		            dq_valid = 1'b0 ;
			        dm = {(pDRAM_SIZE /4){1'b0}}  ;
			        dqs =  interamble_bits_i ;
				    interamble_valid_o= 1'b1 ;
			        dqs_valid = 1'b1 ;
					crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;                    
					data_state_o = 1'b0 ;
					preamble_state_o = 1'b0 ;
					crc_enable_o = 1'b0 ; */
#10 
$stop; 
end 
endmodule