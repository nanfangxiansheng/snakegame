`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/29 23:42:56
// Design Name: 
// Module Name: beep
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


module beep(
    input      sys_clk,
	input      sys_rst_n,
	
    input      enb,                                    //����������ʱʹ��
    output reg beep_en                                 //������ʹ��
    );

reg [31:0] delay_cnt;

always @(posedge sys_clk or negedge sys_rst_n) begin 
    if (!sys_rst_n) begin 
        delay_cnt <= 32'd0;
    end
    else begin
        if(enb)                                        //һ������ʱʹ��
            delay_cnt <= 32'd100000000;                  //����ʱ����������װ�س�ʼֵ������ʱ��Ϊ1s��
        else  begin                                   //�ڰ���״̬�ȶ�ʱ���������ݼ�����ʼ1ms����ʱ
                 if(delay_cnt > 32'd0)
                     delay_cnt <= delay_cnt - 1'b1;
                 else
                     delay_cnt <= delay_cnt;
        end				 
    end   
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
    if (!sys_rst_n) begin 
        beep_en <= 1'b0;          
    end
    else begin
	    if(enb)
		    beep_en <= 1'b1;
		else
        if(delay_cnt == 32'd1) begin   //���������ݼ���1ʱ��˵��״̬ά����1s
            beep_en <= 1'b0;          
        end
        else begin
            beep_en <= beep_en; 
        end  
    end   
end

endmodule 

