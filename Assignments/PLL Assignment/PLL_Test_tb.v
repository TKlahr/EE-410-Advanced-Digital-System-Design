`timescale 1ns / 1ps

module PLL_Test_tb;

    reg sys_clk = 0;
    reg rst_n = 0;

    wire clk_out1;
    wire clk_out2;
    wire clk_out3;
    wire clk_out4;

    // Instantiate the design under test
    PLL_Test uut (
        .sys_clk(sys_clk),
        .rst_n(rst_n),
        .clk_out1(clk_out1),
        .clk_out2(clk_out2),
        .clk_out3(clk_out3),
        .clk_out4(clk_out4)
    );

    // Generate 125 MHz input clock
    // 8 ns period = 125 MHz
    always #4 sys_clk = ~sys_clk;

    initial begin
        // Hold PLL in reset initially
        rst_n = 0;

        // Release reset after 100 ns
        #100;
        rst_n = 1;

        // Allow time for PLL to lock
        #20000;

        $finish;
    end

endmodule
