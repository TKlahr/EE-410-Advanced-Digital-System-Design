# PYNQ-Z2 System Clock (125 MHz)
set_property PACKAGE_PIN H16 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]

# Clock period = 8 ns (125 MHz)
create_clock -period 8.000 -name sys_clk [get_ports sys_clk]

# Reset button BTN0
set_property PACKAGE_PIN D19 [get_ports sys_rst_n_btn]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n_btn]

# External test clock - Raspberry Pi header pin 38
set_property PACKAGE_PIN A20 [get_ports clk_test]
set_property IOSTANDARD LVCMOS33 [get_ports clk_test]

# External test clock - 20 MHz timing assumption
create_clock -period 50.000 -name clk_test [get_ports clk_test]

# Test clock output - Raspberry Pi header pin 37
set_property PACKAGE_PIN W9 [get_ports clk_out]
set_property IOSTANDARD LVCMOS33 [get_ports clk_out]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_out_OBUF]

set_clock_groups -asynchronous \
    -group [get_clocks {sys_clk clk_out1_clk_wiz_0}] \
    -group [get_clocks clk_test]
