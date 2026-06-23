`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 04:28:33 PM
// Design Name: 
// Module Name: audio_lpf_fir
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

module audio_lpf_fir (
    input  wire clk,
    input  wire rst,
    input  wire input_valid,
    input  wire signed [15:0] audio_in,
    output reg  signed [15:0] audio_out,
    output reg output_valid
);

    localparam STATE_IDLE  = 3'd0;
    localparam STATE_READ  = 3'd1;
    localparam STATE_PAIR  = 3'd2;
    localparam STATE_MULT  = 3'd3;
    localparam STATE_ACCUM = 3'd4;

    reg [2:0] state;

    reg signed [15:0] samples [0:62];

    reg signed [39:0] accumulator;
    reg [5:0] tap_index;

    reg signed [15:0] left_sample_reg;
    reg signed [15:0] right_sample_reg;
    reg signed [15:0] coefficient_reg;
    reg center_tap_reg;

    reg signed [16:0] multiply_sample_reg;
    reg signed [32:0] product_reg;

    integer k;

    wire signed [15:0] coefficient;
    wire signed [39:0] extended_product;
    wire signed [39:0] next_accumulator;

    audio_lpf_coeff coefficient_rom (
        .address(tap_index),
        .coefficient(coefficient)
    );

    assign extended_product =
        {{7{product_reg[32]}}, product_reg};

    assign next_accumulator =
        accumulator + extended_product;

    always @(posedge clk) begin
        if (rst) begin
            state <= STATE_IDLE;

            accumulator <= 40'sd0;
            tap_index <= 6'd0;

            left_sample_reg <= 16'sd0;
            right_sample_reg <= 16'sd0;
            coefficient_reg <= 16'sd0;
            center_tap_reg <= 1'b0;

            multiply_sample_reg <= 17'sd0;
            product_reg <= 33'sd0;

            audio_out <= 16'sd0;
            output_valid <= 1'b0;

            for (k = 0; k < 63; k = k + 1)
                samples[k] <= 16'sd0;
        end else begin
            output_valid <= 1'b0;

            case (state)
                STATE_IDLE: begin
                    if (input_valid) begin
                        for (k = 62; k > 0; k = k - 1)
                            samples[k] <= samples[k-1];

                        samples[0] <= audio_in;

                        accumulator <= 40'sd0;
                        tap_index <= 6'd0;
                        state <= STATE_READ;
                    end
                end

                STATE_READ: begin
                    left_sample_reg <= samples[tap_index];
                    right_sample_reg <= samples[6'd62 - tap_index];
                    coefficient_reg <= coefficient;
                    center_tap_reg <= (tap_index == 6'd31);
                    state <= STATE_PAIR;
                end

                STATE_PAIR: begin
                    if (center_tap_reg) begin
                        multiply_sample_reg <=
                            {left_sample_reg[15], left_sample_reg};
                    end else begin
                        multiply_sample_reg <=
                            {left_sample_reg[15], left_sample_reg}
                            + {right_sample_reg[15], right_sample_reg};
                    end

                    state <= STATE_MULT;
                end

                STATE_MULT: begin
                    product_reg <= multiply_sample_reg * coefficient_reg;
                    state <= STATE_ACCUM;
                end

                STATE_ACCUM: begin
                    if (tap_index == 6'd31) begin
                        audio_out <= next_accumulator >>> 15;
                        output_valid <= 1'b1;
                        state <= STATE_IDLE;
                    end else begin
                        accumulator <= next_accumulator;
                        tap_index <= tap_index + 1'b1;
                        state <= STATE_READ;
                    end
                end

                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule