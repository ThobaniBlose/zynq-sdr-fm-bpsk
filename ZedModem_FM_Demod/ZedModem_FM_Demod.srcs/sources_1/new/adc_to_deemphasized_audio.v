`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 03:33:44 PM
// Design Name: 
// Module Name: adc_to_deemphasized_audio
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

module adc_to_deemphasized_audio (
    input  wire clk,
    input  wire rst,

    input  wire        sample_valid,
    input  wire [11:0] adc_code,

    output wire signed [15:0] audio_out,
    output wire               output_valid
);

    wire signed [15:0] demodulated_signal;
    wire               demodulated_valid;

    // ADC input through the FM demodulator.
    adc_to_fm_demod demod_chain_inst (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .adc_code(adc_code),
        .demod_out(demodulated_signal),
        .output_valid(demodulated_valid)
    );

    // Apply the 50 us FM de-emphasis filter.
    deemphasis_filter deemphasis_inst (
        .clk(clk),
        .rst(rst),
        .input_valid(demodulated_valid),
        .demod_in(demodulated_signal),
        .audio_out(audio_out),
        .output_valid(output_valid)
    );

endmodule