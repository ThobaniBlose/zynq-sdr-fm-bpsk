`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 04:57:29 PM
// Design Name: 
// Module Name: fm_receiver_audio
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

module fm_receiver_audio (
    input  wire clk,
    input  wire rst,

    input  wire        sample_valid,
    input  wire [11:0] adc_code,

    output wire signed [15:0] audio_out,
    output wire               audio_valid
);

    wire signed [15:0] deemphasis_audio;
    wire               deemphasis_valid;

    wire signed [15:0] filtered_audio;
    wire               filtered_valid;

    // ADC through FM demodulation and de-emphasis.
    adc_to_deemphasized_audio demod_and_deemphasis (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .adc_code(adc_code),
        .audio_out(deemphasis_audio),
        .output_valid(deemphasis_valid)
    );

    // Remove frequencies above the audio band.
    audio_lpf_fir audio_filter (
        .clk(clk),
        .rst(rst),
        .input_valid(deemphasis_valid),
        .audio_in(deemphasis_audio),
        .audio_out(filtered_audio),
        .output_valid(filtered_valid)
    );

    // Reduce 200 kS/s to 50 kS/s.
    audio_decimator #(
        .DECIMATION_FACTOR(4)
    ) audio_rate_reducer (
        .clk(clk),
        .rst(rst),
        .input_valid(filtered_valid),
        .audio_in(filtered_audio),
        .audio_out(audio_out),
        .output_valid(audio_valid)
    );

endmodule
