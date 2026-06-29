`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 05:00:55 PM
// Design Name: 
// Module Name: tb_fm_receiver_audio
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

module tb_fm_receiver_audio;

    reg clk;
    reg rst;
    reg sample_valid;
    reg [11:0] adc_code;

    wire signed [15:0] audio_out;
    wire audio_valid;

    integer errors;
    integer filtered_count;
    integer audio_count;

    reg signed [15:0] expected_audio;
    reg expected_pending;

    fm_receiver_audio dut (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .adc_code(adc_code),
        .audio_out(audio_out),
        .audio_valid(audio_valid)
    );

    // 100 MHz clock
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    task send_adc_sample;
        input [11:0] code;
        begin
            @(negedge clk);
            adc_code = code;
            sample_valid = 1'b1;

            @(negedge clk);
            sample_valid = 1'b0;

            // 500 clocks per sample gives 200 kS/s.
            repeat (498) @(posedge clk);
        end
    endtask

    // Record every fourth FIR output.
    always @(negedge clk) begin
        if (dut.filtered_valid) begin
            filtered_count = filtered_count + 1;

            if ((filtered_count % 4) == 0) begin
                expected_audio = dut.filtered_audio;
                expected_pending = 1'b1;
            end
        end

        if (audio_valid) begin
            audio_count = audio_count + 1;

            if (!expected_pending) begin
                $display(
                    "FAIL: unexpected audio output %0d",
                    audio_out
                );
                errors = errors + 1;
            end else if ($signed(audio_out) !==
                         $signed(expected_audio)) begin
                $display(
                    "FAIL output %0d: expected=%d, got=%d",
                    audio_count,
                    expected_audio,
                    audio_out
                );
                errors = errors + 1;
            end else begin
                $display(
                    "PASS output %0d: audio=%d",
                    audio_count,
                    audio_out
                );
            end

            expected_pending = 1'b0;
        end
    end

    initial begin
        errors = 0;
        filtered_count = 0;
        audio_count = 0;
        expected_audio = 16'sd0;
        expected_pending = 1'b0;

        rst = 1'b1;
        sample_valid = 1'b0;
        adc_code = 12'd2048;

        repeat (5) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        repeat (3) @(posedge clk);

        $display("Starting complete FM receiver test...");

        // Twenty constant centred samples of +1000.
        repeat (20)
            send_adc_sample(12'd3048);

        // Allow the final sample to pass through every block.
        repeat (1000) @(posedge clk);

        if (filtered_count != 18) begin
            $display(
                "FAIL: expected 18 filtered samples, received %0d",
                filtered_count
            );
            errors = errors + 1;
        end

        if (audio_count != 4) begin
            $display(
                "FAIL: expected 4 audio samples, received %0d",
                audio_count
            );
            errors = errors + 1;
        end

        if (errors == 0)
            $display("COMPLETE FM RECEIVER TEST PASSED");
        else
            $display("TEST FAILED with %0d error(s)", errors);

        $finish;
    end

endmodule