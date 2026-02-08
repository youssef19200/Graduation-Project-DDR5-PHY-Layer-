/*************************************************************************************************************
File Name : ddr5_write_fsm module 
Author : Yousef Gamal Saber 
Created on : Jan 2026 
**************************************************************************************************************/

module write_fsm # (parameter pDRAM_SIZE = 4) 
(clk_i,rst_i,enable_i,wr_en_i,preamble_valid_i,preamble_done_i,postamble_done_i,interamble_done_i,wrdata_crc_done_i,wrdata_done_i,data_burst_done_i,wrmask_done_i,crc_generate_i,interamble_i,preamble_bits_i,interamble_bits_i,gap_i,wr_data_i,wr_datamask_i,crc_code_i,burstlength_i,data_state_o,preamble_state_o,crc_data_o,crc_enable_o,dqs_o,dq_o,dqs_valid_o,dq_valid_o,dm_o,interamble_valid_o) ;
localparam idle = 3'b000 ;
localparam preamble = 3'b001 ;
localparam wr_data_crc = 3'b010 ;
localparam wr_data = 3'b011 ;
localparam data_burst8 = 3'b100 ;
localparam crc = 3'b101 ;
localparam postamble = 3'b110 ;
localparam interamble = 3'b111 ;
// input signals 
input logic clk_i , rst_i ;
input logic enable_i ; // system block enable
input logic wr_en_i ; // write enable signal from freq ratio block
input logic preamble_valid_i,preamble_done_i,postamble_done_i,interamble_done_i,data_burst_done_i,wrmask_done_i,crc_generate_i,interamble_i ;
input logic wrdata_crc_done_i ; // signal that indicates that whole data is sent on DQ bus  (MC crc support)
input logic wrdata_done_i ; // signal that indicates that whole data is sent on DQ bus  (PHY crc support)
input logic [1:0] preamble_bits_i ; // preamble bits result from shifting preamble pattern
input logic [1:0] interamble_bits_i ; // interamble bits result from shifting interamble pattern
input logic [3:0] gap_i ;  // signal detect number of cycles at which  write enable is low 
input logic [2*pDRAM_SIZE -1 :0] wr_data_i ; // the number of bits of the data will be sent 
input logic [(pDRAM_SIZE/4 -1) :0] wr_datamask_i ; // input data mask  from freq ratio block 
input logic [2*pDRAM_SIZE -1 :0] crc_code_i ; // input crc data from crc block
input logic [1:0] burstlength_i ; // input burstlength from command block

// output signals 
output logic data_state_o ; // output signal indicates  to  write data states
output logic preamble_state_o ; // output signal indicates to preamble , postamble ,interamble states
output logic [2*pDRAM_SIZE -1:0] crc_data_o ; // output data to crc block
output logic crc_enable_o ; // output enable to crc block
output logic [1:0] dqs_o ; // output data strobe to DRAM
output logic [2*pDRAM_SIZE -1:0] dq_o ; // output data to DRAM
output logic dqs_valid_o ;  //  output signal indicates that data strobe is sent or not		
output logic dq_valid_o ; //  output signal indicates that data is sent or not
output logic [(pDRAM_SIZE/4 -1) :0] dm_o ; // output data mask to DRAM
output logic interamble_valid_o ; // output signal indicates that interamble bits is sent on dqs bus

// internal signals and logicisters and state defintions
logic [2:0] current_state , next_state ;

logic [1:0] dqs ; 
logic [2*pDRAM_SIZE -1:0] dq ;
logic dqs_valid ;
logic dq_valid ;
logic [(pDRAM_SIZE/4 -1) :0] dm ;

// state transition
always @(posedge clk_i or negedge rst_i)
 begin
	if(!rst_i)              // Asynchronous active low reset 
	  begin
		current_state <= idle ;
	  end
   
	else if (enable_i)       // enable fsm 
	  begin	
	  current_state <= next_state ;
	  end
	  
 end

// next_state and output logic
always @ (*)
begin
 case (current_state)    
    idle : begin 
           dq  = {(2*pDRAM_SIZE){1'b0}} ;
		   dq_valid = 1'b0 ;
		   dm = {(pDRAM_SIZE /4){1'b0}} ;			
		   dqs = 2'b00 ;
		   interamble_valid_o= 1'b0 ;
		   dqs_valid = 1'b0 ;	
		   data_state_o  = 1'b0 ;
		   preamble_state_o = 1'b0 ;
		   crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
           crc_enable_o = 1'b0 ; 
					
		   if(wr_en_i)                            
			  next_state = preamble;
		   else
			  next_state = idle ;	
         end 
  
    preamble : begin 
                 // preamble pattern is sent on dqs bus ,and dqs valid will be high when the correct pattern is sent
                dq = {(2*pDRAM_SIZE){1'b0}};
		        dq_valid = 1'b0 ;
			    dm = {(pDRAM_SIZE /4){1'b0}} ;				      
             	dqs = preamble_bits_i ;
				interamble_valid_o= 1'b0 ;
			    dqs_valid = preamble_valid_i ;
				data_state_o  = 1'b0 ;
				preamble_state_o = 1'b1 ;
			    crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
                crc_enable_o = 1'b0 ;
                // when preamble is sent on dqs bus and check crc_generate_i if low then move to wr_data_crc or if crc_generate_i is high then move to wr_data
                if (preamble_done_i && !crc_generate_i)  
					  next_state = wr_data_crc ;					 
				else if (preamble_done_i && crc_generate_i)
					  next_state = wr_data ;		    
				else 					 
					  next_state = preamble ;	
              end 
    wr_data_crc : begin                    // (MC crc support or data mask) 
                  // wr_data from MC will be sent on dq bus with dq_valid ,dqS will be phy _clock,wrdata mask is sent on dm bus
                    dq= wr_data_i ;
		            dq_valid = 1'b1 ;
			        dm = wr_datamask_i  ;			         
					dqs = 2'b10 ;
				    interamble_valid_o= 1'b0 ;
			        dqs_valid = 1'b1 ;	
					data_state_o  = 1'b1 ;
					preamble_state_o = 1'b0 ;
			        crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
                    crc_enable_o = 1'b0 ;
                  // when data is sent on dq bus and check interamble if high move to interamble state ,if low move to postamble
                    if(!interamble_i && (wrdata_crc_done_i|| wrmask_done_i)) 
					  next_state = postamble ;        
					else if (interamble_i &&(wrdata_crc_done_i|| wrmask_done_i))
					  next_state = interamble ; 					
					else 
					  next_state = wr_data_crc;	
                  end 
    wr_data : begin      // phy crc support
                 // data will be sent on dq bus and to crc block to generate crc anddqs will be phy _clock
                    dq= wr_data_i ;              
		            dq_valid = 1'b1 ;
			        dm = {(pDRAM_SIZE /4){1'b0}}  ;			      
			        dqs = 2'b10 ;
				    interamble_valid_o= 1'b0 ;
			        dqs_valid = 1'b1 ;	
                    crc_data_o = wr_data_i ;
                    crc_enable_o = 1'b1 ;	
				    data_state_o = 1'b1 ;
				    preamble_state_o = 1'b0 ;
                 // when data is sent on dq bus and checkburstlength_i if burstlength_i = 8 ,move to data_burst8 state
                    if(burstlength_i == 2'b01 && data_burst_done_i)
					  next_state = data_burst8 ;
					else if (wrdata_done_i)
					  next_state = crc ; 
					else 
					 next_state = wr_data;
              end 
    data_burst8 : begin      // burstlength = 8
                    dq  = {(2*pDRAM_SIZE){1'b1}} ;   // rest of wr_data will be completed with ones and sent it on dq bus because the default is 16 so we fill the remaining 8 its with 1 and send this ones to crc block to calculate the crc code 
                    dq_valid = 1'b1 ; 
                    dm = {(pDRAM_SIZE /4){1'b0}}  ;			       
					dqs = 2'b10 ;
					interamble_valid_o= 1'b0 ;
					dqs_valid = 1'b1 ;	
				    crc_data_o = {(2*pDRAM_SIZE){1'b1}} ;
                    crc_enable_o = 1'b1 ;
					data_state_o = 1'b1 ;
					preamble_state_o= 1'b0 ;
                    // move to the crc state when the data and it is crosspoinding crc were sent
                    if(wrdata_done_i)
					  next_state = crc ;
					else 
					  next_state = data_burst8;
                  end 
    crc : begin     // phy crc support
                    // crc code is taken from crc block and sent it after data on dq bus
                    // sends interamble_valid to shift register to shift interamble pattern
	                dq  = crc_code_i ;            				 
		            dq_valid = 1'b1 ;
			        dm = {(pDRAM_SIZE /4){1'b0}} ;			    
			        dqs = 2'b10 ;
				    interamble_valid_o = 1'b1 ;    // prepare interamble pattern  
			        dqs_valid = 1'b1 ;	
				    crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
				    crc_enable_o = 1'b1 ;
				    data_state_o = 1'b0 ;
			    	preamble_state_o = 1'b0 ;
                    // check interamble_i if high move to interamble state ,if not move to postamble state
                    if (gap_i ==3'b001 )
					  next_state = wr_data ; 
					else if (interamble_i)
					  next_state = interamble ;
					else 
					  next_state = postamble ;	
          end 
    postamble : begin   // postaamble pattern is sent on dqs bus
                    dq = {(2*pDRAM_SIZE){1'b0}} ;  
		            dq_valid = 1'b0 ;
			        dm = {(pDRAM_SIZE /4){1'b0}}  ;			    
			        dqs = 2'b00 ;
				    interamble_valid_o= 1'b1 ;  // to increment the counter_inter_post that will count when interamble valid is high
			        dqs_valid = 1'b1 ;	
				    crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;
                    crc_enable_o = 1'b0 ;	
				    data_state_o = 1'b0 ;
				    preamble_state_o = 1'b0 ;
                    // when postamble pattern is sent ondqs bus , check wr_en_i if high move to preamble state ,if low move to idle
                    if (postamble_done_i && !wr_en_i)
					  next_state =idle ;
					else if (postamble_done_i && wr_en_i)
					  next_state = preamble ;					
					else 
					  next_state = postamble;
                end 
    interamble : begin    // interamble pattern is sent ondqs bus
                    dq = {(2*pDRAM_SIZE){1'b0}} ;
		            dq_valid = 1'b0 ;
			        dm = {(pDRAM_SIZE /4){1'b0}}  ;
			        dqs =  interamble_bits_i ;
				    interamble_valid_o= 1'b1 ;
			        dqs_valid = 1'b1 ;
					crc_data_o = {(2*pDRAM_SIZE){1'b0}} ;                    
					data_state_o = 1'b0 ;
					preamble_state_o = 1'b0 ;
					crc_enable_o = 1'b0 ;
                    // when interamble pattern is sent on dqs ,check crc_generate if low then move to wr_data_crc , if crc_generate is high then move to wr_data 
                    if (interamble_done_i && crc_generate_i)
					  next_state = wr_data ;					
					else if (interamble_done_i && !crc_generate_i)					
					  next_state = wr_data_crc ;				 
					else   					
					  next_state = interamble;
                 end 
    default : begin 
                    dq_valid = 1'b0 ;
					dm = {(pDRAM_SIZE /4){1'b0}}  ;
					dqs = 2'b00; 
					interamble_valid_o = 1'b0 ;
					dqs_valid = 1'b0 ;	
					crc_enable_o = 1'b0 ;				
					next_state = idle ; 
              end 
 endcase 
end
//////////////////////////////////////////////////////////////////////////////////////////////////
// registered output
always @(posedge clk_i or negedge rst_i)
  begin
	if(!rst_i)              // Asynchronous active low reset 
	  begin
		dq_o <= {(2*pDRAM_SIZE){1'b0}} ;
		dqs_o <= 2'b00 ;
		dq_valid_o <= 1'b0;
        dqs_valid_o <=1'b0  ;
       	dm_o <={(pDRAM_SIZE /4){1'b0}}  ;
	  end
   
	else if (enable_i)       // enable fsm 
	  begin	
	    dq_o <= dq ;
		dqs_o <=dqs ;
		dq_valid_o <= dq_valid ;
        dqs_valid_o <=dqs_valid  ;
       	dm_o <= dm ;
	  end
 end
endmodule