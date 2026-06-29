`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 01:45:54 PM
// Design Name: 
// Module Name: adc_center
// Project Name: zynq-sdr-fm-bpsk
// Target Devices: Zynq-7000
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


module adc_center(
    input  wire [11:0] adc_code,
    output wire signed [12:0] adc_signed
    );
    
    assign adc_signed = {1'b0, adc_code} - 13'sd2048;
    
endmodule

