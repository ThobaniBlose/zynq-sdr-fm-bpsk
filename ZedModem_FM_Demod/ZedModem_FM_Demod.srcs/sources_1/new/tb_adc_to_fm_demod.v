`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 01:23:09 PM
// Design Name: 
// Module Name: tb_adc_to_fm_demod
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

module tb_adc_to_fm_demod;

    reg clk;
    reg rst;
    reg sample_valid;
    reg [11:0] adc_code;

    wire signed [15:0] demod_out;
    wire output_valid;

    integer errors;
    integer outputs_received;
    integer output_error;
    integer timeout;

    adc_to_fm_demod dut (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .adc_code(adc_code),
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

    task send_adc;
        input [11:0] test_code;
        begin
            @(negedge clk);
            adc_code = test_code;
            sample_valid = 1'b1;

            @(negedge clk);
            sample_valid = 1'b0;
        end
    endtask

    always @(negedge clk) begin
        if (output_valid) begin
            outputs_received = outputs_received + 1;

            output_error = $signed(demod_out) - (-16384);

            if (output_error < 0)
                output_error = -output_error;

            if (output_error > 8) begin
                $display(
                    "FAIL: expected -16384, got %d",
                    demod_out
                );
                errors = errors + 1;
            end else begin
                $display(
                    "PASS: demodulated output = %d",
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
        sample_valid = 1'b0;
        adc_code = 12'd2048;

        repeat (5) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        repeat (3) @(posedge clk);

        $display("Starting adc_to_fm_demod test...");

        // Six identical ADC samples.
        repeat (6) begin
            send_adc(12'd3048);
        end

        // Six ADC samples produce four phase differences.
        while ((outputs_received < 4) && (timeout < 100)) begin
            @(posedge clk);
            timeout = timeout + 1;
        end

        if (outputs_received != 4) begin
            $display(
                "FAIL: expected 4 outputs, received %0d",
                outputs_received
            );
            errors = errors + 1;
        end

        if (errors == 0)
            $display("adc_to_fm_demod TEST PASSED");
        else
            $display(
                "adc_to_fm_demod TEST FAILED with %0d error(s)",
                errors
            );

        $finish;
    end

endmodule
