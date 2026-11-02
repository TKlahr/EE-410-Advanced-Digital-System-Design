
`timescale 1ns / 1ps

module PLL_Test (
    input  wire sys_clk,
    input  wire rst_n,
    output wire clk_out1,
    output wire clk_out2,
    output wire clk_out3,
    output wire clk_out4
);

    wire locked;

    // Clocking Wizard IP instance
    clk_wiz_0 clock_gen (
        .clk_in1  (sys_clk),
        .reset    (~rst_n),
        .locked   (locked),
        .clk_out1 (clk_out1),
        .clk_out2 (clk_out2),
        .clk_out3 (clk_out3),
        .clk_out4 (clk_out4)
    );

endmodule
