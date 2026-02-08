/**********************************************************************************
** Graduation project_S26
** Author: Ahmed Mohamed Zakaria
**
** Module Name: ddr5_phy_crc_tb
** Description: this file contains the Test-bench of CRC Generation
**
*********************************************************************************/

module ddr5_phy_crc_gen_tb ();

    // Parameters
    parameter pDRAM_SIZE = 4;

    // input signals //
    reg   clk_i;
    reg   rst_n_i;
    reg   crc_en_i;
    reg [2*pDRAM_SIZE-1: 0] crc_in_data_i;
    // output signals //
    wire [2*pDRAM_SIZE-1: 0] crc_code_o;


    // DUT Instantiate
    ddr5_phy_crc_gen #(.pDRAM_SIZE(pDRAM_SIZE)) CRC_gen_U (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .crc_en_i(crc_en_i),
        .crc_in_data_i(crc_in_data_i),
        .crc_code_o(crc_code_o)
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
        crc_in_data_i = {(2*pDRAM_SIZE){1'b0}};
        @(negedge clk_i);
        rst_n_i = 1;
        @(negedge clk_i);
        end
    endtask

    initial begin
        
        reset_dut();

/*
        // Let the pDRAM_SIZE = 4  &  crc_in_data = 16'h ABCDEFABCDEF7632   //////////////// crc_code => 2'h11
        crc_en_i = 1;      // enable CRC

        crc_in_data_i = 'hAB;
        @(negedge clk_i);

        crc_in_data_i = 'hCD;
        @(negedge clk_i);       
            
        crc_in_data_i = 'hEF;
        @(negedge clk_i);
            
        crc_in_data_i = 'hAB;
        @(negedge clk_i);                        
            
        crc_in_data_i = 'hCD;
        @(negedge clk_i);            
            
        crc_in_data_i = 'hEF;
        @(negedge clk_i);            
            
        crc_in_data_i = 'h76;
        @(negedge clk_i);
            
        crc_in_data_i = 'h32;
        @(negedge clk_i);   

        crc_en_i = 0;
        @(negedge clk_i);
*/

/*
        // // Let the pDRAM_SIZE = 4  &  crc_in_data = 16'h 9876543210985410   //////////////// crc_code => 2'h82
        crc_en_i = 1;      // enable CRC

        crc_in_data_i = 'h98;
        @(negedge clk_i);

        crc_in_data_i = 'h76;
        @(negedge clk_i);       
            
        crc_in_data_i = 'h54;
        @(negedge clk_i);
            
        crc_in_data_i = 'h32;
        @(negedge clk_i);                        
            
        crc_in_data_i = 'h10;
        @(negedge clk_i);            
            
        crc_in_data_i = 'h98;
        @(negedge clk_i);            
            
        crc_in_data_i = 'h54;
        @(negedge clk_i);
            
        crc_in_data_i = 'h10;
        @(negedge clk_i); 

        crc_en_i = 0;
        @(negedge clk_i);  
*/



        // Let the pDRAM_SIZE = 8  &   crc_in_data = 32'h AB98CD76EF54AB32CD10EF9876543210   //////   crc_code => 2'h1182
        crc_en_i = 1;         // enable CRC

        crc_in_data_i = 'hAB98;
        @(negedge clk_i);

        crc_in_data_i = 'hCD76;
        @(negedge clk_i);       
            
        crc_in_data_i = 'hEF54;
        @(negedge clk_i);
            
        crc_in_data_i = 'hAB32;
        @(negedge clk_i);                        
            
        crc_in_data_i = 'hCD10;
        @(negedge clk_i);            
            
        crc_in_data_i = 'hEF98;
        @(negedge clk_i);            
            
        crc_in_data_i = 'h7654;
        @(negedge clk_i);
            
        crc_in_data_i = 'h3210;
        @(negedge clk_i); 

        crc_en_i = 0;
        @(negedge clk_i);  


        // // Let Random crc_in_data
        // crc_en_i = 1;        // enable CRC
        // repeat (8) begin
        //     crc_in_data_i = $random;
        //     @(negedge clk_i);            
        // end
        // crc_en_i = 0;
        // @(negedge clk_i);  


        $display("Direct Test CRC Result: %h", crc_code_o);

        $stop;

    end

    // Test monitor & Results
    initial begin
        $monitor("rstn= %b, enable= %b, data_in= %h, crc_out= %h", 
                rst_n_i, crc_en_i, crc_in_data_i, crc_code_o);
    end

endmodule 