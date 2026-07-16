`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thobani Blose
// 
// Create Date: 06/29/2026 05:21:03 PM
// Design Name: 
// Module Name: tb_bpsk_tx_core
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

module tb_bpsk_tx_core;

    reg clk;
    reg rst;

    wire carrier;
    wire symbol_tick;
    wire current_bit;
    wire bpsk_out;

    integer tick_count;
    integer fail_count;

    // Full BPSK transmitter core
    bpsk_tx_core #(
        .CLKS_PER_SYMBOL(1000),
        .BIT_PATTERN(8'b10110010)
    ) uut (
        .clk(clk),
        .rst(rst),
        .carrier(carrier),
        .symbol_tick(symbol_tick),
        .current_bit(current_bit),
        .bpsk_out(bpsk_out)
    );

    // 100 MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Check BPSK mapping continuously:
    // bit 1 -> output = carrier
    // bit 0 -> output = inverted carrier
    always @(*) begin
        if (!rst) begin
            if (current_bit == 1'b1 && bpsk_out !== carrier) begin
                $display("FAIL: bit=1 but bpsk_out != carrier at time %0t", $time);
                fail_count = fail_count + 1;
            end

            if (current_bit == 1'b0 && bpsk_out !== ~carrier) begin
                $display("FAIL: bit=0 but bpsk_out != inverted carrier at time %0t", $time);
                fail_count = fail_count + 1;
            end
        end
    end

    initial begin
        rst = 1;
        tick_count = 0;
        fail_count = 0;

        #35;
        rst = 0;

        // Watch 9 symbol ticks: full 8-bit pattern plus repeat
        while (tick_count < 9) begin
            @(posedge clk);

            if (symbol_tick) begin
                #1; // wait for current_bit to update
                tick_count = tick_count + 1;

                $display("symbol %0d: current_bit=%b at time %0t",
                         tick_count, current_bit, $time);
            end
        end

        if (fail_count == 0) begin
            $display("PASS: BPSK transmitter core works correctly");
        end else begin
            $display("FAIL: BPSK transmitter core had %0d errors", fail_count);
        end

        #100;
        $finish;
    end

endmodule
