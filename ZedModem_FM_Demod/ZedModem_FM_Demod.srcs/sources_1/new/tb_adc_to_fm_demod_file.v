`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 02:51:07 PM
// Design Name: 
// Module Name: tb_adc_to_fm_demod_file
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

module tb_adc_to_fm_demod_file;

    reg clk;
    reg rst;
    reg sample_valid;
    reg [11:0] adc_code;

    wire signed [15:0] demod_out;
    wire output_valid;

    integer adc_file;
    integer expected_file;
    integer scan_result;

    integer adc_value;
    integer expected_value;
    integer output_error;

    integer inputs_sent;
    integer outputs_checked;
    integer errors;
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

    // Compare each FPGA output with the MATLAB reference.
    always @(negedge clk) begin
        if (output_valid) begin
            scan_result = $fscanf(
                expected_file,
                "%d",
                expected_value
            );

            if (scan_result != 1) begin
                $display("FAIL: no expected value available");
                errors = errors + 1;
            end else begin
                outputs_checked = outputs_checked + 1;

                output_error = $signed(demod_out)
                             - expected_value;

                // Circular 16-bit difference.
                if (output_error > 32767)
                    output_error = output_error - 65536;
                else if (output_error < -32768)
                    output_error = output_error + 65536;

                if (output_error < 0)
                    output_error = -output_error;

                // Allow for small CORDIC rounding differences.
                if (output_error > 16) begin
                    errors = errors + 1;

                    if (errors <= 20) begin
                        $display(
                            "FAIL sample %0d: expected=%d, got=%d, error=%0d",
                            outputs_checked,
                            expected_value,
                            demod_out,
                            output_error
                        );
                    end
                end

                if ((outputs_checked % 250) == 0) begin
                    $display(
                        "Checked %0d demodulated samples",
                        outputs_checked
                    );
                end
            end
        end
    end

    initial begin
        rst = 1'b1;
        sample_valid = 1'b0;
        adc_code = 12'd2048;

        inputs_sent = 0;
        outputs_checked = 0;
        errors = 0;
        timeout = 0;

        adc_file = $fopen(
            "D:/zynq-sdr-fm-bpsk/adc_input_u12.txt",
            "r"
        );

        expected_file = $fopen(
            "D:/zynq-sdr-fm-bpsk/demod_expected_s16.txt",
            "r"
        );

        if ((adc_file == 0) || (expected_file == 0)) begin
            $display("FAIL: could not open input files");
            $finish;
        end

        repeat (5) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        repeat (3) @(posedge clk);

        $display("Starting file-driven FM demodulator test...");

        while (!$feof(adc_file)) begin
            scan_result = $fscanf(adc_file, "%d", adc_value);

            if (scan_result == 1) begin
                send_adc(adc_value[11:0]);
                inputs_sent = inputs_sent + 1;
            end
        end

        // Allow the final samples to leave the CORDIC pipeline.
        while ((outputs_checked < 998) && (timeout < 500)) begin
            @(posedge clk);
            timeout = timeout + 1;
        end

        $display("ADC samples sent: %0d", inputs_sent);
        $display("Outputs checked: %0d", outputs_checked);

        if (outputs_checked != 998) begin
            $display("FAIL: expected 998 demodulated outputs");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("FILE-DRIVEN FM DEMODULATOR TEST PASSED");
        else
            $display(
                "FILE-DRIVEN TEST FAILED with %0d error(s)",
                errors
            );

        $fclose(adc_file);
        $fclose(expected_file);

        $finish;
    end

endmodule
