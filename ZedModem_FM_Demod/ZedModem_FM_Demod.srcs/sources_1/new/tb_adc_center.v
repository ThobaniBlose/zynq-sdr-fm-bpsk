`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 02:30:40 PM
// Design Name: 
// Module Name: tb_adc_center
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


`timescale 1ns / 1ps

module tb_adc_center;

    reg  [11:0] adc_code;
    wire signed [12:0] adc_signed;

    integer errors;

    adc_center dut (
        .adc_code(adc_code),
        .adc_signed(adc_signed)
    );

    task check_sample;
        input [11:0] test_adc_code;
        input signed [12:0] expected_signed;
        begin
            adc_code = test_adc_code;
            #10;

            if (adc_signed !== expected_signed) begin
                $display("FAIL: adc_code = %d, expected = %d, got = %d",
                         test_adc_code, expected_signed, adc_signed);
                errors = errors + 1;
            end else begin
                $display("PASS: adc_code = %d, adc_signed = %d",
                         test_adc_code, adc_signed);
            end
        end
    endtask

    initial begin
        errors = 0;

        $display("Starting adc_center self-checking test...");

        check_sample(12'd0,    -13'sd2048);
        check_sample(12'd2048,  13'sd0);
        check_sample(12'd4095,  13'sd2047);

        if (errors == 0) begin
            $display("adc_center TEST PASSED");
        end else begin
            $display("adc_center TEST FAILED with %0d error(s)", errors);
        end

        $finish;
    end

endmodule