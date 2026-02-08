/*************************************************************************************************************
File Name : ddr5_write_counter module 
Author : Yousef Gamal Saber 
Created on : Jan 2026 
**************************************************************************************************************/

module write_counter (clk_i,rst_i,wr_en_i,phy_crc_mode_i,dram_crc_en_i,precycle_i,postcycle_i,gap_i,burstlength_i,data_state_i,preamble_state_i,interamble_valid_i,preamble_valid_o,interamble_shift_o,preamble_done_o,postamble_done_o,interamble_done_o,data_burst_done_o,wrdata_done_o,wrmask_done_o,interamble_o,crc_generate_o,preamble_load_o,gap_burst_eight_o,wrdata_crc_done_o) ;

// the input signals 
input logic clk_i,rst_i,wr_en_i,interamble_valid_i ; 
input logic phy_crc_mode_i ; // this bit determine which will generate the CRC code MC or PHY 
input logic dram_crc_en_i ; // this bit determine if the dram need the crc code with the data or not 
input logic [2:0] precycle_i ; // this determine the number of cycles needed before sending the data
input logic [1:0] postcycle_i ; // this determine the number of cycles needed after sending the data
input logic [3:0] gap_i ; // this determine the number of cycles where the write enable is low 
input logic [1:0] burstlength_i ; // this determine the number of bits coming from the MC 
input logic data_state_i,preamble_state_i ; // there are to determine the actual state if it data or preamble 

// output signals 

output logic preamble_valid_o ; // this bit say that the current state is preamble state 
output logic [2:0] interamble_shift_o ; // this signal determine the actual bits of the interamble pattern 
output logic preamble_done_o ; // represent the finish of the preamble state 
output logic postamble_done_o ; // represent the finish of the postamble state 
output logic interamble_done_o ; // represent the finish of the interamble state 
output logic data_burst_done_o ; // represents the finish of the data burst in case that the burst is not the default
output logic wrdata_done_o ; // represents the finish of wr_data state
output logic wrmask_done_o ; // represents the finish of write with mask 
output logic interamble_o ; // represents if there will be an interamble or not
output logic crc_generate_o ; // represents that PHY will generate and send the crc to dram
output logic preamble_load_o ; // indicates loading preamble pattern in preamble logicister
output logic gap_burst_eight_o ; // indicates to data burst 8 state and enable is high
output logic wrdata_crc_done_o ; // represents the finish of the data and it is crosspoinding crc  

// internal signals 

logic [3:0] counter_preamble ; // responsible for an output flag to move from preamble state
logic [3:0] counter_write_data ; // responsible for an output flag to move from wr_data_state_i
logic [2:0] counter_inter_post ; // responsible for an output flag to move from interamble state
logic wr_en_low_flag ; // this bit will be high when we are at the data_state_i and the wr_en go to be low 
logic [3:0] gap_value ; // to store the value of the gap 
logic burst_eight ; // flag will be high in case burst length 8 and phy crc support mode   ////////////////////////////////


// preamble_done_o : output to the controller to move from preamble state
assign preamble_done_o = (counter_preamble== 4'b0101)? 1'b1 : 1'b0 ;

// wrdata_crc_done_o : output to the controller to move from wrdata_crc state 
assign wrdata_crc_done_o = (counter_write_data == 4'b0101 && dram_crc_en_i)? 1'b1 : 1'b0 ;

// postamble_done_o : output to the controller to move from postamble or interamble state
assign postamble_done_o = (counter_inter_post == (postcycle_i-1+(dram_crc_en_i && phy_crc_mode_i)))? 1'b1 : 1'b0 ;

// interamble_done_o : output to the controller to move from interamble state
assign interamble_done_o = (counter_inter_post == (gap_value-1))? 1'b1 :1'b0 ;

// wrdata_done_o : output to the controller to move from wrdata state
assign wrdata_done_o = ( (counter_write_data == 4'b0111 && burstlength_i == 2'b01) || (counter_write_data == 4'b0101 && (burstlength_i == 2'b00 || burstlength_i == 2'b10)) )? 1'b1 : 1'b0 ;

//data_burst_done_o : output to the controller to move from data_burst state
assign data_burst_done_o = (counter_write_data == 4'b0011)? 1'b1 : 1'b0 ;

// wrmask_done_o : output to the controller to move from wrdata state in the case of the mask
assign wrmask_done_o = ((counter_write_data == 4'b0101 && !dram_crc_en_i) || (counter_write_data ==4'b0011  && burstlength_i == 2'b01 && !dram_crc_en_i) )? 1'b1 : 1'b0 ;

// interamble : output determines whether there will be interamble or not
assign interamble_o = ((gap_i<precycle_i+postcycle_i+(phy_crc_mode_i-1)) || (burstlength_i == 2'b01 && (gap_i<precycle_i+postcycle_i)))? 1'b1 : 1'b0 ;

// crc_generate_o : output determines if PHY will both generate and send crc to DRAM or not
assign crc_generate_o = dram_crc_en_i && phy_crc_mode_i ;

// preamble_load_o : output signal to load preamble pattern in preamble register
assign preamble_load_o = (counter_write_data == 4'b0001)? 1'b1 : 1'b0 ;

// burst_eight : signal indicates to burst length =8 , phy crc support
assign burst_eight = (dram_crc_en_i && phy_crc_mode_i && burstlength_i ==2'b01 )? 1'b1 : 1'b0 ;

// gap_burst_eight_o : output signal indicates to case byrst length 8 and phy crc support to decrement gap value by 4 
assign gap_burst_eight_o = (counter_preamble ==3'b001 && burst_eight && data_state_i)? 1'b1 : 1'b0 ;

// Preamble sequential always 
always @(posedge clk_i or negedge rst_i)
 begin
	if(!rst_i)                       // active low asynchronous reset. 
	  begin
		counter_preamble   <= 4'b0000  ;  // reset the counter to 0 
		preamble_valid_o <= 1'b0 ;
	  end
	
	else if (wr_en_i == 1'b0 && data_state_i  == 1'b1)
	  begin
	    counter_preamble   <= 4'b0000  ;   // we are in the data state and preamble pattern are finished so we must reset the counter to 0 
	  end
	   
	else if(wr_en_i == 1'b1)
	  begin
		counter_preamble <= counter_preamble + 1 ; 		// increment counter by 1
		
		if ((counter_preamble == ( 5-precycle_i ))&& !data_state_i)    // correct pattern is sent on DQS bus
	      begin
			preamble_valid_o <= 1'b1 ; 
		  end 
		else if(counter_preamble == 4'b0101)       // the counter reach to the max value
		  begin
			counter_preamble <= 4'b0000 ;   // when the counter reach to the max value we must reset it to 0 
			preamble_valid_o <= 1'b0 ;
		  end  
	
	  end
	  
	  
	else if(burstlength_i == 2'b01 && counter_preamble == 4'b0100) // BL16
      begin
         counter_preamble <= counter_preamble + 1 ;   // increment the counter to make sure that the pattern will take it is full cycles (5 cycles)
      end 
	
	else if(counter_preamble == 4'b0101)       // the counter reach to the max value 
      begin
         counter_preamble <= 4'b0000 ; // when the counter reach to the max value we must reset it to 0
         preamble_valid_o <= 1'b0 ;
      end  
 	 
 end


// Data sequential always 
always @(posedge clk_i or negedge rst_i)
 begin  
	if(!rst_i)                       // active low asynchronous reset. 
	  begin
		counter_write_data <= 4'b0000 ;  // reset counter to 0 
		wr_en_low_flag     <= 1'b0    ; 	
	  end
	
	else if(preamble_state_i ||interamble_valid_i)       // preamble , postamble , interamble states
	  begin
	    wr_en_low_flag <= 1'b0  ;
		counter_write_data <= 4'b0000 ;
	  end
	
	else if (data_state_i == 1'b1 && burstlength_i == 2'b01 &&dram_crc_en_i == 1'b0 )    // case of  burst length =8 , mask and no crc needed 
	  begin
		counter_write_data <= counter_write_data + 1 ;
	  end
	
	else if (!wr_en_i && (data_state_i ||preamble_state_i ))    //  start counting when enable is low in data states  or preamble states   
	  begin 
		wr_en_low_flag <= 1 ;
		counter_write_data <= counter_write_data + 1 ;	
      end	
     
	else if (wr_en_low_flag )
	  begin
		counter_write_data <= counter_write_data + 1 ;	// increment the counter when wr_en_low_flag = 1 that we are at the data state and write enable is low 
	  end
 
	else     
	counter_write_data <= 4'b0000 ;      // reset the counter to 0
  	
 end


// Postamble and Interamble sequential always 
always @ (posedge clk_i or negedge rst_i)
 begin
	if(!rst_i)                       // active low asynchronous reset. 
	  begin
		counter_inter_post <= 3'b000  ;
		interamble_shift_o <= 3'b000  ; 
		gap_value <= 3'b000 ;
	  end
	
	else if(interamble_valid_i)      // start counting in interamble state           
	  begin
		counter_inter_post <= counter_inter_post + 1 ;  // increment the counter 
		interamble_shift_o <= interamble_shift_o + 1 ;  // increment the shift to bring the next bit 
	  end  
	  
	else if(data_state_i)    // we are at data state 
	  begin
		gap_value <= gap_i ;        // store value of input gap in register at write data state
		counter_inter_post <= 3'b000  ;
		interamble_shift_o <= 3'b000  ;
	  end
	
	else       // reset all values to 0 because we are at idle state 
	  begin
		gap_value <=4'b0000 ;   
		counter_inter_post <= 3'b000  ;
		interamble_shift_o <= 3'b000  ;
	  end
	
 end


endmodule