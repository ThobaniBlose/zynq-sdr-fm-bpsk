`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thobani Blose
// 
// Create Date: 06/29/2026 05:34:04 PM
// Design Name: 
// Module Name: bpsk_tx_top
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


module bpsk_tx_top (
    input  wire clk,
    input  wire rst,

    output wire bpsk_out,
    output wire bit_debug
);

    (* mark_debug = "true" *) wire carrier;
    (* mark_debug = "true" *) wire symbol_tick;
    (* mark_debug = "true" *) wire current_bit;
    (* mark_debug = "true" *) wire bpsk_internal;

    bpsk_tx_core #(
        .CLKS_PER_SYMBOL(1000)      // 100 ksymbols/s with 100 MHz clock
        //.BIT_PATTERN(8'b10110010)    // fixed message pattern
    ) tx_core (
        .clk(clk),
        .rst(rst),
        .carrier(carrier),
        .symbol_tick(symbol_tick),
        .current_bit(current_bit),
        .bpsk_out(bpsk_internal)
    );

    // Debug output so we can see the transmitted bit on the oscilloscope
    assign bpsk_out  = bpsk_internal;
    assign bit_debug = current_bit;

endmodule