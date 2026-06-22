`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 04:23:12 PM
// Design Name: 
// Module Name: tb_adc_to_filtered_iq
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

module tb_adc_to_filtered_iq;

    reg clk;
    reg rst;
    reg sample_valid;
    reg [11:0] adc_code;

    wire signed [12:0] i_out;
    wire signed [12:0] q_out;
    wire output_valid;

    integer errors;

    adc_to_filtered_iq dut (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .adc_code(adc_code),
        .i_out(i_out),
        .q_out(q_out),
        .output_valid(output_valid)
    );

    // 100 MHz clock
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    task send_first_adc_sample;
        input [11:0] test_adc_code;
        begin
            @(negedge clk);
            adc_code = test_adc_code;
            sample_valid = 1'b1;

            @(posedge clk);

            @(negedge clk);
            sample_valid = 1'b0;

            // Wait one clock for the mixer output to reach the filter
            @(posedge clk);
            #1;

            if (output_valid !== 1'b0) begin
                $display("FAIL: first ADC sample should not produce filtered output");
                errors = errors + 1;
            end else begin
                $display("PASS: first ADC sample accepted, no filtered output yet");
            end
        end
    endtask

    task send_and_check;
        input [11:0] test_adc_code;
        input signed [12:0] expected_i;
        input signed [12:0] expected_q;
        begin
            @(negedge clk);
            adc_code = test_adc_code;
            sample_valid = 1'b1;

            @(posedge clk);

            @(negedge clk);
            sample_valid = 1'b0;

            // Wait one clock for the filtered output
            @(posedge clk);
            #1;

            if (output_valid !== 1'b1) begin
                $display("FAIL: output_valid was not high");
                errors = errors + 1;
            end

            if (i_out !== expected_i || q_out !== expected_q) begin
                $display("FAIL: adc_code = %d, expected I = %d, Q = %d, got I = %d, Q = %d",
                         test_adc_code, expected_i, expected_q, i_out, q_out);
                errors = errors + 1;
            end else begin
                $display("PASS: adc_code = %d, I = %d, Q = %d",
                         test_adc_code, i_out, q_out);
            end
        end
    endtask

    initial begin
        errors = 0;

        rst = 1'b1;
        sample_valid = 1'b0;
        adc_code = 12'd2048;

        repeat (3) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        $display("Starting adc_to_filtered_iq test...");

        send_first_adc_sample(12'd2148);

        send_and_check(12'd2248,  13'sd50,    -13'sd100);
        send_and_check(12'd2348, -13'sd150,   -13'sd100);
        send_and_check(12'd2448, -13'sd150,    13'sd200);

        if (errors == 0) begin
            $display("adc_to_filtered_iq TEST PASSED");
        end else begin
            $display("adc_to_filtered_iq TEST FAILED with %0d error(s)", errors);
        end

        $finish;
    end

endmodule
