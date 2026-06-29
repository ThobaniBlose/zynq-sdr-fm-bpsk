`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 04:17:39 PM
// Design Name: 
// Module Name: tb_iq_lpf_2tap
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

module tb_iq_lpf_2tap;

    reg clk;
    reg rst;
    reg input_valid;

    reg signed [12:0] i_in;
    reg signed [12:0] q_in;

    wire signed [12:0] i_out;
    wire signed [12:0] q_out;
    wire output_valid;

    integer errors;

    iq_lpf_2tap dut (
        .clk(clk),
        .rst(rst),
        .input_valid(input_valid),
        .i_in(i_in),
        .q_in(q_in),
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

    task send_first_sample;
        input signed [12:0] test_i;
        input signed [12:0] test_q;
        begin
            @(negedge clk);
            i_in = test_i;
            q_in = test_q;
            input_valid = 1'b1;

            @(posedge clk);
            #1;

            if (output_valid !== 1'b0) begin
                $display("FAIL: first sample should not produce output");
                errors = errors + 1;
            end else begin
                $display("PASS: first sample accepted, no output yet");
            end

            @(negedge clk);
            input_valid = 1'b0;
        end
    endtask

    task send_and_check;
        input signed [12:0] test_i;
        input signed [12:0] test_q;
        input signed [12:0] expected_i;
        input signed [12:0] expected_q;
        begin
            @(negedge clk);
            i_in = test_i;
            q_in = test_q;
            input_valid = 1'b1;

            @(posedge clk);
            #1;

            if (output_valid !== 1'b1) begin
                $display("FAIL: output_valid was not high");
                errors = errors + 1;
            end

            if (i_out !== expected_i || q_out !== expected_q) begin
                $display("FAIL: input I = %d, Q = %d, expected I = %d, Q = %d, got I = %d, Q = %d",
                         test_i, test_q, expected_i, expected_q, i_out, q_out);
                errors = errors + 1;
            end else begin
                $display("PASS: input I = %d, Q = %d, output I = %d, Q = %d",
                         test_i, test_q, i_out, q_out);
            end

            @(negedge clk);
            input_valid = 1'b0;
        end
    endtask

    initial begin
        errors = 0;

        rst = 1'b1;
        input_valid = 1'b0;
        i_in = 13'sd0;
        q_in = 13'sd0;

        repeat (3) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        $display("Starting iq_lpf_2tap test...");

        // First sample: no output yet
        send_first_sample(13'sd100, 13'sd20);

        // Average of 100 and 200 = 150
        // Average of 20 and 40 = 30
        send_and_check(13'sd200, 13'sd40, 13'sd150, 13'sd30);

        // Average of 200 and -100 = 50
        // Average of 40 and -20 = 10
        send_and_check(-13'sd100, -13'sd20, 13'sd50, 13'sd10);

        // Average of -100 and -300 = -200
        // Average of -20 and 100 = 40
        send_and_check(-13'sd300, 13'sd100, -13'sd200, 13'sd40);

        if (errors == 0) begin
            $display("iq_lpf_2tap TEST PASSED");
        end else begin
            $display("iq_lpf_2tap TEST FAILED with %0d error(s)", errors);
        end

        $finish;
    end

endmodule