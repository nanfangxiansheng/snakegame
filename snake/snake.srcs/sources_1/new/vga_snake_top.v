`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/29 23:38:15
// Design Name: 
// Module Name: vga_snake_top
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

module vga_snake_top(
	 input           sys_clk,				   //系统时钟
	 input           sys_rst_n,				//系统复位信号
	 //按键输入
	 input           key_up,
	 input           key_down,
	 input           key_left,
	 input           key_right,
	 //通过拨码输入实现两种难度选择，难度依靠速度来决定
	 input           switch1,
	 input           remote_in,
	 //vga接口
	 output          vga_hs,				   //行同步信号
	 output          vga_vs,				   //场同步信号
	 output  [11:0]  vga_rgb,					//红绿蓝三原色输入
	 //数码管接口
	 output  [ 5:0]  seg_sel,        // 数码管位选，最左侧数码管为最高位
     output  [ 7:0]  seg_led,         // 数码管段选 
     output          beep_en	//暂时不用
	);

wire         vga_clk_w;                   //PLL分频得到25Mhz时钟
wire         locked_w;                    //PLL输出稳定信号
wire         rst_n_w;                     //内部复位信号
wire [15:0]  pixel_data_w;                //像素点数据
wire [ 9:0]  pixel_xpos_w;                //像素点横坐标
wire [ 9:0]  pixel_ypos_w;                //像素点纵坐标    
 
wire        repeat_en;                   
wire        data_en;                     
wire [7:0]  data;                        

wire [19:0] score;
wire        en;
wire        sign;
wire [5:0]  point;

wire        key_l;
wire        key_r;
wire        key_u;
wire        key_d;

wire        ky_right;
wire        ky_left;
wire        ky_up;
wire        ky_down;
wire        switch2;
wire        beep_clk;
//*****************************************************
//**                    main code
//***************************************************** 

//待PLL输出稳定之后，停止复位
assign rst_n_w = sys_rst_n && locked_w;
assign switch2=switch1;
vga_pll	u_vga_pll(                      //时钟分频模块
	.inclk0         (sys_clk),    
	.areset         (~sys_rst_n),
    
	.c0             (vga_clk_w),          //VGA时钟 25M
	.locked         (locked_w)
	); 

vga_driver u_vga_driver(//vga数字显示实例
    .vga_clk        (vga_clk_w),    
    .sys_rst_n      (rst_n_w),    

    .vga_hs         (vga_hs),       
    .vga_vs         (vga_vs),       
    .vga_rgb        (vga_rgb),      
    
    .pixel_data     (pixel_data_w), 
    .pixel_xpos     (pixel_xpos_w), 
    .pixel_ypos     (pixel_ypos_w)
    ); 
    
vga_display u_vga_display(//vga贪吃蛇游戏实例
    .vga_clk        (vga_clk_w),
    .sys_rst_n      (rst_n_w),
	 
    .key_down       (key_d),
	.kf_down        (kf_down),
	.key_up         (key_u),
	.kf_up          (kf_up),
	.key_left       (key_l),
	.kf_left        (kf_left),
	.key_right      (key_r),
	.kf_right       (kf_right),
	.switch1        (switch2),
	.con_flag       (data),
	
	.score          (score),
	.point          (point),
	.en             (en),
	.sign           (sign),
	
	.beep_clk       (beep_clk),
	
    .pixel_xpos     (pixel_xpos_w),
    .pixel_ypos     (pixel_ypos_w),
    .pixel_data     (pixel_data_w)
    );


seg_led u_seg_led(//数码管控制相关实例
    .clk         (sys_clk),
	.rst_n       (sys_rst_n),
	
	.data            (score),
	.en              (en),
	.point           (point),
	.sign            (sign),
	
	.seg_led         (seg_led),
	.seg_sel         (seg_sel)
    );


key_debounce u_left(//左按钮对应的实例
    .sys_clk         (vga_clk_w),
	.sys_rst_n       (sys_rst_n),
	
	.key             (key_left),
	.key_value       (key_l),
	.key_flag        (kf_left)
);

key_debounce u_right(//右按钮对应的实例
    .sys_clk         (vga_clk_w),
	.sys_rst_n       (sys_rst_n),
	
	.key             (key_right),
	.key_value       (key_r),
	.key_flag        (kf_right)
);	

key_debounce u_up(//上按钮对应的实例
    .sys_clk         (vga_clk_w),
	.sys_rst_n       (sys_rst_n),
	
	.key             (key_up),
	.key_value       (key_u),
	.key_flag        (kf_up)
);

key_debounce u_down(//下按钮对应的实例
    .sys_clk         (vga_clk_w),
	.sys_rst_n       (sys_rst_n),
	
	.key             (key_down),
	.key_value       (key_d),
	.key_flag        (kf_down)
);

endmodule 
