# README before act

## Idea and overall explain

This design is verified on EGO1 xilinx development board and VGA screen ,mainly worked on vivado 2021.

![snakegame/ego1.png at main · nanfangxiansheng/snakegame](https://github.com/nanfangxiansheng/snakegame/blob/main/ego1.png)



The main idea of this project can be described in the below  figure:

![snakegame/main describe.png at main · nanfangxiansheng/snakegame](https://github.com/nanfangxiansheng/snakegame/blob/main/main describe.png)

This version can finish jobs including snake 's  move ,eat,die and score display as well as keys control and difficulty set.

The control of screen based on VGA communication technology is showed below:

![snakegame/VGA.png at main · nanfangxiansheng/snakegame](https://github.com/nanfangxiansheng/snakegame/blob/main/VGA.png)

## Transplant help 

what 's more ,if you want to transplant this job to other development board,you are supposed to change the "drc" constraints file(mainly deal with the pins of board),and the PLL ip core.

```shell
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {sys_clk}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {sys_rst_n}]
# Button inputs
set_property -dict {PACKAGE_PIN V1 IOSTANDARD LVCMOS33} [get_ports {key_left}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {key_down}]
set_property -dict {PACKAGE_PIN R11 IOSTANDARD LVCMOS33} [get_ports {key_right}]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports {key_up}]
# Digital tube digit selection
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS33} [get_ports {seg_sel[5]}]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {seg_sel[4]}]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {seg_sel[3]}]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports {seg_sel[2]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {seg_sel[1]}]
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports {seg_sel[0]}]
# VGA row and column signals
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS33} [get_ports {vga_hs}]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports {vga_vs}]
# Blue
set_property -dict {PACKAGE_PIN E7 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[11]}]
set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[10]}]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[9]}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[8]}]
# Green
set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[7]}]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[6]}]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[5]}]
set_property -dict {PACKAGE_PIN B6 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[4]}]
# Red
set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[3]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[2]}]
set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[1]}]
set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS33} [get_ports {vga_rgb[0]}]
# Digital tube segment selection
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {seg_led[0]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {seg_led[1]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {seg_led[2]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {seg_led[3]}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {seg_led[4]}]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports {seg_led[5]}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {seg_led[6]}]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports {seg_led[7]}]
# Button for difficulty adjustment by selecting snake speed
set_property -dict {PACKAGE_PIN N4 IOSTANDARD LVCMOS33} [get_ports {switch1}]
```

 when you need to design a soft ip core of PLL to provide stable clock (20MHZ) to the VGA control terminal. You need to design like following:

![snakegame/PLL.png at main · nanfangxiansheng/snakegame](https://github.com/nanfangxiansheng/snakegame/blob/main/PLL.png)

clock in :always choose 100MHZ, clock out: should be 25MHZ.