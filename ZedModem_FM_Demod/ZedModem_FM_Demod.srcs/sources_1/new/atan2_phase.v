`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 11:44:53 AM
// Design Name: 
// Module Name: atan2_phase
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

module atan2_phase (
    input  wire clk,
    input  wire rst,

    input  wire input_valid,
    input  wire signed [12:0] i_in,
    input  wire signed [12:0] q_in,

    output wire signed [15:0] phase_out,
    output wire               output_valid
);

    wire signed [15:0] i_extended;
    wire signed [15:0] q_extended;

    wire signed [15:0] i_scaled;
    wire signed [15:0] q_scaled;

    wire [31:0] cartesian_data;
    wire signed [15:0] cordic_phase_data;
    wire        cordic_output_valid;

    // Extend the 13-bit inputs to 16 bits.
    assign i_extended = {{3{i_in[12]}}, i_in};
    assign q_extended = {{3{q_in[12]}}, q_in};

    // Scale the inputs to use more of the CORDIC input range.
    assign i_scaled = i_extended <<< 2;
    assign q_scaled = q_extended <<< 2;

    // CORDIC expects X in the lower half and Y in the upper half.
    assign cartesian_data = {q_scaled, i_scaled};

    cordic_atan2 cordic_inst (
        .aclk                    (clk),
        .aresetn                 (~rst),
        .s_axis_cartesian_tvalid (input_valid),
        .s_axis_cartesian_tdata  (cartesian_data),
        .m_axis_dout_tvalid      (cordic_output_valid),
        .m_axis_dout_tdata       (cordic_phase_data)
    );

    // Convert the 18-bit circular phase to our 16-bit phase format.
    assign phase_out = cordic_phase_data <<< 2;
    assign output_valid = cordic_output_valid;

endmodule
