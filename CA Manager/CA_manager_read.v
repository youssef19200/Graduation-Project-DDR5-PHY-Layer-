module ddr5_phy_command_address_read #(
  // parameter used to specify the number of ranks used in the DIMM
  parameter     pNUM_RANK	= 1
  )(
  
  ////////////////input signals//////////////
  
  input wire clk_i,
  input wire rst_i,
  input wire enable_i,
  input wire [13:0]			dfi_address_i,
  input wire [pNUM_RANK-1:0]	dfi_cs_i,
  
  ////////////////output signals//////////////
  
  output reg [pNUM_RANK-1:0]	chip_select_o,
  output reg [13:0]			command_address_o,
  output wire [1:0]			burst_length_o,
  output reg [2:0]			num_pre_cycle_o,
  output reg	           num_post_cycle_o,   
  output reg 			   dram_crc_en_o   
  );


  // default_sel is a flag indicates if it is first clock cycle to select the default values
  reg command_1st_flag, command_2nd_flag, read_flag, default_sel;

  // signals to determine BL value
  reg [1:0]   burst_length_alternate;
  reg [1:0]   burst_length_default;
  reg         burst_length_sel;
  // MR and OP signals 
  reg [7:0] mode_register,operation;

    
  // select which register is connected to the output burst length
  assign burst_length_o = burst_length_sel ? burst_length_default : burst_length_alternate;
  
  //always block to control the flow of current sate register
  always @ (posedge clk_i or negedge rst_i) begin
    if (!rst_i) begin
      
	  // internal registers
	    command_1st_flag <= 1'b0;
	    command_2nd_flag <= 1'b0;
	    read_flag <= 1'b0;
        default_sel <= 1'b0;
        mode_register <= 8'b0;
        operation <= 8'b0;
	  
      // output registers
      command_address_o   <= 14'b0;
      chip_select_o <= {pNUM_RANK{1'b0}}; 
      burst_length_default <= 2'b00;
      burst_length_alternate <= 2'b00;
      burst_length_sel <= 1'b0;	  
      num_pre_cycle_o <= 3'b0;
      num_post_cycle_o <= 1'b0;
      dram_crc_en_o <= 1'b0;
    
    end
    else if (enable_i) begin
	
	  // assign the command on dfi_address on CA bus
      command_address_o   <= dfi_address_i;
      // assign the CS signal to dfi_cs
      chip_select_o <= dfi_cs_i;
	
	  if (!default_sel) begin
        default_sel <= 1'b1;
		    command_1st_flag <= 1'b0;
	      command_2nd_flag <= 1'b0;
		    read_flag <= 1'b0;
    
        // begin with the default values, these values are from  JEDEC
        burst_length_default <= 2'b00;
        burst_length_alternate <= 2'b00;
        burst_length_sel <= 1'b0;			
        num_pre_cycle_o <= 3'b010;
        num_post_cycle_o <= 1'b0;
        dram_crc_en_o <= 1'b0;
      end
      else begin
	  
	    if(!dfi_cs_i && (dfi_address_i[4:0] == 5'b00101)) begin // mode register write command first cycle
	      // enabel command 1st cycle flag
		  command_1st_flag <= 1'b1;
          command_2nd_flag <= 1'b0;
          read_flag <= 1'b0;
		  // from command truth table in JEDEC the mode register address is in CA[12:5] of the 1st cycle
		  mode_register <= dfi_address_i [12:5]; 
	    end
	    else if (!dfi_cs_i && (dfi_address_i[4:0] == 5'b01111)) begin // write command
		  // enable write command 1st cycle flag
		  read_flag <= 1'b1;
		  command_1st_flag <= 1'b0;
          command_2nd_flag <= 1'b0;      
	    end
	    
	    
	    if(dfi_cs_i && !dfi_address_i[10] && command_1st_flag) begin // mode register write command second cycle
	      // disabel command 1st cycle flag
		  command_1st_flag <= 1'b0;
		  // enabel command 2nd cycle flag
	    command_2nd_flag <= 1'b1;
        read_flag <= 1'b0;
		  // from command truth table in JEDEC the mode register operation is in CA[7:0] of the 2nd cycle
		  operation <= dfi_address_i [7:0];
	    end
	    else if (dfi_cs_i && read_flag) begin
		  // disable write command 1st cycle flag
		  read_flag <= 1'b0;
		  
		  // when CS is high check if default or not is wanted
	      // CA5:BL*=L, the command places the DRAM into the alternate Burst mode described by MR0[1:0] instead of the default Burst Length 16 mode.
		  burst_length_sel <= command_address_o[5];
	    end
	    
	    if(command_2nd_flag) begin
		  // disabel command 2nd cycle flag
	      command_2nd_flag <= 1'b0;
		  // decode the mode register 8 value to the desired output signals
          if(mode_register == 8) begin
                num_pre_cycle_o <= operation [5:3];
                num_post_cycle_o <= operation [7];
          end
            
          // decode the mode register 50 value to the DRAM CRC enable signal
          else if (mode_register == 50) begin
            dram_crc_en_o <= operation[1] | operation[0];
          end
	    
          // decode the mode register 0 value to the desired burst length value 
        else if (mode_register == 0) begin
            burst_length_alternate <= operation [1:0];
          end
	    end
      end
    end
  end
  

endmodule