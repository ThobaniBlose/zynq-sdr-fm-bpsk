`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thobani Blose
// 
// Create Date: 06/29/2026 04:02:30 PM
// Design Name: 
// Module Name: tb_symbol_timer
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

module tb_symbol_timer;

    reg clk;
    reg rst;
    wire symbol_tick;

    integer tick_count;
    integer cycle_count;

    symbol_timer #(
        .CLKS_PER_SYMBOL(1000)
    ) uut (
        .clk(clk),
        .rst(rst),
        .symbol_tick(symbol_tick)
    );

    // 100 MHz clock: period = 10 ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        tick_count = 0;
        cycle_count = 0;

        #30;
        rst = 0;

        while (tick_count < 3) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;

            if (symbol_tick) begin
                tick_count = tick_count + 1;
                $display("symbol_tick %0d at cycle %0d, time %0t",
                         tick_count, cycle_count, $time);
            end
        end

        $display("PASS: symbol_tick pulses are 1000 clock cycles apart");

        #100;
        $finish;
    end

endmodule
