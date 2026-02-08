/**********************************************************************************
** Graduation project_S26
** Author: Ahmed Mohamed Zakaria
**
** Module Name: ddr5_phy_crc
** Description: this file contains the CRC Checking RTL (top module of the devices (X4, X8, X16))
**
*********************************************************************************/

module ddr5_phy_crc_check
    # (parameter pDRAM_SIZE = 4 )  // parameter indicate the device size (X4, X8, X16)
(
    // input signals //
	input 					clk_i ,                // clock signal
	input 					rst_n_i ,              // active low asynchronous reset
	input 					crc_en_i ,             // enable signal from write data block 
	input 					pre_rddata_valid_i ,   // active high at the start of data burst
  	input [2*pDRAM_SIZE-1: 0] dfi_rddata_i ,       // input data bus from read data block followed by CRC code that compared with Calculated CRC code
  
    // output signals //
  	output reg           	 dfi_alert_n_o             // asserted when an error occurs (0 if mismatch, 1 if OK)
);

    wire [2*pDRAM_SIZE-1: 0]	 crc_calculated;   //    crc_calculated from first 8 cycles 
    reg  [3:0] cycle_cnt;                          //
    reg        calculating;                        //

    // Instance of CRC Generator to calculate crc code of received data
    ddr5_phy_crc_gen #(.pDRAM_SIZE(pDRAM_SIZE)) crc_gen (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .crc_en_i(crc_en_i),
        .crc_in_data_i (dfi_rddata_i),
        .crc_code_o(crc_calculated)
    );

    // Control Logic & Counter
    always  @(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)  begin                    // reseting value of the counter and initial storing zeros in data_register
            cycle_cnt     <= 4'd0;
            calculating   <= 1'b0;
            dfi_alert_n_o <= 1'b1;              // Default active high: No error
        end
        else begin
            if (pre_rddata_valid_i) begin      // Start counting when pre_rddata_valid_i or crc_en_i is high
                calculating <= 1'b1;
                cycle_cnt   <= cycle_cnt + 1'b1;
                dfi_alert_n_o <= 1'b1;          // Reset alert for new burst            
            end

            if (calculating) begin
                if (cycle_cnt < 4'd8) begin
                    cycle_cnt <= cycle_cnt + 1'b1;
                end else begin
                    cycle_cnt      <= 4'd0;
                    calculating    <= 1'b0;
                end
            end   
        end

        // Comparison Logic (at 9th cycle)
        if (calculating && cycle_cnt == 4'd8) begin
            if (dfi_rddata_i !== crc_calculated)          // dfi_rddata_i (9th cycle) that have the received crc from read data block
                dfi_alert_n_o <= 1'b0;                    // Error detected!
            else 
                dfi_alert_n_o <= 1'b1;                    // CRC matches
        end

    end

endmodule
