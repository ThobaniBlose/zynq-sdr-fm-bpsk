`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 04:39:41 PM
// Design Name: 
// Module Name: audio_lpf_coeff
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

module audio_lpf_coeff (
    input  wire [5:0] address,
    output reg signed [15:0] coefficient
);

    always @(*) begin
        case (address)
             0: coefficient =  16'sd16;
             1: coefficient =  16'sd0;
             2: coefficient = -16'sd19;
             3: coefficient = -16'sd36;
             4: coefficient = -16'sd43;
             5: coefficient = -16'sd33;
             6: coefficient =  16'sd0;
             7: coefficient =  16'sd49;
             8: coefficient =  16'sd96;
             9: coefficient =  16'sd117;
            10: coefficient =  16'sd87;
            11: coefficient =  16'sd0;
            12: coefficient = -16'sd123;
            13: coefficient = -16'sd234;
            14: coefficient = -16'sd275;
            15: coefficient = -16'sd198;
            16: coefficient =  16'sd0;
            17: coefficient =  16'sd267;
            18: coefficient =  16'sd501;
            19: coefficient =  16'sd579;
            20: coefficient =  16'sd414;
            21: coefficient =  16'sd0;
            22: coefficient = -16'sd560;
            23: coefficient = -16'sd1064;
            24: coefficient = -16'sd1261;
            25: coefficient = -16'sd939;
            26: coefficient =  16'sd0;
            27: coefficient =  16'sd1477;
            28: coefficient =  16'sd3241;
            29: coefficient =  16'sd4920;
            30: coefficient =  16'sd6124;
            31: coefficient =  16'sd6562;
            default: coefficient = 16'sd0;
        endcase
    end

endmodule
