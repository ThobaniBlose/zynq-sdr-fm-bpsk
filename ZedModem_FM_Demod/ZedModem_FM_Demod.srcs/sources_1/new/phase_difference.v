`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 10:53:18 AM
// Design Name: 
// Module Name: phase_difference
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

module phase_difference (
    input  wire clk,
    input  wire rst,

    input  wire input_valid,
    input  wire signed [15:0] phase_in,

    output reg  signed [15:0] phase_diff,
    output reg                 output_valid
);

    reg signed [15:0] previous_phase;
    reg               have_previous;

    always @(posedge clk) begin

        if (rst) begin
            previous_phase <= 16'sd0;
            have_previous  <= 1'b0;

            phase_diff     <= 16'sd0;
            output_valid   <= 1'b0;
        end

        else begin
            output_valid <= 1'b0;

            if (input_valid) begin

                if (have_previous) begin
                    phase_diff   <= phase_in - previous_phase;
                    output_valid <= 1'b1;
                end

                previous_phase <= phase_in;
                have_previous  <= 1'b1;
            end
        end
    end

endmodule
