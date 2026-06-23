`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 05:15:00 PM
// Design Name: 
// Module Name: tb_fm_receiver_file
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

module tb_fm_receiver_file;

    reg clk;
    reg rst;
    reg sample_valid;
    reg [11:0] adc_code;

    wire signed [15:0] audio_out;
    wire audio_valid;

    integer input_file;
    integer output_file;
    integer scan_result;
    integer adc_value;
    integer input_count;
    integer output_count;

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
        input integer code;
        begin
            @(negedge clk);
            adc_code = code;
            sample_valid = 1'b1;

            @(negedge clk);
            sample_valid = 1'b0;

            // Accelerated simulation spacing.
            // The FIR still receives enough processing clocks.
            repeat (98) @(posedge clk);
        end
    endtask

    always @(negedge clk) begin
        if (audio_valid) begin
            $fwrite(output_file, "%0d\n", $signed(audio_out));
            output_count = output_count + 1;
        end
    end

    initial begin
        rst = 1'b1;
        sample_valid = 1'b0;
        adc_code = 12'd2048;
        input_count = 0;
        output_count = 0;

        input_file = $fopen(
            "D:/zynq-sdr-fm-bpsk/ZedModem_FM_Demod/adc_samples.txt",
            "r"
        );

        output_file = $fopen(
            "D:/zynq-sdr-fm-bpsk/ZedModem_FM_Demod/verilog_audio_samples.txt",
            "w"
        );

        if (input_file == 0) begin
            $display("ERROR: could not open adc_samples.txt");
            $finish;
        end

        if (output_file == 0) begin
            $display("ERROR: could not create output file");
            $finish;
        end

        repeat (5) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        repeat (3) @(posedge clk);

        $display("Starting file-driven FM receiver test...");

        scan_result = $fscanf(input_file, "%d", adc_value);

        while ((scan_result == 1) && (input_count < 4000)) begin
            send_adc_sample(adc_value);
            input_count = input_count + 1;
            scan_result = $fscanf(input_file, "%d", adc_value);
        end

        // Allow the final samples to leave the pipeline.
        repeat (500) @(posedge clk);

        $fclose(input_file);
        $fclose(output_file);

        $display("ADC samples read: %0d", input_count);
        $display("Audio samples written: %0d", output_count);

        if ((input_count == 4000) && (output_count == 999))
            $display("FILE-DRIVEN RECEIVER TEST PASSED");
        else
            $display("FILE-DRIVEN RECEIVER TEST FAILED");

        $finish;
    end

endmodule
