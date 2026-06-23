`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 12:41:16 PM
// Design Name: 
// Module Name: fm_receiver_hardware_top
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

module fm_receiver_hardware_top (
    input  wire clk,
    input  wire rst,

    input  wire vauxp1,
    input  wire vauxn1,

    output wire pwm_audio
);

    wire [11:0] adc_code;
    wire        sample_valid;

    wire signed [15:0] audio_out;
    wire               audio_valid;

    xadc_sampler adc_sampler_inst (
        .clk(clk),
        .rst(rst),
        .vauxp1(vauxp1),
        .vauxn1(vauxn1),
        .adc_code(adc_code),
        .sample_valid(sample_valid)
    );

    fm_receiver_audio receiver_inst (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .adc_code(adc_code),
        .audio_out(audio_out),
        .audio_valid(audio_valid)
    );

    audio_pwm pwm_inst (
        .clk(clk),
        .rst(rst),
        .audio_in(audio_out),
        .audio_valid(audio_valid),
        .pwm_out(pwm_audio)
    );

endmodule