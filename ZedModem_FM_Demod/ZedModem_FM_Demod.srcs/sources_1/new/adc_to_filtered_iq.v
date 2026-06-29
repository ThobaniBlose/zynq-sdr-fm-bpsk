`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 04:21:26 PM
// Design Name: 
// Module Name: adc_to_filtered_iq
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

module adc_to_filtered_iq (
    input  wire clk,
    input  wire rst,

    input  wire sample_valid,
    input  wire [11:0] adc_code,

    output wire signed [12:0] i_out,
    output wire signed [12:0] q_out,
    output wire                output_valid
);

    wire signed [12:0] mixer_i;
    wire signed [12:0] mixer_q;
    wire               mixer_valid;

    adc_to_iq adc_to_iq_inst (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .adc_code(adc_code),
        .i_out(mixer_i),
        .q_out(mixer_q),
        .output_valid(mixer_valid)
    );

    iq_lpf_2tap iq_lpf_inst (
        .clk(clk),
        .rst(rst),
        .input_valid(mixer_valid),
        .i_in(mixer_i),
        .q_in(mixer_q),
        .i_out(i_out),
        .q_out(q_out),
        .output_valid(output_valid)
    );

endmodule