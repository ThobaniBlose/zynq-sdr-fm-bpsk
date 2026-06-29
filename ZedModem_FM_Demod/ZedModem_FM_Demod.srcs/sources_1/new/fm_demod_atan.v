`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 12:55:28 PM
// Design Name: 
// Module Name: fm_demod_atan
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


module fm_demod_atan (
    input  wire clk,
    input  wire rst,

    input  wire input_valid,
    input  wire signed [12:0] i_in,
    input  wire signed [12:0] q_in,

    output wire signed [15:0] demod_out,
    output wire               output_valid
);

    wire signed [15:0] phase;
    wire               phase_valid;

    // Convert I/Q into phase.
    atan2_phase atan2_inst (
        .clk(clk),
        .rst(rst),
        .input_valid(input_valid),
        .i_in(i_in),
        .q_in(q_in),
        .phase_out(phase),
        .output_valid(phase_valid)
    );

    // Calculate the phase change between consecutive samples.
    phase_difference phase_difference_inst (
        .clk(clk),
        .rst(rst),
        .input_valid(phase_valid),
        .phase_in(phase),
        .phase_diff(demod_out),
        .output_valid(output_valid)
    );

endmodule
