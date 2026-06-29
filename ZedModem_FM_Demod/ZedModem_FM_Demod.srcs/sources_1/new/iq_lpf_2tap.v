`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 04:14:23 PM
// Design Name: 
// Module Name: iq_lpf_2tap
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

module iq_lpf_2tap (
    input  wire clk,
    input  wire rst,

    input  wire input_valid,
    input  wire signed [12:0] i_in,
    input  wire signed [12:0] q_in,

    output reg  signed [12:0] i_out,
    output reg  signed [12:0] q_out,
    output reg                 output_valid
);

    reg signed [12:0] previous_i;
    reg signed [12:0] previous_q;
    reg               have_previous;

    wire signed [13:0] sum_i;
    wire signed [13:0] sum_q;

    assign sum_i = {i_in[12], i_in} + {previous_i[12], previous_i};
    assign sum_q = {q_in[12], q_in} + {previous_q[12], previous_q};

    always @(posedge clk) begin

        if (rst) begin
            previous_i   <= 13'sd0;
            previous_q   <= 13'sd0;
            have_previous <= 1'b0;

            i_out        <= 13'sd0;
            q_out        <= 13'sd0;
            output_valid <= 1'b0;
        end

        else begin
            output_valid <= 1'b0;

            if (input_valid) begin

                if (have_previous) begin
                    i_out <= sum_i >>> 1;
                    q_out <= sum_q >>> 1;
                    output_valid <= 1'b1;
                end

                previous_i <= i_in;
                previous_q <= q_in;
                have_previous <= 1'b1;
            end
        end
    end

endmodule
