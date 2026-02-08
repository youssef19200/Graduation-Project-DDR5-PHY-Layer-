/**********************************************************************************
** Graduation project_S26
** Author: Ahmed Mohamed Zakaria
**
** Module Name: ddr5_phy_crc_x4
** Description: this file contains the CRC Generation RTL of the device size X4
**
*********************************************************************************/

module ddr5_phy_crc_x4 (
    // input signals //
  	input 			clk_i ,         // clock signal 
	input 			rst_n_i ,         // active low asynchronous reset
  	input 			crc_en_i ,      // enable signal from write data block 
	input [7: 0]  crc_in_data_i ,   // input data bus from write data block that required crc bits

	// output signals //
  	output  [7: 0]	crc_code_o      // output crc bits
);
  

reg [7:0]  data_register;   // internal register to store the input data to generate crc
reg	[3:0]  counter;         // counter counts number of clock cycle start to count when enable get high


always @(posedge clk_i or negedge rst_n_i)
    begin  

	if(!rst_n_i) begin  // reseting value of the counter and initial storing zeros in data_register
		data_register <= 8'b0  ;
		counter       <= 3'b0  ;
	end
	   
	else if(crc_en_i) begin
		counter <= counter + 1 ;   
		
		case (counter)
	    4'b0000 : begin      //0-7//
			data_register[0] <= crc_in_data_i[0] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[1] <= crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[6];
			data_register[2] <= crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[6];
		    data_register[3] <= crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[7];
			data_register[4] <= crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[4];
			data_register[5] <= crc_in_data_i[3] ^ crc_in_data_i[4] ^ crc_in_data_i[5];
			data_register[6] <= crc_in_data_i[4] ^ crc_in_data_i[5] ^ crc_in_data_i[6];
		    data_register[7] <= crc_in_data_i[5] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
		end

	    4'b0001 :  begin     //8-15//           
            data_register[0] <= data_register[0] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[0] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[1] <= data_register[0] ^ data_register[1] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[6];
			data_register[2] <= data_register[0] ^ data_register[1] ^ data_register[2] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[6];
			data_register[3] <= data_register[1] ^ data_register[2] ^ data_register[3] ^ data_register[7] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[7];
			data_register[4] <= data_register[2] ^ data_register[3] ^ data_register[4] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[4];
			data_register[5] <= data_register[3] ^ data_register[4] ^ data_register[5] ^ crc_in_data_i[3] ^ crc_in_data_i[4] ^ crc_in_data_i[5];
			data_register[6] <= data_register[4] ^ data_register[5] ^ data_register[6] ^ crc_in_data_i[4] ^ crc_in_data_i[5] ^ crc_in_data_i[6];
			data_register[7] <= data_register[5] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[5] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
        end

	    4'b0010 : begin      //16-23//             
            data_register[0] <= data_register[0] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[0] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[1] <= data_register[0] ^ data_register[1] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[6];
			data_register[2] <= data_register[0] ^ data_register[1] ^ data_register[2] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[6];
			data_register[3] <= data_register[1] ^ data_register[2] ^ data_register[3] ^ data_register[7] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[7];
			data_register[4] <= data_register[2] ^ data_register[3] ^ data_register[4] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[4];
			data_register[5] <= data_register[3] ^ data_register[4] ^ data_register[5] ^ crc_in_data_i[3] ^ crc_in_data_i[4] ^ crc_in_data_i[5];
			data_register[6] <= data_register[4] ^ data_register[5] ^ data_register[6] ^ crc_in_data_i[4] ^ crc_in_data_i[5] ^ crc_in_data_i[6];
			data_register[7] <= data_register[5] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[5] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
        end
				
	    4'b0011 : begin    	 //24-31//             
            data_register[0] <= data_register[0] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[0] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[1] <= data_register[0] ^ data_register[1] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[6];
			data_register[2] <= data_register[0] ^ data_register[1] ^ data_register[2] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[6];
			data_register[3] <= data_register[1] ^ data_register[2] ^ data_register[3] ^ data_register[7] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[7];
			data_register[4] <= data_register[2] ^ data_register[3] ^ data_register[4] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[4];
			data_register[5] <= data_register[3] ^ data_register[4] ^ data_register[5] ^ crc_in_data_i[3] ^ crc_in_data_i[4] ^ crc_in_data_i[5];
			data_register[6] <= data_register[4] ^ data_register[5] ^ data_register[6] ^ crc_in_data_i[4] ^ crc_in_data_i[5] ^ crc_in_data_i[6];
			data_register[7] <= data_register[5] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[5] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
        end
	
	    4'b0100 : begin      //32-39//              
            data_register[0] <= data_register[0] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[0] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[1] <= data_register[0] ^ data_register[1] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[6];
			data_register[2] <= data_register[0] ^ data_register[1] ^ data_register[2] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[6];
			data_register[3] <= data_register[1] ^ data_register[2] ^ data_register[3] ^ data_register[7] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[7];
			data_register[4] <= data_register[2] ^ data_register[3] ^ data_register[4] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[4];
			data_register[5] <= data_register[3] ^ data_register[4] ^ data_register[5] ^ crc_in_data_i[3] ^ crc_in_data_i[4] ^ crc_in_data_i[5];
			data_register[6] <= data_register[4] ^ data_register[5] ^ data_register[6] ^ crc_in_data_i[4] ^ crc_in_data_i[5] ^ crc_in_data_i[6];
			data_register[7] <= data_register[5] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[5] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
        end

        4'b0101 : begin      //40-47//	             
            data_register[0] <= data_register[0] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[0] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[1] <= data_register[0] ^ data_register[1] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[6];
			data_register[2] <= data_register[0] ^ data_register[1] ^ data_register[2] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[6];
			data_register[3] <= data_register[1] ^ data_register[2] ^ data_register[3] ^ data_register[7] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[7];
			data_register[4] <= data_register[2] ^ data_register[3] ^ data_register[4] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[4];
			data_register[5] <= data_register[3] ^ data_register[4] ^ data_register[5] ^ crc_in_data_i[3] ^ crc_in_data_i[4] ^ crc_in_data_i[5];
			data_register[6] <= data_register[4] ^ data_register[5] ^ data_register[6] ^ crc_in_data_i[4] ^ crc_in_data_i[5] ^ crc_in_data_i[6];
			data_register[7] <= data_register[5] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[5] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
        end
	
	    4'b0110 : begin      //48-55//
            data_register[0] <= data_register[0] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[0] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[1] <= data_register[0] ^ data_register[1] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[6];
			data_register[2] <= data_register[0] ^ data_register[1] ^ data_register[2] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[6];
			data_register[3] <= data_register[1] ^ data_register[2] ^ data_register[3] ^ data_register[7] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[7];
			data_register[4] <= data_register[2] ^ data_register[3] ^ data_register[4] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[4];
			data_register[5] <= data_register[3] ^ data_register[4] ^ data_register[5] ^ crc_in_data_i[3] ^ crc_in_data_i[4] ^ crc_in_data_i[5];
			data_register[6] <= data_register[4] ^ data_register[5] ^ data_register[6] ^ crc_in_data_i[4] ^ crc_in_data_i[5] ^ crc_in_data_i[6];
			data_register[7] <= data_register[5] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[5] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
        end
		
	    4'b0111 : begin      //56-63//               
            data_register[0] <= data_register[0] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[0] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
			data_register[1] <= data_register[0] ^ data_register[1] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[6];
			data_register[2] <= data_register[0] ^ data_register[1] ^ data_register[2] ^ data_register[6] ^ crc_in_data_i[0] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[6];
			data_register[3] <= data_register[1] ^ data_register[2] ^ data_register[3] ^ data_register[7] ^ crc_in_data_i[1] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[7];
			data_register[4] <= data_register[2] ^ data_register[3] ^ data_register[4] ^ crc_in_data_i[2] ^ crc_in_data_i[3] ^ crc_in_data_i[4];
			data_register[5] <= data_register[3] ^ data_register[4] ^ data_register[5] ^ crc_in_data_i[3] ^ crc_in_data_i[4] ^ crc_in_data_i[5];
			data_register[6] <= data_register[4] ^ data_register[5] ^ data_register[6] ^ crc_in_data_i[4] ^ crc_in_data_i[5] ^ crc_in_data_i[6];
			data_register[7] <= data_register[5] ^ data_register[6] ^ data_register[7] ^ crc_in_data_i[5] ^ crc_in_data_i[6] ^ crc_in_data_i[7];
        end
					
	    4'b1000 :  counter <= 4'b0; 

		endcase


	end
end
  
assign crc_code_o = (counter == 4'b1000)? data_register : 8'b0000; 

endmodule  
