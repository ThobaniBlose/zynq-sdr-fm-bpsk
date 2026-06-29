`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thobani Blose
// 
// Create Date: 06/29/2026 03:39:29 PM
// Design Name: 
// Module Name: tb_carrier_10mhz
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

module tb_carrier_10mhz;

    reg clk;
    reg rst;
    wire carrier_out;

    time t1;
    time t2;
    time measured_period;

    // Instantiate the module under test
    carrier_10mhz uut (
        .clk(clk),
        .rst(rst),
        .carrier_out(carrier_out)
    );

    // Generate 100 MHz clock
    // 100 MHz period = 10 ns
    // Toggle every 5 ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        rst = 1;

        // Hold reset for a short time
        #30;
        rst = 0;

        // Ignore the first carrier edge after reset
        @(posedge carrier_out);

        // Measure one full carrier period
        @(posedge carrier_out);
        t1 = $time;

        @(posedge carrier_out);
        t2 = $time;

        measured_period = t2 - t1;

        $display("Measured carrier period = %0d ns", measured_period);

        if (measured_period == 100) begin
            $display("PASS: carrier_out is 10 MHz");
        end else begin
            $display("FAIL: expected 100 ns period, got %0d ns", measured_period);
        end

        #200;
        $finish;
    end

endmodule