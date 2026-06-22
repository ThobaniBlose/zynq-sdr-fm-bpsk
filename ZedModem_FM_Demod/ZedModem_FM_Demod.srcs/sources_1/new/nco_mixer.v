`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thobani Blose
// 
// Create Date: 06/19/2026 03:02:52 PM
// Design Name: 
// Module Name: nco_mixer
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


module nco_mixer (
    input  wire clk,
    input  wire rst,

    input  wire sample_valid,
    input  wire signed [12:0] x_in,

    output reg  signed [12:0] i_out,
    output reg  signed [12:0] q_out,
    output reg                 output_valid
);

    // This 2-bit counter represents the NCO phase:
    // 0, 1, 2, 3, then back to 0.
    reg [1:0] phase;

    always @(posedge clk) begin

        if (rst) begin
            phase        <= 2'd0;
            i_out        <= 13'sd0;
            q_out        <= 13'sd0;
            output_valid <= 1'b0;
        end

        else begin
            output_valid <= sample_valid;

            if (sample_valid) begin

                case (phase)

                    2'd0: begin
                        i_out <=  x_in;
                        q_out <=  13'sd0;
                    end

                    2'd1: begin
                        i_out <=  13'sd0;
                        q_out <= -x_in;
                    end

                    2'd2: begin
                        i_out <= -x_in;
                        q_out <=  13'sd0;
                    end

                    2'd3: begin
                        i_out <=  13'sd0;
                        q_out <=  x_in;
                    end

                endcase

                phase <= phase + 2'd1;
            end
        end
    end

endmodule