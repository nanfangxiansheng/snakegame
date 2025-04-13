`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/29 23:43:38
// Design Name: 
// Module Name: key_debounce
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
module key_debounce(
    input            sys_clk,          //�ⲿ50Mʱ��
    input            sys_rst_n,        //�ⲿ��λ�źţ�����Ч
    
    input            key,              //�ⲿ��������
    output reg       key_flag,         //����������Ч�ź�
	output reg       key_value         //���������������  
    );

//reg define    
reg [31:0] delay_cnt;
reg        key_reg;
assign keyn=!key;
//*****************************************************
//**                    main code
//*****************************************************
always @(posedge sys_clk or negedge sys_rst_n) begin 
    if (!sys_rst_n) begin 
        key_reg   <= 1'b1;
        delay_cnt <= 32'd0;
    end
    else begin
        key_reg <= keyn;
        if(key_reg != keyn)             //һ����⵽����״̬�����仯(�а��������»��ͷ�)
            delay_cnt <= 32'd500000;   //����ʱ����������װ�س�ʼֵ������ʱ��Ϊ20ms��
        else if(key_reg == keyn) begin  //�ڰ���״̬�ȶ�ʱ���������ݼ�����ʼ20ms����ʱ
                 if(delay_cnt > 32'd0)
                     delay_cnt <= delay_cnt - 1'b1;
                 else
                     delay_cnt <= delay_cnt;
             end           
    end   
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
    if (!sys_rst_n) begin 
       // key_flag  <= 1'b0;
        key_value <= 1'b1;          
    end
    else begin
        if(delay_cnt == 32'd1) begin   //���������ݼ���1ʱ��˵�������ȶ�״̬ά����20ms
            key_flag  <= 1'b1;         //��ʱ�������̽���������һ��ʱ�����ڵı�־�ź�
            key_value <= keyn;          //���Ĵ��ʱ������ֵ
        end
        else begin
            key_flag  <= 1'b0;
            key_value <= key_value; 
        end  
    end   
end
    
endmodule 

