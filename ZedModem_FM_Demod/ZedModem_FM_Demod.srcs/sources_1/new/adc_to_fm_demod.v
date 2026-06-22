`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 01:20:14 PM
// Design Name: 
// Module Name: adc_to_fm_demod
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


module adc_to_fm_demod (
    input  wire clk,
    input  wire rst,

    input  wire        sample_valid,
    input  wire [11:0] adc_code,

    output wire signed [15:0] demod_out,
    output wire               output_valid
);

    wire signed [12:0] filtered_i;
    wire signed [12:0] filtered_q;
    wire               filtered_iq_valid;

    // ADC code to filtered I/Q samples.
    adc_to_filtered_iq iq_chain_inst (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .adc_code(adc_code),
        .i_out(filtered_i),
        .q_out(filtered_q),
        .output_valid(filtered_iq_valid)
    );

    // Filtered I/Q samples to FM-demodulated output.
    fm_demod_atan demod_inst (
        .clk(clk),
        .rst(rst),
        .input_valid(filtered_iq_valid),
        .i_in(filtered_i),
        .q_in(filtered_q),
        .demod_out(demod_out),
        .output_valid(output_valid)
    );

endmodule
