`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 03:12:15 PM
// Design Name: 
// Module Name: tb_nco_mixer
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

module tb_nco_mixer;

    reg clk;
    reg rst;
    reg sample_valid;
    reg signed [12:0] x_in;

    wire signed [12:0] i_out;
    wire signed [12:0] q_out;
    wire output_valid;

    integer errors;

    nco_mixer dut (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .x_in(x_in),
        .i_out(i_out),
        .q_out(q_out),
        .output_valid(output_valid)
    );

    // 100 MHz clock: 10 ns period
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    task send_and_check;
        input signed [12:0] sample;
        input signed [12:0] expected_i;
        input signed [12:0] expected_q;
        begin
            // Change inputs away from the rising edge
            @(negedge clk);
            x_in = sample;
            sample_valid = 1'b1;

            // DUT reads the input here
            @(posedge clk);
            #1;

            if (i_out !== expected_i || q_out !== expected_q) begin
                $display("FAIL: x = %d, expected I = %d, Q = %d, got I = %d, Q = %d",
                         sample, expected_i, expected_q, i_out, q_out);
                errors = errors + 1;
            end else begin
                $display("PASS: x = %d, I = %d, Q = %d",
                         sample, i_out, q_out);
            end

            // Turn sample_valid off away from the rising edge
            @(negedge clk);
            sample_valid = 1'b0;
        end
    endtask

    initial begin
        errors = 0;

        rst = 1'b1;
        sample_valid = 1'b0;
        x_in = 13'sd0;

        // Hold reset for a few clock cycles
        repeat (3) @(posedge clk);

        // Release reset away from the rising edge
        @(negedge clk);
        rst = 1'b0;

        $display("Starting nco_mixer test...");

        send_and_check(13'sd100,  13'sd100,   13'sd0);
        send_and_check(13'sd200,  13'sd0,    -13'sd200);
        send_and_check(13'sd300, -13'sd300,   13'sd0);
        send_and_check(13'sd400,  13'sd0,     13'sd400);

        if (errors == 0) begin
            $display("nco_mixer TEST PASSED");
        end else begin
            $display("nco_mixer TEST FAILED with %0d error(s)", errors);
        end

        $finish;
    end

endmodule