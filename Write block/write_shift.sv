/*************************************************************************************************************
File Name : ddr5_write_shift module 
Author : Yousef Gamal Saber 
Created on : Jan 2026 
**************************************************************************************************************/

module write_shift (clk_i,rst_i,wr_en_i,pre_pattern_i,interamble_valid_i,interamble_shift_i,preamble_valid_i,preamble_load_i,gap_burst_eight_i,interamble_bits_o,preamble_bits_o,gap_o) ;

// input signals 
input logic clk_i,rst_i,wr_en_i,interamble_valid_i,preamble_valid_i,preamble_load_i,gap_burst_eight_i ;
// rst_i are active low asynchorouns reset 
// wr_en_i are the bit that allow to write to the RAM or not
// interamble_valid_i this bit determine are there is an interamble bits or not 
// preamble_valid_i this bit determine are there is an preamble bits or not
// preamble_load_i this bit determine if the preamble bits are loaded on the DQ or not 
// gap_burst_eight_i this bit determine the number of data that will be sent 8 or 16 or any number multplied with 8 
input logic [7:0] pre_pattern_i ; // this is the preamble pattern and it is 8 bits
input logic [2:0] interamble_shift_i ; // this is the value of the shift to determine where is the start bits from interamble_pattern

// output signals 
output logic [1:0] interamble_bits_o,preamble_bits_o ; // there are the actual interamble_bits_o and preamble_bits_o will be sent to the RAM there are 2 bits from the 12 bits and 10 bits respectivily
output logic [3:0] gap_o ; // this are the number of cycles that must be waited 

// internal signals 
logic [9:0] preamble_pattern ;  // this is the pattern of the preamble and in the standered the last 2 bits are 00 to tell the ram that the actual data are come
logic [11:0] interamble_pattern ; // this is the pattern of the interamble and in the standered it is a 12 bits to make a varity because the interamble_shift_i are 3 bits that can make me start from the seventh bit so i will find bits to be transmitted and it is mixed from preamble and postamble and the interamble_shift_i determined where the interamble will start
logic [3:0] gap_register ; // this is the gap that the system must wait it and there is no data sent at this cycles but it help to make the MC and RAM be synchronized and this value will go to gap to be as output 
logic [3:0] counter_enable_low ; // this is a counter that count the cycles when the wr_en_i is low and there is no data are be written now at RAM and when the wr_en_i is high the last number that be counted will transfered to the gap_register

// preamble pattern 
always @ (posedge clk_i or negedge rst_i)  
begin 
    if (! rst_i) 
     begin 
      preamble_pattern <= 10'b0 ;     // reset the preamble pattern to zeros 
      preamble_bits_o <= 2'b0 ;
     end 
    else if (preamble_load_i)
     begin 
      preamble_pattern <= {2'b00 , pre_pattern_i} ; // load the preamble pattern with the 10 bits
     end
    else if (wr_en_i || preamble_valid_i)
     begin
      preamble_bits_o <= preamble_pattern[9:8] ;     // get the 2 MSB on the preamble bits 
      preamble_pattern <= {preamble_pattern[7:0], 2'b00 } ;  // modify the value on the preamble pattern 
     end
    else 
     preamble_pattern <= {2'b00 , pre_pattern_i} ;   // set the defualt that the preamble pattern take it is value
end 


// calculate gap_register
always @ (posedge clk_i or negedge rst_i) 
begin
   if (!rst_i)
    begin
     counter_enable_low <= 3'b000 ;  // reset the counter to 0 
    end 
   else if (!wr_en_i)    // if write enable = 0
    begin
     counter_enable_low <= counter_enable_low+1 ;   // decrement the counter 
     gap_register <= counter_enable_low+1 ;   // put the new decremented value on gap_register 
     gap_o <=counter_enable_low+1  ;   // put the new decremented value on gap
    end     
   else if (gap_burst_eight_i)     // if the number of bits of the data are 8 
   begin 
     gap_register <= gap_register-4 ;   // decrement the value of gap_register by 4 because we need 4 cycles to send the 8 bits of data and the remaing value will be the gap that i must waited
     gap_o <= gap_register-4 ;         // decrement the value of gap by 4
     counter_enable_low <= 3'b000 ;   // reset the counter to 0 to modify the last number written on the counter and start the next pattern from a new counter  
   end
   else 
   begin 
     counter_enable_low <=3'b000 ; // write enable become 1 so counter must be 0 and to modify the last count and reset it to 0 
   end  
end 


// calculate interamble
always @ (interamble_valid_i,interamble_shift_i,gap_register,interamble_pattern,pre_pattern_i)
begin 
   interamble_bits_o = interamble_pattern[11:10] ; // put the highest 2 bits of the interamble pattern on the interamble bits and it is value will be modifyed every cycle because the interamble paterrn will be shifted by 2 bits 
  
   if (interamble_valid_i == 1'b1) 
     begin 
       interamble_pattern = {interamble_pattern[9:0],2'b00} ; // modify to the interamble pattern by shifting it to the left and put 2 zeros 
     end 

   else 
     begin 
      case (gap_register)    // this is the value of the counter that the write enable = 0 and there are no data are sent in this period so we send interamble bits to make synchronization
       4'b0001 : begin   // gap = 1 cycle so we need to transmitt two bits
                     interamble_pattern = {pre_pattern_i[1:0],10'b0} ;
                 end 
       4'b0010 : begin // gap = 2 cycle so we need to transmitt 4 bits
                     interamble_pattern = {pre_pattern_i[3:0],8'b0} ;
                 end 
       4'b0011 : begin // gap = 3 cycle so we need to transmitt 6 bits
                     interamble_pattern = {pre_pattern_i[5:0],6'b0} ;
                 end 
       4'b0100 : begin // gap = 4 cycle so we need to transmitt 8 bits
                     interamble_pattern = {pre_pattern_i[7:0],4'b0} ;
                 end 
       4'b0101 : begin  // gap = 5 cycle so we need to transmitt 8 bits and 2 zeros at first
                     interamble_pattern = {2'b00,pre_pattern_i[7:0],2'b00}; 
                 end 
       4'b0110 : begin  // gap = 6 cycle so we need to transmitt 8 bits and 4 zeros at first
                     interamble_pattern = {4'b0,pre_pattern_i[7:0]};
                 end 
       default : begin // except this values the interamble pattern will be 0 because it is 12 bits so the max value of gap must be 6
                     interamble_pattern = 12'b0 ;
                 end
      endcase 
     end 
end
endmodule