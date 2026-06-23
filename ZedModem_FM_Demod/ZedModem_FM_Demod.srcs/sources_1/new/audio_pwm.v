`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 02:41:48 PM
// Design Name: 
// Module Name: audio_pwm
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

module audio_pwm (
    input  wire clk,
    input  wire rst,

    input  wire signed [15:0] audio_in,
    input  wire               audio_valid,

    output reg pwm_out
);

    reg [7:0] pwm_counter;
    reg [7:0] pwm_level;

    wire [15:0] unsigned_audio;

    assign unsigned_audio = audio_in + 16'sd32768;

    always @(posedge clk) begin
        if (rst) begin
            pwm_counter <= 8'd0;
            pwm_level   <= 8'd128;
            pwm_out     <= 1'b0;
        end else begin
            pwm_counter <= pwm_counter + 1'b1;

            if (audio_valid)
                pwm_level <= unsigned_audio[15:8];

            pwm_out <= (pwm_counter < pwm_level);
        end
    end

endmodule
