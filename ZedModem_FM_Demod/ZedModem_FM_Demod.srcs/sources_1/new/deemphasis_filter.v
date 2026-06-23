`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 03:09:51 PM
// Design Name: 
// Module Name: deemphasis_filter
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

module deemphasis_filter (
    input  wire clk,
    input  wire rst,

    input  wire input_valid,
    input  wire signed [15:0] demod_in,

    output reg  signed [15:0] audio_out,
    output reg                output_valid
);

    // Q15 coefficients:
    // 29650 / 32768 = 0.90485
    //  3118 / 32768 = 0.09515
    localparam signed [15:0] ALPHA = 16'sd29650;
    localparam signed [15:0] BETA  = 16'sd3118;

    reg signed [15:0] previous_output;

    wire signed [31:0] feedback_product;
    wire signed [31:0] input_product;
    wire signed [32:0] product_sum;
    wire signed [32:0] scaled_result;

    assign feedback_product = previous_output * ALPHA;
    assign input_product    = demod_in * BETA;

    assign product_sum =
        {feedback_product[31], feedback_product}
        +
        {input_product[31], input_product};

    // Divide the Q15 result by 32768.
    assign scaled_result = product_sum >>> 15;

    always @(posedge clk) begin
        if (rst) begin
            previous_output <= 16'sd0;
            audio_out       <= 16'sd0;
            output_valid    <= 1'b0;
        end else begin
            output_valid <= 1'b0;

            if (input_valid) begin
                audio_out       <= scaled_result[15:0];
                previous_output <= scaled_result[15:0];
                output_valid    <= 1'b1;
            end
        end
    end

endmodule