`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 11:00:29 AM
// Design Name: 
// Module Name: tb_phase_difference
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


module tb_phase_difference;

    reg clk;
    reg rst;
    reg input_valid;
    reg signed [15:0] phase_in;

    wire signed [15:0] phase_diff;
    wire output_valid;

    integer errors;

    phase_difference dut (
        .clk(clk),
        .rst(rst),
        .input_valid(input_valid),
        .phase_in(phase_in),
        .phase_diff(phase_diff),
        .output_valid(output_valid)
    );

    // 100 MHz clock
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    task send_first_phase;
        input signed [15:0] test_phase;
        begin
            @(negedge clk);
            phase_in = test_phase;
            input_valid = 1'b1;

            @(posedge clk);
            #1;

            if (output_valid !== 1'b0) begin
                $display("FAIL: first phase should not produce output");
                errors = errors + 1;
            end else begin
                $display("PASS: first phase stored, no output yet");
            end

            @(negedge clk);
            input_valid = 1'b0;
        end
    endtask

    task send_and_check;
        input signed [15:0] test_phase;
        input signed [15:0] expected_diff;
        begin
            @(negedge clk);
            phase_in = test_phase;
            input_valid = 1'b1;

            @(posedge clk);
            #1;

            if (output_valid !== 1'b1) begin
                $display("FAIL: output_valid was not high");
                errors = errors + 1;
            end

            if (phase_diff !== expected_diff) begin
                $display(
                    "FAIL: phase = %d, expected difference = %d, got = %d",
                    test_phase, expected_diff, phase_diff
                );
                errors = errors + 1;
            end else begin
                $display(
                    "PASS: phase = %d, difference = %d",
                    test_phase, phase_diff
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
        phase_in = 16'sd0;

        repeat (3) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        $display("Starting phase_difference test...");

        // First phase is only stored
        send_first_phase(16'sd1000);

        // 1500 - 1000 = 500
        send_and_check(16'sd1500, 16'sd500);

        // -500 - 1500 = -2000
        send_and_check(-16'sd500, -16'sd2000);

        // 32000 - (-500) = 32500
        send_and_check(16'sd32000, 16'sd32500);

        // Crossing from +pi to -pi wraps to +1536
        send_and_check(-16'sd32000, 16'sd1536);

        // Crossing back wraps to -1536
        send_and_check(16'sd32000, -16'sd1536);

        if (errors == 0)
            $display("phase_difference TEST PASSED");
        else
            $display("phase_difference TEST FAILED with %0d error(s)", errors);

        $finish;
    end

endmodule
