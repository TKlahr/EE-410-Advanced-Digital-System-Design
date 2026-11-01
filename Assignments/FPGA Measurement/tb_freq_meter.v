`timescale 1ns / 1ps

module tb_freq_meter;

    reg sys_clk = 0;
    reg sys_rst_n_btn = 1;
    reg clk_test = 0;
    wire clk_out;

    // 125 MHz system clock (8 ns period)
    always #4 sys_clk = ~sys_clk;

    // 5 MHz test clock (200 ns period)
    always #100 clk_test = ~clk_test;

    // Frequency meter under test
    freq_meter_calc uut (
        .sys_clk(sys_clk),
        .sys_rst_n_btn(sys_rst_n_btn),
        .clk_test(clk_test),
        .clk_out(clk_out)
    );

    initial begin
        // Press and release the reset button
        #100;
        sys_rst_n_btn = 0;

        // Allow time for the shortened measurement gate
        #10000;

        $display("Measured frequency = %d Hz", uut.freq);
        $finish;
    end

defparam uut.CNT_GATE_S_MAX = 240;
defparam uut.CNT_RISE_MAX = 40;

endmodule
