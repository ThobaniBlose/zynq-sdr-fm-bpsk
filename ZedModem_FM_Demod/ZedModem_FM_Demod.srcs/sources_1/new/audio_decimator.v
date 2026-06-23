`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 04:46:32 PM
// Design Name: 
// Module Name: audio_decimator
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

module audio_decimator #(
    parameter DECIMATION_FACTOR = 4
)(
    input  wire clk,
    input  wire rst,

    input  wire input_valid,
    input  wire signed [15:0] audio_in,

    output reg signed [15:0] audio_out,
    output reg output_valid
);

    reg [7:0] sample_count;

    always @(posedge clk) begin
        if (rst) begin
            sample_count <= 8'd0;
            audio_out    <= 16'sd0;
            output_valid <= 1'b0;
        end else begin
            output_valid <= 1'b0;

            if (input_valid) begin
                if (sample_count == DECIMATION_FACTOR - 1) begin
                    audio_out    <= audio_in;
                    output_valid <= 1'b1;
                    sample_count <= 8'd0;
                end else begin
                    sample_count <= sample_count + 1'b1;
                end
            end
        end
    end

endmodule
