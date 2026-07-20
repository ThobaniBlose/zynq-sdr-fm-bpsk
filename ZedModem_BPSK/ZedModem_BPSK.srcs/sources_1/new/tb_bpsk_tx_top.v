`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2026 05:37:15 PM
// Design Name: 
// Module Name: tb_bpsk_tx_top
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

module tb_bpsk_tx_top;

    reg clk;
    reg rst;
    wire bpsk_out;
    wire bit_debug;

    // These are internal debug signals from inside bpsk_tx_top.
    // We use them only for simulation checking.
    wire carrier_dbg;
    wire symbol_tick_dbg;
    wire current_bit_dbg;

    integer tick_count;
    integer fail_count;

    bpsk_tx_top uut (
        .clk(clk),
        .rst(rst),
        .bpsk_out(bpsk_out),
        .bit_debug(bit_debug)
);
    assign carrier_dbg     = uut.carrier;
    assign symbol_tick_dbg = uut.symbol_tick;
    assign current_bit_dbg = uut.current_bit;

    // 100 MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Check BPSK mapping:
    // bit 1 -> bpsk_out = carrier
    // bit 0 -> bpsk_out = inverted carrier
    always @(*) begin
        if (!rst) begin
            if (current_bit_dbg == 1'b1 && bpsk_out !== carrier_dbg) begin
                $display("FAIL: bit=1 but bpsk_out != carrier at time %0t", $time);
                fail_count = fail_count + 1;
            end

            if (current_bit_dbg == 1'b0 && bpsk_out !== ~carrier_dbg) begin
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

        while (tick_count < 5) begin
            @(posedge clk);

            if (symbol_tick_dbg) begin
                #1;
                tick_count = tick_count + 1;

                $display("symbol %0d: current_bit=%b at time %0t",
                         tick_count, current_bit_dbg, $time);
            end
        end

        if (fail_count == 0) begin
            $display("PASS: bpsk_tx_top wrapper works correctly");
        end else begin
            $display("FAIL: bpsk_tx_top had %0d errors", fail_count);
        end

        #100;
        $finish;
    end

endmodule
