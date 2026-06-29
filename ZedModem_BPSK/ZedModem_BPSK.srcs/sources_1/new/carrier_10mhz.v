`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thobani Blose
// 
// Create Date: 06/29/2026 03:35:45 PM
// Design Name: 
// Module Name: carrier_10mhz
// Project Name: BPSK Transceiver Core (Radio Modem Baseline)
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

module carrier_10mhz (
    input  wire clk,          // 100 MHz clock
    input  wire rst,          // active-high reset
    output reg  carrier_out   // 10 MHz square-wave carrier
);

    // 100 MHz clock = 10 ns period
    // 10 MHz carrier = 100 ns period
    // Half period = 50 ns = 5 clock cycles
    localparam HALF_PERIOD_CYCLES = 5;

    reg [2:0] count;

    always @(posedge clk) begin
        if (rst) begin
            count       <= 0;
            carrier_out <= 0;
        end else begin
            if (count == HALF_PERIOD_CYCLES - 1) begin
                count       <= 0;
                carrier_out <= ~carrier_out;
            end else begin
                count <= count + 1;
            end
        end
    end

endmodule
