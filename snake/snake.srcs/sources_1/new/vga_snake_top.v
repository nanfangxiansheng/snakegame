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
	 input           sys_clk,				   //ϵͳʱ��
	 input           sys_rst_n,				//ϵͳ��λ�ź�
	 //��������
	 input           key_up,
	 input           key_down,
	 input           key_left,
	 input           key_right,
	 //ͨ����������ʵ�������Ѷ�ѡ���Ѷ������ٶ�������
	 input           switch1,
	 input           remote_in,
	 //vga�ӿ�
	 output          vga_hs,				   //��ͬ���ź�
	 output          vga_vs,				   //��ͬ���ź�
	 output  [11:0]  vga_rgb,					//��������ԭɫ����
	 //����ܽӿ�
	 output  [ 5:0]  seg_sel,        // �����λѡ������������Ϊ���λ
     output  [ 7:0]  seg_led,         // ����ܶ�ѡ 
     output          beep_en	//��ʱ����
	);

wire         vga_clk_w;                   //PLL��Ƶ�õ�25Mhzʱ��
wire         locked_w;                    //PLL����ȶ��ź�
wire         rst_n_w;                     //�ڲ���λ�ź�
wire [15:0]  pixel_data_w;                //���ص�����
wire [ 9:0]  pixel_xpos_w;                //���ص������
wire [ 9:0]  pixel_ypos_w;                //���ص�������    
 
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

//��PLL����ȶ�֮��ֹͣ��λ
assign rst_n_w = sys_rst_n && locked_w;
assign switch2=switch1;
vga_pll	u_vga_pll(                      //ʱ�ӷ�Ƶģ��
	.inclk0         (sys_clk),    
	.areset         (~sys_rst_n),
    
	.c0             (vga_clk_w),          //VGAʱ�� 25M
	.locked         (locked_w)
	); 

vga_driver u_vga_driver(//vga������ʾʵ��
    .vga_clk        (vga_clk_w),    
    .sys_rst_n      (rst_n_w),    

    .vga_hs         (vga_hs),       
    .vga_vs         (vga_vs),       
    .vga_rgb        (vga_rgb),      
    
    .pixel_data     (pixel_data_w), 
    .pixel_xpos     (pixel_xpos_w), 
    .pixel_ypos     (pixel_ypos_w)
    ); 
    
vga_display u_vga_display(//vga̰������Ϸʵ��
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


seg_led u_seg_led(//����ܿ������ʵ��
    .clk         (sys_clk),
	.rst_n       (sys_rst_n),
	
	.data            (score),
	.en              (en),
	.point           (point),
	.sign            (sign),
	
	.seg_led         (seg_led),
	.seg_sel         (seg_sel)
    );


key_debounce u_left(//��ť��Ӧ��ʵ��
    .sys_clk         (vga_clk_w),
	.sys_rst_n       (sys_rst_n),
	
	.key             (key_left),
	.key_value       (key_l),
	.key_flag        (kf_left)
);

key_debounce u_right(//�Ұ�ť��Ӧ��ʵ��
    .sys_clk         (vga_clk_w),
	.sys_rst_n       (sys_rst_n),
	
	.key             (key_right),
	.key_value       (key_r),
	.key_flag        (kf_right)
);	

key_debounce u_up(//�ϰ�ť��Ӧ��ʵ��
    .sys_clk         (vga_clk_w),
	.sys_rst_n       (sys_rst_n),
	
	.key             (key_up),
	.key_value       (key_u),
	.key_flag        (kf_up)
);

key_debounce u_down(//�°�ť��Ӧ��ʵ��
    .sys_clk         (vga_clk_w),
	.sys_rst_n       (sys_rst_n),
	
	.key             (key_down),
	.key_value       (key_d),
	.key_flag        (kf_down)
);

endmodule 
