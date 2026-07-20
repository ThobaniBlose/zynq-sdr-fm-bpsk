`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thobani Blose
// 
// Create Date: 07/02/2026 05:10:10 PM
// Design Name: 
// Module Name: bpsk_prbs7_source
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

module bpsk_prbs7_source #(
    parameter SEED = 7'b1011101
)(
    input  wire clk,
    input  wire rst,
    input  wire symbol_tick,
    output reg  current_bit
);

    reg [6:0] lfsr;
    wire feedback;

    // PRBS-7 polynomial: x^7 + x^6 + 1
    // Feedback is XOR of bit 6 and bit 5
    assign feedback = lfsr[6] ^ lfsr[5];

    always @(posedge clk) begin
        if (rst) begin
            lfsr        <= SEED;
            current_bit <= SEED[6];
        end else begin
            if (symbol_tick) begin
                lfsr        <= {lfsr[5:0], feedback};
                current_bit <= lfsr[5];
            end
        end
    end

endmodule
