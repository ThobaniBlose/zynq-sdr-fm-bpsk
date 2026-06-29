`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2026 04:35:46 PM
// Design Name: 
// Module Name: tb_audio_lpf_fir
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

module tb_audio_lpf_fir;

    reg clk;
    reg rst;
    reg input_valid;
    reg signed [15:0] audio_in;

    wire signed [15:0] audio_out;
    wire output_valid;

    integer errors;
    integer output_index;
    integer expected_audio;

    audio_lpf_fir dut (
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

    function signed [15:0] expected_coefficient;
        input integer index;
        integer address;
        begin
            // Use symmetry for coefficients 32 to 62.
            if (index <= 31)
                address = index;
            else
                address = 62 - index;

            case (address)
                 0: expected_coefficient =  16'sd16;
                 1: expected_coefficient =  16'sd0;
                 2: expected_coefficient = -16'sd19;
                 3: expected_coefficient = -16'sd36;
                 4: expected_coefficient = -16'sd43;
                 5: expected_coefficient = -16'sd33;
                 6: expected_coefficient =  16'sd0;
                 7: expected_coefficient =  16'sd49;
                 8: expected_coefficient =  16'sd96;
                 9: expected_coefficient =  16'sd117;
                10: expected_coefficient =  16'sd87;
                11: expected_coefficient =  16'sd0;
                12: expected_coefficient = -16'sd123;
                13: expected_coefficient = -16'sd234;
                14: expected_coefficient = -16'sd275;
                15: expected_coefficient = -16'sd198;
                16: expected_coefficient =  16'sd0;
                17: expected_coefficient =  16'sd267;
                18: expected_coefficient =  16'sd501;
                19: expected_coefficient =  16'sd579;
                20: expected_coefficient =  16'sd414;
                21: expected_coefficient =  16'sd0;
                22: expected_coefficient = -16'sd560;
                23: expected_coefficient = -16'sd1064;
                24: expected_coefficient = -16'sd1261;
                25: expected_coefficient = -16'sd939;
                26: expected_coefficient =  16'sd0;
                27: expected_coefficient =  16'sd1477;
                28: expected_coefficient =  16'sd3241;
                29: expected_coefficient =  16'sd4920;
                30: expected_coefficient =  16'sd6124;
                31: expected_coefficient =  16'sd6562;
                default: expected_coefficient = 16'sd0;
            endcase
        end
    endfunction

    task send_sample;
        input signed [15:0] sample;
        begin
            @(negedge clk);
            audio_in = sample;
            input_valid = 1'b1;

            @(negedge clk);
            input_valid = 1'b0;

            // Wait until the FIR finishes this sample.
            wait(output_valid == 1'b1);
            @(negedge clk);
        end
    endtask

    always @(negedge clk) begin
        if (output_valid) begin
            expected_audio =
                ($signed(expected_coefficient(output_index))
                 * 16'sd16384) >>> 15;

            if ($signed(audio_out) !== expected_audio) begin
                $display(
                    "FAIL index %0d: expected=%d, got=%d",
                    output_index,
                    expected_audio,
                    audio_out
                );
                errors = errors + 1;
            end else begin
                $display(
                    "PASS index %0d: output=%d",
                    output_index,
                    audio_out
                );
            end

            output_index = output_index + 1;
        end
    end

    initial begin
        errors = 0;
        output_index = 0;
        rst = 1'b1;
        input_valid = 1'b0;
        audio_in = 16'sd0;

        repeat (5) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        repeat (3) @(posedge clk);

        $display("Starting audio LPF impulse test...");

        // One impulse followed by 62 zeros.
        send_sample(16'sd16384);

        repeat (62)
            send_sample(16'sd0);

        @(posedge clk);

        if (output_index != 63) begin
            $display(
                "FAIL: expected 63 outputs, received %0d",
                output_index
            );
            errors = errors + 1;
        end

        if (errors == 0)
            $display("AUDIO LPF FIR TEST PASSED");
        else
            $display("TEST FAILED with %0d error(s)", errors);

        $finish;
    end

endmodule
