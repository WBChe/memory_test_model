#sys
create_clock -period 20.000 -name sysclk_i -add [get_ports sys_clk]
set_property PACKAGE_PIN V4 [get_ports sys_clk]
set_property IOSTANDARD SSTL135 [get_ports sys_clk]

set_property PACKAGE_PIN N12 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]

#gt
create_clock -period 8.0 -name GT_REFCLK1 [get_ports gt_refclk1_p]
set_property PACKAGE_PIN F10 [get_ports  gt_refclk1_p ]
#set_property PACKAGE_PIN E10 [get_ports  gt_refclk1_n ] 

#set_property LOC GTPE2_CHANNEL_X0Y0 [get_cells aurora_module_i/aurora_8b10b_0_i/inst/gt_wrapper_i/aurora_8b10b_0_multi_gt_i/gt0_aurora_8b10b_0_i/gtpe2_i]
set_property PACKAGE_PIN B8 [get_ports rxp]
set_property PACKAGE_PIN B4 [get_ports txp]


set_property PACKAGE_PIN A18 [get_ports sfpa_tx_dis]
set_property PACKAGE_PIN A20 [get_ports sfpb_tx_dis]


set_property IOSTANDARD LVCMOS33 [get_ports sfpa_tx_dis]
set_property IOSTANDARD LVCMOS33 [get_ports sfpb_tx_dis]