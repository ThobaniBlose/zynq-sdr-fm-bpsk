`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 12:15:40 PM
// Design Name: 
// Module Name: tb_atan2_phase
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

module tb_atan2_phase;

    reg clk;
    reg rst;
    reg input_valid;

    reg signed [12:0] i_in;
    reg signed [12:0] q_in;

    wire signed [15:0] phase_out;
    wire output_valid;

    integer errors;
    integer difference;

    atan2_phase dut (
        .clk(clk),
        .rst(rst),
        .input_valid(input_valid),
        .i_in(i_in),
        .q_in(q_in),
        .phase_out(phase_out),
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
        input signed [12:0] test_i;
        input signed [12:0] test_q;
        input signed [15:0] expected_phase;
        begin
            @(negedge clk);
            i_in = test_i;
            q_in = test_q;
            input_valid = 1'b1;

            // Send the sample for one clock period.
            @(negedge clk);
            input_valid = 1'b0;

            // Wait for the CORDIC pipeline.
            while (output_valid !== 1'b1)
                @(posedge clk);

            #1;

            // Calculate circular phase error.
            difference = $signed(phase_out)
                       - $signed(expected_phase);

            if (difference > 32767)
                difference = difference - 65536;
            else if (difference < -32768)
                difference = difference + 65536;

            if (difference < 0)
                difference = -difference;

            // Allow a few codes for CORDIC rounding.
            if (difference > 8) begin
                $display(
                    "FAIL: I=%d, Q=%d, expected phase=%d, got=%d",
                    test_i, test_q, expected_phase, phase_out
                );
                errors = errors + 1;
            end else begin
                $display(
                    "PASS: I=%d, Q=%d, phase=%d",
                    test_i, test_q, phase_out
                );
            end
        end
    endtask

    initial begin
        errors = 0;
        rst = 1'b1;
        input_valid = 1'b0;
        i_in = 13'sd0;
        q_in = 13'sd0;

        repeat (5) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        // Allow the CORDIC reset to clear internally.
        repeat (3) @(posedge clk);

        $display("Starting atan2_phase test...");

        // 0 degrees
        send_and_check(13'sd1000, 13'sd0, 16'sd0);

        // +90 degrees
        send_and_check(13'sd0, 13'sd1000, 16'sd16384);

        // 180 degrees: represented as -32768
        send_and_check(-13'sd1000, 13'sd0, -16'sd32768);

        // -90 degrees
        send_and_check(13'sd0, -13'sd1000, -16'sd16384);

        // +45 degrees
        send_and_check(13'sd1000, 13'sd1000, 16'sd8192);

        // -45 degrees
        send_and_check(13'sd1000, -13'sd1000, -16'sd8192);

        if (errors == 0)
            $display("atan2_phase TEST PASSED");
        else
            $display(
                "atan2_phase TEST FAILED with %0d error(s)",
                errors
            );

        $finish;
    end

endmodule