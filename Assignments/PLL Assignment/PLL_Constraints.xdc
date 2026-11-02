## 125 MHz onboard system clock
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports {sys_clk}]

## Reset switch
set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS33 } [get_ports {rst_n}]

## PMOD JA clock outputs
set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports {clk_out1}]
set_property -dict { PACKAGE_PIN Y17 IOSTANDARD LVCMOS33 } [get_ports {clk_out2}]
set_property -dict { PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 } [get_ports {clk_out3}]
set_property -dict { PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 } [get_ports {clk_out4}]
