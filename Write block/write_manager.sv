/*************************************************************************************************************
File Name : ddr5_write_manager module 
Author : Yousef Gamal Saber 
Created on : Jan 2026 
**************************************************************************************************************/
module write_manager # (parameter pDRAM_SIZE =4 ) 
(clk_i,rst_i,enable_i,wr_en_i,phy_crc_mode_i,dram_crc_en_i,burstlength_i,precycle_i,postcycle_i,wr_data_i,wr_datamask_i,pre_pattern_i,crc_code_i,dq_o,dq_valid_o,dm_o,dqs_o,dqs_valid_o,crc_data_o,crc_enable_o) ;

// input signals 
            input logic		 clk_i  ;
  			input logic		 rst_i  ;
			input logic		 enable_i  ;
			input logic		 wr_en_i ;
			input logic       phy_crc_mode_i ;
			input logic       dram_crc_en_i ;
			input logic		[1:0] burstlength_i ;
			input logic     	[2:0] precycle_i ;
			input logic     	[1:0] postcycle_i ;
			input logic 		[2*pDRAM_SIZE -1: 0] wr_data_i ;
			input logic		[(pDRAM_SIZE/4 -1):0] wr_datamask_i ;
			input logic 		[7:0] pre_pattern_i ;
			input logic 		[2*pDRAM_SIZE -1: 0] crc_code_i ;
// output signals 
            output logic		[2*pDRAM_SIZE -1:0] dq_o ;
			output logic 	    dq_valid_o ;
			output logic    	[(pDRAM_SIZE /4 -1):0] dm_o ;		 
			output logic		[1:0] dqs_o ;
			output logic    	dqs_valid_o ;
			output logic  	[2*pDRAM_SIZE -1:0] crc_data_o ;
			output logic    	crc_enable_o  ;
// internal signals and registers
            logic			preamble_valid   ;
            logic			preamble_done    ;				  
            logic			postamble_done   ;			 
            logic			interamble_done  ;			   
            logic			wrdata_crc_done  ;			   
            logic			wrdata_done ;			 
            logic			data_burst_done  ;			 
            logic			wrmask_done ;					   
            logic			crc_generate ; 			  
            logic			interamble ;			   
            logic	[1:0] 	preamble_bits ;			 
            logic	[1:0] 	interamble_bits  ;			 
            logic	[3:0] 	gap ; 
            logic			interamble_valid ;
            logic	[2:0] 	interamble_shift ; 
            logic 		preamble_load ;
            logic 		preamble_state  ;
            logic 		data_state ; 
            logic 		gap_burst_eight ; 
////////////////////////////////////////////////////////////////////////////////////////////////////////
write_fsm #( .pDRAM_SIZE(pDRAM_SIZE)) write_fsm_U (
// input signals 
.clk_i  			(clk_i),				  
.rst_i 				(rst_i),				  
.enable_i 			(enable_i) ,					
.wr_en_i 			(wr_en_i),					
.preamble_valid_i 	(preamble_valid),	/////////////////			 
// .preamble_done_i 	(preamble_done),				  
.postamble_done_i  	(postamble_done) ,			 
.interamble_done_i  (interamble_done) ,		   
.wrdata_crc_done_i  (wrdata_crc_done),			   
// .wrdata_done_i   	(wrdata_done) ,			 
// .data_burst_done_i  (data_burst_done) ,			 
.wrmask_done_i  	(wrmask_done) ,					   
// .crc_generate_i  	(crc_generate) , 			  
// .interamble_i 		(interamble),			   
.preamble_bits_i 	(preamble_bits)  ,			 
.interamble_bits_i 	(interamble_bits) ,			 
.gap_i   			(gap) , 			  
.wr_data_i 			(wr_data_i) ,			 
.wr_datamask_i 		(wr_datamask_i),			 
.crc_code_i 		(crc_code_i)  , 
.burstlength_i 		(burstlength_i),
// output signals 
// .data_state_o  		(data_state) ,
// .preamble_state_o	(preamble_state)  ,
.crc_data_o 		(crc_data_o),			 
.crc_enable_o 		(crc_enable_o),			 
.dqs_o 				(dqs_o),			 
.dq_o 				(dq_o),			 
.dqs_valid_o 		(dqs_valid_o) ,			 
.dq_valid_o 		(dq_valid_o),			 
.dm_o  				(dm_o) 	 
// .interamble_valid_o (interamble_valid)
) ; 

write_counter write_counters_U (
// input signals 
.clk_i 				(clk_i),
.rst_i  			(rst_i),
.wr_en_i   			(wr_en_i)      ,
.phy_crc_mode_i 	(phy_crc_mode_i) ,
.dram_crc_en_i   	(dram_crc_en_i),
.precycle_i    		(precycle_i)  ,
.postcycle_i    	(postcycle_i) ,
.gap_i      		(gap)     ,
.burstlength_i   	(burstlength_i),
.data_state_i  		(data_state)   ,
.preamble_state_i   (preamble_state )  ,
.interamble_valid_i (interamble_valid)  ,
// output signals 
.preamble_load_o 	(preamble_load),	
.preamble_valid_o	(preamble_valid) ,	
.preamble_done_o  	(preamble_done) ,	
.postamble_done_o 	(postamble_done) ,
.interamble_done_o 	(interamble_done) ,
.data_burst_done_o 	(data_burst_done) ,
.wrdata_done_o    	(wrdata_done) ,
.wrmask_done_o    	(wrmask_done) ,
.interamble_o     	(interamble) ,
.gap_burst_eight_o	(gap_burst_eight) ,
.crc_generate_o   	(crc_generate) ,
.interamble_shift_o (interamble_shift) ,
.wrdata_crc_done_o 	(wrdata_crc_done) 
) ;

write_shift write_shift_U (
// input signals 
.clk_i 				(clk_i) ,
.rst_i  			(rst_i),
.wr_en_i 			(wr_en_i),
.pre_pattern_i 		(pre_pattern_i),
.interamble_valid_i (interamble_valid) ,
.interamble_shift_i (interamble_shift) ,
.preamble_valid_i  	(preamble_valid) ,
.preamble_load_i 	(preamble_load),
.gap_burst_eight_i 	(gap_burst_eight),

// output signals 
.interamble_bits_o  (interamble_bits) ,
.preamble_bits_o 	(preamble_bits) ,
.gap_o 				(gap)
) ;

endmodule 