`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thobani Blose
// 
// Create Date: 06/29/2026 05:00:07 PM
// Design Name: 
// Module Name: tb_bpsk_modulator
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

module tb_bpsk_modulator;

    reg carrier;
    reg current_bit;
    wire bpsk_out;

    integer fail_count;

    bpsk_modulator uut (
        .carrier(carrier),
        .current_bit(current_bit),
        .bpsk_out(bpsk_out)
    );

    task check_output;
        input expected;
    begin
        #1;
        if (bpsk_out !== expected) begin
            $display("FAIL: current_bit=%b carrier=%b expected=%b got=%b at time %0t",
                     current_bit, carrier, expected, bpsk_out, $time);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS: current_bit=%b carrier=%b bpsk_out=%b",
                     current_bit, carrier, bpsk_out);
        end
    end
    endtask

    initial begin
        fail_count = 0;

        // Case 1: bit = 1, output should equal carrier
        current_bit = 1;
        carrier = 0; check_output(0);
        carrier = 1; check_output(1);

        // Case 2: bit = 0, output should be inverted carrier
        current_bit = 0;
        carrier = 0; check_output(1);
        carrier = 1; check_output(0);

        if (fail_count == 0) begin
            $display("PASS: bpsk_modulator mapping is correct");
        end else begin
            $display("FAIL: bpsk_modulator had %0d errors", fail_count);
        end

        #20;
        $finish;
    end

endmodule
