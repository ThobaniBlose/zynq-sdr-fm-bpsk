`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2026 04:58:39 PM
// Design Name: 
// Module Name: bpsk_modulator
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

module bpsk_modulator (
    input  wire carrier,
    input  wire current_bit,
    output wire bpsk_out
);

    // BPSK mapping used in this project:
    // bit 1 -> normal carrier  -> 0 degrees
    // bit 0 -> inverted carrier -> 180 degrees
    assign bpsk_out = current_bit ? carrier : ~carrier;

endmodule
