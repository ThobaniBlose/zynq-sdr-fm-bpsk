`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 12:15:22 PM
// Design Name: 
// Module Name: xadc_sampler
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

module xadc_sampler (
    input  wire clk,
    input  wire rst,

    input  wire vauxp1,
    input  wire vauxn1,

    output reg  [11:0] adc_code,
    output reg         sample_valid
);

    wire [15:0] xadc_data;
    wire        xadc_ready;
    wire        xadc_eoc;

    // VAUX1 conversion result register address.
    localparam [6:0] VAUX1_ADDRESS = 7'h11;

    xadc_wiz_0 xadc_inst (
        .di_in(16'd0),
        .daddr_in(VAUX1_ADDRESS),
        .den_in(xadc_eoc),
        .dwe_in(1'b0),

        .drdy_out(xadc_ready),
        .do_out(xadc_data),

        .dclk_in(clk),
        .reset_in(rst),

        .vp_in(1'b0),
        .vn_in(1'b0),

        .vauxp1(vauxp1),
        .vauxn1(vauxn1),

        .user_temp_alarm_out(),
        .vccint_alarm_out(),
        .vccaux_alarm_out(),
        .vccpint_alarm_out(),
        .vccpaux_alarm_out(),
        .vccddro_alarm_out(),
        .ot_out(),
        .channel_out(),
        .muxaddr_out(),
        .eoc_out(xadc_eoc),
        .alarm_out(),
        .eos_out(),
        .busy_out()
    );

    always @(posedge clk) begin
        if (rst) begin
            adc_code <= 12'd0;
            sample_valid <= 1'b0;
        end else begin
            sample_valid <= 1'b0;

            if (xadc_ready) begin
                adc_code <= xadc_data[15:4];
                sample_valid <= 1'b1;
            end
        end
    end

endmodule
