/**********************************************************************************
** Graduation project_S26
** Author: Ahmed Mohamed Zakaria
**
** Module Name: ddr5_phy_crc_tb
** Description: this file contains the Test-bench of CRC Checker
**
*********************************************************************************/

module ddr5_phy_crc_check_tb ();

    // Parameters
    parameter pDRAM_SIZE = 4;

    // input signals //
    reg   clk_i;
    reg   rst_n_i;
    reg   crc_en_i;
    reg   pre_rddata_valid_i;
    reg [2*pDRAM_SIZE-1: 0] dfi_rddata_i;

    // output signals //
    wire  dfi_alert_n_o;


    // DUT Instantiate
    ddr5_phy_crc_top #(.pDRAM_SIZE(pDRAM_SIZE)) CRC_checker_U (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .crc_en_i(crc_en_i),
        .pre_rddata_valid_i(pre_rddata_valid_i),
        .dfi_rddata_i(dfi_rddata_i),
        .dfi_alert_n_o(dfi_alert_n_o)
    );

    // Clock Generation
    initial begin
        clk_i=0;
        forever 
            #1 clk_i= ~clk_i;
    end

    // Task for verify reset operation & Initialization inputs
    task reset_dut();
        begin
        rst_n_i = 0;
        crc_en_i = 0;
        pre_rddata_valid_i = 0;
        dfi_rddata_i = {(2*pDRAM_SIZE){1'b0}};
        @(negedge clk_i);
        rst_n_i = 1;
        @(negedge clk_i);
        end
    endtask

    initial begin
        
        reset_dut();
/*
        // // Let the pDRAM_SIZE = 4  &  dfi_rddata_i = 18'h ABCDEFABCDEF7632 11  ////////////////
        pre_rddata_valid_i = 1;
        crc_en_i = 1;
        dfi_rddata_i = 'hAB;
        @(negedge clk_i);

        dfi_rddata_i = 'hCD;
        pre_rddata_valid_i = 0;
        @(negedge clk_i);       

        dfi_rddata_i = 'hEF;
        @(negedge clk_i);
            
        dfi_rddata_i = 'hAB;
        @(negedge clk_i);                        
            
        dfi_rddata_i = 'hCD;
        @(negedge clk_i);            
            
        dfi_rddata_i = 'hEF;
        @(negedge clk_i);            
            
        dfi_rddata_i = 'h76;
        @(negedge clk_i);
            
        dfi_rddata_i = 'h32;
        @(negedge clk_i);   

        dfi_rddata_i = 'hab;
        repeat(2) @(negedge clk_i);  
        if (dfi_alert_n_o == 0 ) begin
            $display ("errorrrrrrrrrrrr - CRC not matched");
            $stop;
        end
*/


        // Let the pDRAM_SIZE = 4  &  dfi_rddata_i = 18'h 3c3c3c3c3c3c3c3c3c 99  // crc true = 05 // then  dfi_rddata_i = 18'h dededededededede 6c   ///////////// 
        pre_rddata_valid_i = 1;
        crc_en_i = 1;
        dfi_rddata_i = 'h3c;
        @(negedge clk_i);

        dfi_rddata_i = 'h3c;
        pre_rddata_valid_i = 0;
        @(negedge clk_i);       

        dfi_rddata_i = 'h3c;
        @(negedge clk_i);
            
        dfi_rddata_i = 'h3c;
        @(negedge clk_i);                        
            
        dfi_rddata_i = 'h3c;
        @(negedge clk_i);            
            
        dfi_rddata_i = 'h3c;
        @(negedge clk_i);            
            
        dfi_rddata_i = 'h3c;
        @(negedge clk_i);
            
        dfi_rddata_i = 'h3c;
        @(negedge clk_i);   

        dfi_rddata_i = 'h99;

        if (dfi_alert_n_o == 0 ) begin
            $display ("errorrrrrrrrrrrr - CRC not matched");
            $stop;
        end
        @(negedge clk_i);  


        pre_rddata_valid_i = 1;
        crc_en_i = 1;
        // @(negedge clk_i);
        
        dfi_rddata_i = 'hde;
        @(negedge clk_i);

        dfi_rddata_i = 'hde;
        pre_rddata_valid_i = 0;
        @(negedge clk_i);       

        dfi_rddata_i = 'hde;
        @(negedge clk_i);
            
        dfi_rddata_i = 'hde;
        @(negedge clk_i);                        
            
        dfi_rddata_i = 'hde;
        @(negedge clk_i);            
            
        dfi_rddata_i = 'hde;
        @(negedge clk_i);            
            
        dfi_rddata_i = 'hde;
        @(negedge clk_i);
            
        dfi_rddata_i = 'hde;
        @(negedge clk_i);   

        dfi_rddata_i = 'h6c;
        repeat(2) @(negedge clk_i);  
        if (dfi_alert_n_o == 0 ) begin
            $display ("errorrrrrrrrrrrr - CRC not matched");
            $stop;
        end 

/*
        // // Let the pDRAM_SIZE = 8  &  dfi_rddata_i = 36'h AB98CD76EF54AB32CD10EF9876543210  1182 ////////////////
        pre_rddata_valid_i = 1;
        crc_en_i = 1;
        dfi_rddata_i = 'hAB98;
        @(negedge clk_i);

        dfi_rddata_i = 'hCD76;
        pre_rddata_valid_i = 0;
        @(negedge clk_i);       

        dfi_rddata_i = 'hEF54;
        @(negedge clk_i);
            
        dfi_rddata_i = 'hAB32;
        @(negedge clk_i);                        
            
        dfi_rddata_i = 'hCD10;
        @(negedge clk_i);            
            
        dfi_rddata_i = 'hEF98;
        @(negedge clk_i);            
            
        dfi_rddata_i = 'h7654;
        @(negedge clk_i);
            
        dfi_rddata_i = 'h3210;
        @(negedge clk_i);   

        dfi_rddata_i = 'h1182;

        if (dfi_alert_n_o == 0 ) begin
            $display ("errorrrrrrrrrrrr - CRC not matched");
            $stop;
        end
*/


        // // Let Random dfi_rddata_i
        // pre_rddata_valid_i = 1;
        // crc_en_i = 1; 
        // dfi_rddata_i = $random;
        // @(negedge clk_i);
        // pre_rddata_valid_i = 0;
        // repeat (8) begin
        //     dfi_rddata_i = $random;
        //     @(negedge clk_i);            
        // end



        @(negedge clk_i);  
        $stop;

    end

    // Test monitor & Results
    initial begin
        $monitor("rstn= %b, enable= %b, valid= %h, data= %h, alert_n= %b", 
                rst_n_i, crc_en_i, pre_rddata_valid_i, dfi_rddata_i, dfi_alert_n_o);
    end

endmodule 