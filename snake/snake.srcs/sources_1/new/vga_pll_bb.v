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
//���໷�����������100MHZʱ�ӱ�Ϊ25MHZ��VGA����
module vga_pll (
    input       areset,
    input       inclk0,
    output      c0,
    output      locked
);

// Xilinx ʱ��ԭ��ʵ����
clk_wiz_0 vga_pll_inst
(
    .reset(areset),         // �첽��λ������Ч
    .clk_in1(inclk0),       // ����ʱ�� (100MHz)
    .clk_out1(c0),          // ���ʱ�� (25MHz)
    .locked(locked)         // PLL�����ź�
);

endmodule