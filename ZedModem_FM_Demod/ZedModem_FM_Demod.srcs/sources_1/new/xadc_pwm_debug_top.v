`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 05:08:20 PM
// Design Name: 
// Module Name: xadc_pwm_debug_top
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

module xadc_pwm_debug_top (
    input  wire clk,
    input  wire rst,

    input  wire vauxp1,
    input  wire vauxn1,

    output wire pwm_audio
);

    wire [11:0] adc_code;
    wire        sample_valid;

    wire signed [15:0] adc_as_audio;

    xadc_sampler adc_sampler_inst (
        .clk(clk),
        .rst(rst),
        .vauxp1(vauxp1),
        .vauxn1(vauxn1),
        .adc_code(adc_code),
        .sample_valid(sample_valid)
    );

    // Convert 12-bit unsigned ADC code into signed 16-bit audio-like value.
    assign adc_as_audio = {adc_code, 4'b0000} - 16'sd32768;

    audio_pwm pwm_inst (
        .clk(clk),
        .rst(rst),
        .audio_in(adc_as_audio),
        .audio_valid(sample_valid),
        .pwm_out(pwm_audio)
    );

endmodule
