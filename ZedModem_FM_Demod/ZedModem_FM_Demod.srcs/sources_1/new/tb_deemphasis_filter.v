`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 03:16:43 PM
// Design Name: 
// Module Name: tb_deemphasis_filter
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

module tb_deemphasis_filter;

    reg clk;
    reg rst;
    reg input_valid;
    reg signed [15:0] demod_in;

    wire signed [15:0] audio_out;
    wire output_valid;

    integer errors;

    deemphasis_filter dut (
        .clk(clk),
        .rst(rst),
        .input_valid(input_valid),
        .demod_in(demod_in),
        .audio_out(audio_out),
        .output_valid(output_valid)
    );

    // 100 MHz clock
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    task send_and_check;
        input signed [15:0] test_input;
        input signed [15:0] expected_output;
        begin
            @(negedge clk);
            demod_in = test_input;
            input_valid = 1'b1;

            @(posedge clk);
            #1;

            if (output_valid !== 1'b1) begin
                $display("FAIL: output_valid was not high");
                errors = errors + 1;
            end

            if (audio_out !== expected_output) begin
                $display(
                    "FAIL: expected=%d, got=%d",
                    expected_output,
                    audio_out
                );
                errors = errors + 1;
            end else begin
                $display(
                    "PASS: input=%d, output=%d",
                    test_input,
                    audio_out
                );
            end

            @(negedge clk);
            input_valid = 1'b0;
        end
    endtask

    initial begin
        errors = 0;

        rst = 1'b1;
        input_valid = 1'b0;
        demod_in = 16'sd0;

        repeat (3) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        $display("Starting deemphasis_filter test...");

        // Constant input: output should rise gradually.
        send_and_check(16'sd10000, 16'sd951);
        send_and_check(16'sd10000, 16'sd1812);
        send_and_check(16'sd10000, 16'sd2591);
        send_and_check(16'sd10000, 16'sd3295);
        send_and_check(16'sd10000, 16'sd3933);
        send_and_check(16'sd10000, 16'sd4510);
        send_and_check(16'sd10000, 16'sd5032);
        send_and_check(16'sd10000, 16'sd5504);

        if (errors == 0)
            $display("deemphasis_filter TEST PASSED");
        else
            $display(
                "deemphasis_filter TEST FAILED with %0d error(s)",
                errors
            );

        $finish;
    end

endmodule
