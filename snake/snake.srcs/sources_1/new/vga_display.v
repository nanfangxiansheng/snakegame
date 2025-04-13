`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/29 23:39:19
// Design Name: 
// Module Name: vga_display
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
module vga_display(
    input                vga_clk,               //VGA����ʱ��
    input                sys_rst_n,             //��λ�ź�
	 //��������
	input                 key_up,
	input                 kf_up,
	input                 key_down,
	input                 kf_down,
	input                 key_left,
	input                 kf_left,
	input                 key_right,
	input                 kf_right,
	input                 switch1,//ʵ���Ѷȵ�ѡ��
	//��������
	input      [ 7:0]     con_flag,             //��������ź�
    //��������
    input      [ 9:0]     pixel_xpos,           //���ص������
    input      [ 9:0]     pixel_ypos,           //���ص�������
    //�����ź�����
	output     reg        en,                   //�����ʹ��
	output     reg [ 5:0] point,                //С����
	output     reg        sign,                 //��ֵ����
    output     reg [19:0] score,                //�÷�	
	//���������
	output     reg        beep_clk,             // ��������ʼ����ʱ  
    //���ص����	 
    output     reg [15:0] pixel_data            //���ص�����	
    );
//parameter define    
parameter  H_DISP      = 10'd640;                //�ֱ��ʡ�����
parameter  V_DISP      = 10'd480;                //�ֱ��ʡ�����
//snake_state
parameter  STATE_LEFT  = 3'b000;                 //��ͷ�����˶���״̬
parameter  STATE_RIGHT = 3'b001;                 //
parameter  STATE_DOWN  = 3'b010;                 //
parameter  STATE_UP    = 3'b011;                 //
parameter  STATE_DIE   = 3'b100;                 //
parameter  STATE_START = 3'b101;
//con_flag code 
parameter  TURN_LEFT   = 8'h44;
parameter  TURN_RIGHT  = 8'h43;
parameter  TURN_UP     = 8'h46;
parameter  TURN_DOWN   = 8'h15;

parameter  MAX_LEN     = 6;                       //�ߵ���󳤶�

localparam SIDE_W      = 10'd20;                  //�߿���
localparam BLOCK_W     = 10'd20;                  //������
localparam BLUE        = 16'b00000_000000_11111;  //�߿���ɫ ��ɫ
localparam WHITE       = 16'b11111_111111_11111;  //������ɫ ��ɫ
localparam BLACK       = 16'b00000_000000_00000;  //������ɫ ��ɫ

//reg define
reg [ 2:0] cur_state;
reg [ 2:0] next_state;

reg [ 9:0] block_x[MAX_LEN-1:0];                   //�����нڵ��x���꣬block_x[0]Ϊ��ͷx����
reg [ 9:0] block_y[MAX_LEN-1:0];                   //�����нڵ��y���꣬block_y[0]Ϊ��ͷy����
reg [ 9:0] food_x;                                 //ʳ���x����
reg [ 9:0] food_y;                                 //ʳ���y����
reg [ 9:0] temp_food_x;                            //��ʱʳ��x����
reg [ 9:0] temp_food_y;                            //��ʱʳ��y����

reg [32:0] div_cnt;                                //ʱ�ӷ�Ƶ������
reg [ 9:0] cur_len;                                //�ߵĵ�ǰ����

reg        hit_w;                                  //ײǽ�ź�
reg        hit_self;                               //ײ�Լ��ź�
reg        eated;                                  //�Ե�ʳ���ź�
reg        eated_f;
reg        eated_s;
reg        die;                                    //�����ź�
integer i;                                         //ѭ������ֵ
reg [32:0]divide ;
//wire define   
reg move_en;                                      //���ƶ�ʹ���źţ�Ƶ��Ϊ100hz
wire pos_eated;
//*****************************************************
//**                    main code
//*****************************************************

always @(posedge vga_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        move_en <= 1'b0;
    end
    else begin
        // ���� switch1 ѡ��ͬ�ļ���ֵ
        if (switch1==1)begin
        
            divide<=22'd800000000;       
            move_en <=  (div_cnt == divide - 1'b1) ? 1'b1 : 1'b0;
            end
        else begin
            divide<=22'd1000000000;
            move_en <= (div_cnt == divide - 1'b1) ? 1'b1 : 1'b0;
            end
    end
end
assign pos_eated = (~eated_s) & eated_f;
//ͨ����vga����ʱ�Ӽ�����ʵ��ʱ�ӷ�Ƶ
always @(posedge vga_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n)
        div_cnt <= 22'd0;
    else begin
        if(div_cnt <divide  - 1'b1) 
            div_cnt <= div_cnt + 1'b1;
        else
            div_cnt <= 22'd0;                     //������ms������
    end
end

//���ݰ������룬�ı��ƶ�����
//״̬��
always @ (posedge vga_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cur_state <= STATE_START;
    else
        cur_state <= next_state ;
end

always @(*) begin
    case(cur_state)
	      //next_state = STATE_RIGHT;
		    STATE_START : begin
			    if((key_right == 1'b0 ) || con_flag == TURN_RIGHT)                        //�����Ҽ���ˮƽ����
                    next_state = STATE_RIGHT ;               
                else if((key_left == 1'b0 ) || con_flag == TURN_LEFT)                    //���������ˮƽ����                                               
                    next_state = STATE_LEFT; 
			    else if((key_up == 1'b0 ) || con_flag == TURN_UP)                      //�����Ҽ���ˮƽ����
                    next_state = STATE_UP ;               
                else if((key_down == 1'b0 ) || con_flag == TURN_DOWN)                    //���������ˮƽ����                                               
                    next_state = STATE_DOWN;
			    else 
		            next_state = STATE_START;		
			end
			STATE_LEFT : begin
			    if(hit_w || hit_self)
				     next_state = STATE_DIE;
				else if(key_up == 1'b0 || con_flag == TURN_UP)         //����up�����������ϵ�״̬��ˮƽ����
                     next_state = STATE_UP ;               
                else if(key_down == 1'b0 || con_flag == TURN_DOWN)       //����down�����������µ�״̬��ˮƽ����                                               
                     next_state = STATE_DOWN;               
                else 
				     next_state = STATE_LEFT;
			end
		    STATE_RIGHT : begin
			    if(hit_w || hit_self)
				    next_state = STATE_DIE;
			    else if(key_up == 1'b0 || con_flag == TURN_UP)         //����up����ˮƽ����
                    next_state = STATE_UP ;               
                else if(key_down == 1'b0 || con_flag == TURN_DOWN)       //����down����ˮƽ����                                               
                    next_state = STATE_DOWN;               
                else 
				    next_state = STATE_RIGHT;
			end
		    STATE_DOWN : begin
			    if(hit_w || hit_self)
				    next_state = STATE_DIE;
				else if(key_right == 1'b0 || con_flag == TURN_RIGHT)      //�����Ҽ���ˮƽ����
                    next_state = STATE_RIGHT ;               
                else if(key_left == 1'b0 || con_flag == TURN_LEFT)       //���������ˮƽ����                                               
                    next_state = STATE_LEFT;               
                else 
				    next_state = STATE_DOWN;
				
		    end
	        STATE_UP : begin
			    if(hit_w || hit_self)
				    next_state = STATE_DIE;
				else if(key_right == 1'b0 || con_flag == TURN_RIGHT)      //�����Ҽ���ˮƽ����
                    next_state = STATE_RIGHT ;               
                else if(key_left == 1'b0 || con_flag == TURN_LEFT)       //���������ˮƽ����                                               
                    next_state = STATE_LEFT;               
                else 
				    next_state = STATE_UP;
	        end
			STATE_DIE : begin
			if(key_right == 1'b0 || con_flag == TURN_RIGHT)                        //�����Ҽ���ˮƽ����
                 next_state = STATE_START;            
            else if(key_left == 1'b0 || con_flag == TURN_LEFT)                    //���������ˮƽ����                                               
                 next_state = STATE_START;
			else if(key_up == 1'b0 || con_flag == TURN_UP)                      //�����Ҽ���ˮƽ����
                 next_state = STATE_START;              
            else if(key_down == 1'b0)                    //���������ˮƽ����                                               
                 next_state = STATE_START;
			else
	             next_state = STATE_DIE;		
			end
			
            default : begin
		        next_state = STATE_START;
            end		  
	 endcase 		
end 

//������ͷ״̬���ı����ݺ�����
always @(posedge vga_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)begin
	     block_x[0] <= 22'd100;                     //�߳�ʼλ�ú�����
         block_y[0] <= 22'd100;                     //�߿��ʼλ��������
		 die        <= 0;                           //�����ź�
	end
	else begin
	    if(move_en) begin
			case(cur_state)
				STATE_RIGHT : begin
				    die        <=  1'b0; 
					block_x[0] <= block_x[0] + 9'd20;
				end
				STATE_LEFT : begin
			        die        <=  1'b0; 	
					block_x[0] <= block_x[0] - 9'd20;	 			 
				end
				STATE_UP : begin
					die        <=  1'b0; 	
				    block_y[0] <= block_y[0] - 9'd20;		
				end
			    STATE_DOWN : begin
					 die        <=  1'b0;                       //���������ź�
					 block_y[0] <= block_y[0] + 9'd20;
				end
				STATE_DIE : begin
						 block_x[0] <= 22'd100;                     //�߳�ʼλ�ú�����
						 block_y[0] <= 22'd100;                     //�߿��ʼλ��������
						 die        <=  1'b1;                       //���������ź� 
				end
				default : begin
					block_x[0] <= block_x[0];  
					block_y[0] <= block_y[0];					
				end 				
			endcase
			  //���˶��ź�ʹ��ʱ�����θ���ÿһ���ڵ����꣬�ƶ��ı��ʾ����ظ���һ���ڵ�Ķ������ܵ���˵�����ظ���ͷ�Ķ���  
			for(i = 0;i < MAX_LEN - 1;i = i + 1) begin 
					  block_x[i+1] <= block_x[i];  
					  block_y[i+1] <= block_y[i];	
			end			  
		 end
	     else begin 
	         block_x[0] <= block_x[0];  
			 block_y[0] <= block_y[0];	
		 end  
	 end
end 

//��ӡ�ߣ�����ͬ��������Ʋ�ͬ����ɫ
always @(posedge vga_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) 
        pixel_data <= BLACK;
    else begin
        if((pixel_xpos < SIDE_W) || (pixel_xpos >= H_DISP - SIDE_W)
          || (pixel_ypos < SIDE_W) || (pixel_ypos >= V_DISP - SIDE_W))
            pixel_data <= BLUE;                      
		else if((pixel_xpos >= food_x) && (pixel_xpos < food_x + BLOCK_W)
			     && (pixel_ypos >= food_y) && (pixel_ypos < food_y + BLOCK_W))
		         pixel_data <= BLACK;                //����ʳ�﷽��Ϊ��ɫ
        else if(cur_len == 1) begin                    //����һ�ڵ���
		     if((pixel_xpos >= block_x[0]) && (pixel_xpos < block_x[0] + BLOCK_W)
			     && (pixel_ypos >= block_y[0]) && (pixel_ypos < block_y[0] + BLOCK_W))
			     pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		     else
                 pixel_data <= WHITE;                //���Ʊ���Ϊ��ɫ
        end
		else if(cur_len == 2) begin                    //�������ڵ���
		      if((pixel_xpos >= block_x[0]) && (pixel_xpos < block_x[0] + BLOCK_W)
			       && (pixel_ypos >= block_y[0]) && (pixel_ypos < block_y[0] + BLOCK_W))
			       pixel_data <= BLACK;              //���Ʒ���Ϊ��ɫ
		      else
		      if((pixel_xpos >= block_x[1]) && (pixel_xpos < block_x[1] + BLOCK_W)
			       && (pixel_ypos >= block_y[1]) && (pixel_ypos < block_y[1] + BLOCK_W))
			       pixel_data <= BLACK;              //���Ʒ���Ϊ��ɫ
		      else
				    pixel_data <= WHITE;             //���Ʊ���Ϊ��ɫ 
		end
		else if(cur_len == 3) begin                    //����������
		    if((pixel_xpos >= block_x[0]) && (pixel_xpos < block_x[0] + BLOCK_W)
			    && (pixel_ypos >= block_y[0]) && (pixel_ypos < block_y[0] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else
		    if((pixel_xpos >= block_x[1]) && (pixel_xpos < block_x[1] + BLOCK_W)
			    && (pixel_ypos >= block_y[1]) && (pixel_ypos < block_y[1] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else
		    if((pixel_xpos >= block_x[2]) && (pixel_xpos < block_x[2] + BLOCK_W)
			    && (pixel_ypos >= block_y[2]) && (pixel_ypos < block_y[2] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ 
			else
		        pixel_data <= WHITE;                //���Ʊ���Ϊ��ɫ 
	    end
        else if(cur_len == 4) begin	                                //�������ϵ�4����
		    if((pixel_xpos >= block_x[0]) && (pixel_xpos < block_x[0] + BLOCK_W)
			    && (pixel_ypos >= block_y[0]) && (pixel_ypos < block_y[0] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else
		    if((pixel_xpos >= block_x[1]) && (pixel_xpos < block_x[1] + BLOCK_W)
			    && (pixel_ypos >= block_y[1]) && (pixel_ypos < block_y[1] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else
		    if((pixel_xpos >= block_x[2]) && (pixel_xpos < block_x[2] + BLOCK_W)
			    && (pixel_ypos >= block_y[2]) && (pixel_ypos < block_y[2] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else 
		    if((pixel_xpos >= block_x[3]) && (pixel_xpos < block_x[3] + BLOCK_W)
			    && (pixel_ypos >= block_y[3]) && (pixel_ypos < block_y[3] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else
		        pixel_data <= WHITE;                //���Ʊ���Ϊ��ɫ 
	    end
	    else if(cur_len == 5) begin
		    if((pixel_xpos >= block_x[0]) && (pixel_xpos < block_x[0] + BLOCK_W)
			    && (pixel_ypos >= block_y[0]) && (pixel_ypos < block_y[0] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else
		    if((pixel_xpos >= block_x[1]) && (pixel_xpos < block_x[1] + BLOCK_W)
			    && (pixel_ypos >= block_y[1]) && (pixel_ypos < block_y[1] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else
		    if((pixel_xpos >= block_x[2]) && (pixel_xpos < block_x[2] + BLOCK_W)
			    && (pixel_ypos >= block_y[2]) && (pixel_ypos < block_y[2] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else 
		    if((pixel_xpos >= block_x[3]) && (pixel_xpos < block_x[3] + BLOCK_W)
			    && (pixel_ypos >= block_y[3]) && (pixel_ypos < block_y[3] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
			else
			if((pixel_xpos >= block_x[4]) && (pixel_xpos < block_x[4] + BLOCK_W)
			    && (pixel_ypos >= block_y[4]) && (pixel_ypos < block_y[4] + BLOCK_W))
				pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else
		        pixel_data <= WHITE;                //���Ʊ���Ϊ��ɫ 
	    end	
		else begin
		    if((pixel_xpos >= block_x[0]) && (pixel_xpos < block_x[0] + BLOCK_W)
			    && (pixel_ypos >= block_y[0]) && (pixel_ypos < block_y[0] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else
		    if((pixel_xpos >= block_x[1]) && (pixel_xpos < block_x[1] + BLOCK_W)
			    && (pixel_ypos >= block_y[1]) && (pixel_ypos < block_y[1] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else
		    if((pixel_xpos >= block_x[2]) && (pixel_xpos < block_x[2] + BLOCK_W)
			    && (pixel_ypos >= block_y[2]) && (pixel_ypos < block_y[2] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else 
		    if((pixel_xpos >= block_x[3]) && (pixel_xpos < block_x[3] + BLOCK_W)
			    && (pixel_ypos >= block_y[3]) && (pixel_ypos < block_y[3] + BLOCK_W))
			    pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
			else
			if((pixel_xpos >= block_x[4]) && (pixel_xpos < block_x[4] + BLOCK_W)
			    && (pixel_ypos >= block_y[4]) && (pixel_ypos < block_y[4] + BLOCK_W))
				pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
			else
			if((pixel_xpos >= block_x[5]) && (pixel_xpos < block_x[5] + BLOCK_W)
			    && (pixel_ypos >= block_y[5]) && (pixel_ypos < block_y[5] + BLOCK_W))
				pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
		    else
		        pixel_data <= WHITE;                //���Ʊ���Ϊ��ɫ 
		end
    end
end

//�ж����Ƿ�ײǽ
always @(posedge vga_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        hit_w <= 0;                                 //ײǽ�źų�ʼ��    
    end
    else begin
        if(block_x[0] < SIDE_W - 1'b1)              //ײ����߽�ʱ
            hit_w <= 1'b1;               
        else                                        //ײ���ұ߽�ʱ
        if(block_x[0] > H_DISP - SIDE_W - BLOCK_W)
            hit_w <= 1'b1;               
        else    
        if(block_y[0] < SIDE_W - 1'b1)             //ײ���ϱ߽�ʱ
            hit_w <= 1'b1;                
        else                                    
        if(block_y[0] > V_DISP - SIDE_W - BLOCK_W) //ײ���±߽�ʱ
            hit_w <= 1'b1;               
        else
            hit_w <= 1'b0;
    end
end

//�ж����Ƿ�ײ���Լ�
always @(posedge vga_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        hit_self <= 0;                            //ײ�Լ��źų�ʼ��    
    end
    else begin
        if(block_x[0]==block_x[1] && block_y[0] == block_y[1])
		    hit_self <= 1'b1;
		else
		if(block_x[0]==block_x[2] && block_y[0] == block_y[2])
		    hit_self <= 1'b1;
		else
		if(block_x[0]==block_x[3] && block_y[0] == block_y[3])
		    hit_self <= 1'b1;
		else
		    hit_self <= 0;	
    end
end

//�������ʳ������
//����ʳ��x����
always @(posedge vga_clk or negedge sys_rst_n) begin 
    if(!sys_rst_n) begin
	    food_x <= 200;
	end
	else begin
	    if(eated) begin
		    food_x <= temp_food_x;
		end
		else if(temp_food_x > 560)
		    temp_food_x <= 200;
		else if(temp_food_x < 200)
		    temp_food_x <= 580;
		else 
		    temp_food_x <= temp_food_x + 9'd20;
	end 
end 

//������ʳ��y����
always @(posedge vga_clk or negedge sys_rst_n) begin 
    if(!sys_rst_n) begin
		food_y <= 200;
	end
	else begin
	    if(eated) begin
			food_y <= temp_food_y;
		end
		else if(temp_food_y > 400)
		    temp_food_y <= 160;
		else if(temp_food_y < 160)
		    temp_food_y <= 400;
		else 
			temp_food_y <= temp_food_y + 9'd20;
	end 
end

//�������eated�ź���ʱ����
always @(posedge vga_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        eated_f <= 1'b0;
        eated_s <= 1'b0;
    end
    else begin
        eated_f <= eated;
        eated_s <= eated_f;
    end
end 

//�ж��Ƿ�Ե�ʳ��
always @(posedge vga_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
	    eated <= 0;
	end
    else 
    if(block_x[0]==food_x && block_y[0]==food_y) begin
		eated <= 1'b1;
	end 
	else
		eated <= 1'b0;		
end

//�Ե�ʳ��͵÷�
always @(posedge vga_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
	    score <= 0;
		en    <= 0;
		point <= 6'b000000;
		sign  <= 0;		
	end
    else begin
		en    <= 1;
		point <= 6'b000000;
		sign  <= 0;	
		if(pos_eated)
			score <= score + 9'd1;
		else
		if(die) begin
			score <= 1'b0;
		end
		else
		    score <= score;
	end
end

//�ߵĳ���
always @(posedge vga_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
	    cur_len  <= 1'b1;
		beep_clk <= 1'b0;
	end
	else begin
		if(pos_eated) begin
			cur_len  <= cur_len + 1'b1;
		    beep_clk <= 1'b1;
		end
		else
		if(die) begin
			cur_len  <= 1'b1;
			beep_clk <= 1'b1;
		end
		else
		    cur_len  <= cur_len;
			beep_clk <= 1'b0;
	end
end

endmodule 
