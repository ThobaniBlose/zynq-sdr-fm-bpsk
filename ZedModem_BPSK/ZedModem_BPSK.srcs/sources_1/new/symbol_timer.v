`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thobani Blose
// 
// Create Date: 06/29/2026 04:00:36 PM
// Design Name: 
// Module Name: symbol_timer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module symbol_timer #(
    parameter CLKS_PER_SYMBOL = 1000
)(
    input  wire clk,          // 100 MHz clock
    input  wire rst,          // active-high reset
    output reg  symbol_tick   // one-clock pulse when next symbol is due
);

    reg [15:0] count;

    always @(posedge clk) begin
        if (rst) begin
            count       <= 0;
            symbol_tick <= 0;
        end else begin
            if (count == CLKS_PER_SYMBOL - 1) begin
                count       <= 0;
                symbol_tick <= 1;
            end else begin
                count       <= count + 1;
                symbol_tick <= 0;
            end
        end
    end

endmodule