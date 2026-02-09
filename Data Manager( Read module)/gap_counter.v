// File: gap_counter.v (CORRECTED - PROPER OVERFLOW HANDLING)
`timescale 1ns / 1ps
module gap_counter (
    input clk,
    input reset_n,
    input rddata_en,
    output wire gap_valid,
    output wire [4:0] gap_count,
    output wire fifo_write,
    output wire overflow,
    output wire reset
);
    reg [4:0] counter;
    reg counting;
    reg last_rddata_en;
    reg [4:0] saved_gap;
    reg gap_valid_reg;
    reg overflow_reg;
    
    // Edge detection for rddata_en
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            last_rddata_en <= 1'b0;
        end else begin
            last_rddata_en <= rddata_en;
        end
    end
    
    assign fifo_write = (last_rddata_en == 1'b0) && (rddata_en == 1'b1); // rising edge
    assign reset      = (last_rddata_en == 1'b1) && (rddata_en == 1'b0); // falling edge
    
    // Counter Logic - CORRECTED OVERFLOW HANDLING
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 5'd0;
            counting <= 1'b0;
            saved_gap <= 5'd0;
            gap_valid_reg <= 1'b0;
            overflow_reg <= 1'b0;
        end else begin

                 // Reset handling (falling edge of rddata_en)
                  //if (reset) begin
                  //counter <= 5'd0;
                  //counting <= 1'b0;
                  //end
                // Handle FIFO write (read command rising edge)
                 if (fifo_write) begin
                // FIRST READ: gap_valid=1, gap=0
                if (!gap_valid_reg) begin
                    gap_valid_reg <= 1'b1;
                    saved_gap <= 5'd0;
                end 
                // SUBSEQUENT READS: save measured gap
                else begin
                    saved_gap <= counter;
                end
                
                // CRITICAL FIX: Reset overflow on EVERY read command
                overflow_reg <= 1'b0;
                
                // Reset counter and start counting for next gap
                counter <= 5'd0;
                counting <= 1'b1;
            end 
            // Counting between reads
            else if (counting) begin
                if (counter == 5'd31) begin
                    // Set overflow ONLY when counter saturates
                    overflow_reg <= 1'b1;
                    counter <= 5'd31; // Saturate (don't wrap around)
                end else begin
                    counter <= counter + 1'b1;
                    // Keep overflow=0 during normal counting
                    overflow_reg <= 1'b0;
                end
            end
        
        end
    end
    
    assign gap_count = saved_gap;
    assign gap_valid = gap_valid_reg;
    assign overflow = overflow_reg;
endmodule