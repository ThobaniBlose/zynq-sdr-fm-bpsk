`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thobani Blose
// 
// Create Date: 06/29/2026 04:38:47 PM
// Design Name: 
// Module Name: bpsk_bit_source
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

module bpsk_bit_source #(
    parameter BIT_PATTERN = 8'b10110010
)(
    input  wire clk,
    input  wire rst,
    input  wire symbol_tick,
    output reg  current_bit
);

    reg [7:0] shift_reg;

    always @(posedge clk) begin
        if (rst) begin
            shift_reg   <= BIT_PATTERN;
            current_bit <= BIT_PATTERN[7];   // first bit
        end else begin
            if (symbol_tick) begin
                shift_reg   <= {shift_reg[6:0], shift_reg[7]};
                current_bit <= shift_reg[6]; // next bit after shifting
            end
        end
    end

endmodule