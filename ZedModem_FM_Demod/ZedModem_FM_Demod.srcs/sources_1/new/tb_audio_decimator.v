`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 04:49:24 PM
// Design Name: 
// Module Name: tb_audio_decimator
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

module tb_audio_decimator;

    reg clk;
    reg rst;
    reg input_valid;
    reg signed [15:0] audio_in;

    wire signed [15:0] audio_out;
    wire output_valid;

    integer errors;
    integer outputs_received;
    integer expected_output;

    audio_decimator #(
        .DECIMATION_FACTOR(4)
    ) dut (
        .clk(clk),
        .rst(rst),
        .input_valid(input_valid),
        .audio_in(audio_in),
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

    task send_sample;
        input signed [15:0] sample;
        begin
            @(negedge clk);
            audio_in = sample;
            input_valid = 1'b1;

            @(negedge clk);
            input_valid = 1'b0;

            // Add a gap to confirm that only valid samples count.
            @(negedge clk);
        end
    endtask

    always @(negedge clk) begin
        if (output_valid) begin
            outputs_received = outputs_received + 1;

            case (outputs_received)
                1: expected_output = 40;
                2: expected_output = 80;
                3: expected_output = 120;
                default: expected_output = 0;
            endcase

            if ($signed(audio_out) !== expected_output) begin
                $display(
                    "FAIL output %0d: expected=%d, got=%d",
                    outputs_received,
                    expected_output,
                    audio_out
                );
                errors = errors + 1;
            end else begin
                $display(
                    "PASS output %0d: audio=%d",
                    outputs_received,
                    audio_out
                );
            end
        end
    end

    initial begin
        errors = 0;
        outputs_received = 0;
        expected_output = 0;

        rst = 1'b1;
        input_valid = 1'b0;
        audio_in = 16'sd0;

        repeat (5) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        repeat (3) @(posedge clk);

        $display("Starting audio decimator test...");

        send_sample(16'sd10);
        send_sample(16'sd20);
        send_sample(16'sd30);
        send_sample(16'sd40);

        send_sample(16'sd50);
        send_sample(16'sd60);
        send_sample(16'sd70);
        send_sample(16'sd80);

        send_sample(16'sd90);
        send_sample(16'sd100);
        send_sample(16'sd110);
        send_sample(16'sd120);

        repeat (3) @(posedge clk);

        if (outputs_received != 3) begin
            $display(
                "FAIL: expected 3 outputs, received %0d",
                outputs_received
            );
            errors = errors + 1;
        end

        if (errors == 0)
            $display("AUDIO DECIMATOR TEST PASSED");
        else
            $display("TEST FAILED with %0d error(s)", errors);

        $finish;
    end

endmodule
