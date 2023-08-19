set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports scl]
set_property IOSTANDARD LVCMOS33 [get_ports sda]
set_property IOSTANDARD LVCMOS33 [get_ports sysclk]
set_property PULLUP true [get_ports scl]
set_property PULLUP true [get_ports sda]
set_property PACKAGE_PIN G15 [get_ports rst_n]
set_property PACKAGE_PIN V12 [get_ports scl]
set_property PACKAGE_PIN W16 [get_ports sda]
set_property PACKAGE_PIN K17 [get_ports sysclk]


set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets sysclk_IBUF_BUFG]