`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thobani Blose
// 
// Create Date: 06/29/2026 04:40:33 PM
// Design Name: 
// Module Name: tb_bpsk_bit_source
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

module tb_bpsk_bit_source;

    reg clk;
    reg rst;
    reg symbol_tick;
    wire current_bit;

    integer fail_count;

    bpsk_bit_source #(
        .BIT_PATTERN(8'b10110010)
    ) uut (
        .clk(clk),
        .rst(rst),
        .symbol_tick(symbol_tick),
        .current_bit(current_bit)
    );

    // 100 MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task send_tick;
    begin
        @(negedge clk);
        symbol_tick = 1;

        @(negedge clk);
        symbol_tick = 0;

        #1;
    end
    endtask

    task check_bit;
        input expected;
    begin
        if (current_bit !== expected) begin
            $display("FAIL: expected bit %b, got %b at time %0t",
                     expected, current_bit, $time);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS: current_bit = %b at time %0t",
                     current_bit, $time);
        end
    end
    endtask

    initial begin
        rst = 1;
        symbol_tick = 0;
        fail_count = 0;

        #32;
        rst = 0;
        #20;

        // Initial bit after reset
        check_bit(1);

        // Step through the rest of the pattern
        send_tick(); check_bit(0);
        send_tick(); check_bit(1);
        send_tick(); check_bit(1);
        send_tick(); check_bit(0);
        send_tick(); check_bit(0);
        send_tick(); check_bit(1);
        send_tick(); check_bit(0);

        // Check that it repeats
        send_tick(); check_bit(1);

        if (fail_count == 0) begin
            $display("PASS: bpsk_bit_source repeats the expected bit pattern");
        end else begin
            $display("FAIL: bpsk_bit_source had %0d errors", fail_count);
        end

        #100;
        $finish;
    end

endmodule
