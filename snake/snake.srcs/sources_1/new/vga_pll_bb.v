`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/29 23:41:52
// Design Name: 
// Module Name: vga_pll_bb
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
`timescale 1ps / 1ps
//锁相环驱动将输入的100MHZ时钟变为25MHZ的VGA输入
module vga_pll (
    input       areset,
    input       inclk0,
    output      c0,
    output      locked
);

// Xilinx 时钟原语实例化
clk_wiz_0 vga_pll_inst
(
    .reset(areset),         // 异步复位，高有效
    .clk_in1(inclk0),       // 输入时钟 (100MHz)
    .clk_out1(c0),          // 输出时钟 (25MHz)
    .locked(locked)         // PLL锁定信号
);

endmodule