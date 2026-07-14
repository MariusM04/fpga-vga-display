## ============================================================
## Basys 3 VGA Project Constraints
## Top module ports:
## sys_clock, reset, Hsync, Vsync, vgaRed, vgaGreen, vgaBlue
## ============================================================


## ============================================================
## 100 MHz clock input
## Basys 3 clock pin: W5
## This port must match the top module input: sys_clock
## ============================================================

set_property PACKAGE_PIN W5 [get_ports sys_clock]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clock]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports sys_clock]


## ============================================================
## Reset button
## Reset is connected to button U18
## Top module port: reset
##
## In top.sv:
## assign resetn = ~reset;
##
## Button not pressed -> reset = 0 -> resetn = 1 -> normal operation
## Button pressed     -> reset = 1 -> resetn = 0 -> reset active
## ============================================================

set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]


## ============================================================
## Unused reset switch option
## These lines are kept only as reference.
## Do not enable them unless the top module has sw[0] again.
##
## SW0 pin: V17
## ============================================================

# set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]


## ============================================================
## VGA Red output
## 4-bit red channel
## ============================================================

set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]

set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]

set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]

set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]


## ============================================================
## VGA Green output
## 4-bit green channel
## ============================================================

set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]

set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]

set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]

set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]


## ============================================================
## VGA Blue output
## 4-bit blue channel
## ============================================================

set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]

set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]

set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]

set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]


## ============================================================
## VGA synchronization signals
## ============================================================

set_property PACKAGE_PIN P19 [get_ports Hsync]
set_property IOSTANDARD LVCMOS33 [get_ports Hsync]

set_property PACKAGE_PIN R19 [get_ports Vsync]
set_property IOSTANDARD LVCMOS33 [get_ports Vsync]


## ============================================================
## Configuration voltage
## Required for Basys 3
## ============================================================

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]