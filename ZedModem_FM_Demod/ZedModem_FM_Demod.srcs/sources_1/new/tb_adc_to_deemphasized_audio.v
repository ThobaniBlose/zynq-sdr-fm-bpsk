`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 03:36:53 PM
// Design Name: 
// Module Name: tb_adc_to_deemphasized_audio
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

module tb_adc_to_deemphasized_audio;

    reg clk;
    reg rst;
    reg sample_valid;
    reg [11:0] adc_code;

    wire signed [15:0] audio_out;
    wire output_valid;

    integer errors;
    integer outputs_received;
    integer expected_audio;
    integer timeout;

    adc_to_deemphasized_audio dut (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .adc_code(adc_code),
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

            case (outputs_received)
                1: expected_audio = -1559;
                2: expected_audio = -2970;
                3: expected_audio = -4247;
                4: expected_audio = -5402;
                5: expected_audio = -6447;
                6: expected_audio = -7393;
                7: expected_audio = -8249;
                8: expected_audio = -9024;
                default: expected_audio = 0;
            endcase

            if ($signed(audio_out) !== expected_audio) begin
                $display(
                    "FAIL sample %0d: expected=%d, got=%d",
                    outputs_received,
                    expected_audio,
                    audio_out
                );
                errors = errors + 1;
            end else begin
                $display(
                    "PASS sample %0d: audio=%d",
                    outputs_received,
                    audio_out
                );
            end
        end
    end

    initial begin
        errors = 0;
        outputs_received = 0;
        expected_audio = 0;
        timeout = 0;

        rst = 1'b1;
        sample_valid = 1'b0;
        adc_code = 12'd2048;

        repeat (5) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        repeat (3) @(posedge clk);

        $display(
            "Starting ADC-to-deemphasized-audio test..."
        );

        // Constant centred value of +1000.
        repeat (10) begin
            send_adc(12'd3048);
        end

        while ((outputs_received < 8) && (timeout < 100)) begin
            @(posedge clk);
            timeout = timeout + 1;
        end

        if (outputs_received != 8) begin
            $display(
                "FAIL: expected 8 outputs, received %0d",
                outputs_received
            );
            errors = errors + 1;
        end

        if (errors == 0)
            $display(
                "ADC-TO-DEEMPHASIZED-AUDIO TEST PASSED"
            );
        else
            $display(
                "TEST FAILED with %0d error(s)",
                errors
            );

        $finish;
    end

endmodule