`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thobani Blose
// 
// Create Date: 06/29/2026 05:08:51 PM
// Design Name: 
// Module Name: bpsk_tx_core
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

module bpsk_tx_core #(
    parameter CLKS_PER_SYMBOL = 1000,
    parameter BIT_PATTERN     = 8'b10110010
)(
    input  wire clk,
    input  wire rst,

    output wire carrier,
    output wire symbol_tick,
    output wire current_bit,
    output wire bpsk_out
);

    carrier_10mhz carrier_gen (
        .clk(clk),
        .rst(rst),
        .carrier_out(carrier)
    );

    symbol_timer #(
        .CLKS_PER_SYMBOL(CLKS_PER_SYMBOL)
    ) timer (
        .clk(clk),
        .rst(rst),
        .symbol_tick(symbol_tick)
    );

    bpsk_bit_source #(
        .BIT_PATTERN(BIT_PATTERN)
    ) bit_source (
        .clk(clk),
        .rst(rst),
        .symbol_tick(symbol_tick),
        .current_bit(current_bit)
    );

    bpsk_modulator modulator (
        .carrier(carrier),
        .current_bit(current_bit),
        .bpsk_out(bpsk_out)
    );

endmodule
