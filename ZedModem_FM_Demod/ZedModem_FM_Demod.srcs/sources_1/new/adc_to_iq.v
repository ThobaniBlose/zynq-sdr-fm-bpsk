`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Cape Town
// Engineer: Thobani Blose
// 
// Create Date: 06/19/2026 03:46:09 PM
// Design Name: 
// Module Name: adc_to_iq
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

module adc_to_iq (
    input  wire clk,
    input  wire rst,

    input  wire sample_valid,
    input  wire [11:0] adc_code,

    output wire signed [12:0] i_out,
    output wire signed [12:0] q_out,
    output wire                output_valid
);

    wire signed [12:0] adc_signed;

    adc_center adc_center_inst (
        .adc_code(adc_code),
        .adc_signed(adc_signed)
    );

    nco_mixer nco_mixer_inst (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .x_in(adc_signed),
        .i_out(i_out),
        .q_out(q_out),
        .output_valid(output_valid)
    );

endmodule
