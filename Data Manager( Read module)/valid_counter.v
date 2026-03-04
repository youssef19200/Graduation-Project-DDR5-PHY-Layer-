// File: valid_counter.v
`timescale 1ns / 1ps

module valid_counter (
    input clk,
    input reset_n,   // active-low global reset
    input en,
    input [4:0] count,
    output reg done,
    input reset
);

    reg [4:0] counter;
    reg counting;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter  <= 5'd0;
            counting <= 1'b0;
            done     <= 1'b0;
        end 
        else if (reset) begin
            counter  <= 5'd0;
            counting <= 1'b0;
            done     <= 1'b0;
        end 
        else begin
            done <= 1'b0; // default (pulse)

            if (en && !counting) begin
                counting <= 1'b1;
                counter  <= 5'd0;
            end 
            else if (counting) begin
                if (counter < count) begin
                    counter <= counter + 1'b1;
                end 
                else begin
                    done     <= 1'b1;   // pulse done
                    counting <= 1'b0;   // stop counting
                end
            end
        end
    end

endmodule
