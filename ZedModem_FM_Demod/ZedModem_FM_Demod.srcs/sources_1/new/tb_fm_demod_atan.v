`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 12:58:47 PM
// Design Name: 
// Module Name: tb_fm_demod_atan
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

module tb_fm_demod_atan;

    reg clk;
    reg rst;
    reg input_valid;

    reg signed [12:0] i_in;
    reg signed [12:0] q_in;

    wire signed [15:0] demod_out;
    wire output_valid;

    integer errors;
    integer outputs_received;
    integer output_error;
    integer timeout;

    fm_demod_atan dut (
        .clk(clk),
        .rst(rst),
        .input_valid(input_valid),
        .i_in(i_in),
        .q_in(q_in),
        .demod_out(demod_out),
        .output_valid(output_valid)
    );

    // 100 MHz clock
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    task send_iq;
        input signed [12:0] test_i;
        input signed [12:0] test_q;
        begin
            @(negedge clk);
            i_in = test_i;
            q_in = test_q;
            input_valid = 1'b1;

            @(negedge clk);
            input_valid = 1'b0;
        end
    endtask

    // Check every demodulated output.
    always @(negedge clk) begin
        if (output_valid) begin
            outputs_received = outputs_received + 1;

            output_error = $signed(demod_out) - 8192;

            if (output_error < 0)
                output_error = -output_error;

            if (output_error > 8) begin
                $display(
                    "FAIL: expected phase difference 8192, got %d",
                    demod_out
                );
                errors = errors + 1;
            end else begin
                $display(
                    "PASS: demodulated phase difference = %d",
                    demod_out
                );
            end
        end
    end

    initial begin
        errors = 0;
        outputs_received = 0;
        output_error = 0;
        timeout = 0;

        rst = 1'b1;
        input_valid = 1'b0;
        i_in = 13'sd0;
        q_in = 13'sd0;

        repeat (5) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        repeat (3) @(posedge clk);

        $display("Starting fm_demod_atan test...");

        // Phase = 0 degrees
        send_iq(13'sd1000, 13'sd0);

        // Phase = 45 degrees
        send_iq(13'sd1000, 13'sd1000);

        // Phase = 90 degrees
        send_iq(13'sd0, 13'sd1000);

        // Phase = 135 degrees
        send_iq(-13'sd1000, 13'sd1000);

        // Phase = 180 degrees
        send_iq(-13'sd1000, 13'sd0);

        // Phase = -135 degrees, crossing the phase boundary
        send_iq(-13'sd1000, -13'sd1000);

        // Wait for five phase differences.
        while ((outputs_received < 5) && (timeout < 100)) begin
            @(posedge clk);
            timeout = timeout + 1;
        end

        if (outputs_received != 5) begin
            $display(
                "FAIL: expected 5 outputs, received %0d",
                outputs_received
            );
            errors = errors + 1;
        end

        if (errors == 0)
            $display("fm_demod_atan TEST PASSED");
        else
            $display(
                "fm_demod_atan TEST FAILED with %0d error(s)",
                errors
            );

        $finish;
    end

endmodule
