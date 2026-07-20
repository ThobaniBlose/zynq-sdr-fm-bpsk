`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2026 12:24:24 PM
// Design Name: 
// Module Name: slow_data_gen
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


module slow_data_gen #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer OUT_HZ = 1
)(
    input  wire clk,
    input  wire rstn,
    output reg  tx_data_out
);

    localparam integer HALF_PERIOD_COUNT = CLK_HZ / (2 * OUT_HZ);

    reg [31:0] count;

    always @(posedge clk) begin
        if (!rstn) begin
            count       <= 32'd0;
            tx_data_out <= 1'b0;
        end else begin
            if (count == HALF_PERIOD_COUNT - 1) begin
                count       <= 32'd0;
                tx_data_out <= ~tx_data_out;
            end else begin
                count <= count + 1;
            end
        end
    end

endmodule
