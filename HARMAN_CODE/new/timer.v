`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/27 11:59:19
// Design Name: 
// Module Name: timer
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


module main_timer(
    input clk, reset_p,
    input [3:0] btn,
    output [3:0] com,
    output [7:0]seg_7,
    output led_on,
    output clk_start);
    
   clock_usec usec_clk(clk_start,reset_p,clk_usec); 
   clock_div_1000 msec_clk(clk_start, reset_p,clk_usec,clk_msec);
   clock_div_1000 sec_clk(clk_start, reset_p,clk_msec,clk_sec);
   clock_min min_clk(clk_start, reset_p,clk_sec, clk_min);
   
   wire [3:0] btn_pedge; 
   button_cntr btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]),.btn_ne(btn_pedge[0]));
   button_cntr btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]),.btn_ne(btn_pedge[1]));
   button_cntr btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]),.btn_ne(btn_pedge[2])); 
   button_cntr btn4(.clk(clk), .reset_p(reset_p),.btn(btn[0]),.btn_ne(btn_pedge[3])); 
   
   wire clk_start;
   assign clk_start = btn_pedge[0]? 1:0 ;
 
   upcounter_dec_60 sec_up (clk, reset_p,btn_pedge[1] , sec1, sec10);
   upcounter_dec_60 min_up (clk, reset_p, btn_pedge[2], min1, min10);
   
   downcounter_dec_60 sec_down(clk, reset_p, clk_time, dec1, dec10);
   downcounter_dec_60 min_down(clk, reset_p, clk_time, dec1, dec10);
   
   wire [3:0]value;
   assign value= {min10,min1,sec10,sec1};
   
   fnd_4digit_cntr fnd(.clk(clk),.reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
   
   timer_led(clk, reset_p, btn_pedge[3],value,led_on);
endmodule


module downcounter_dec_60(
      input clk, reset_p,
        input clk_time,
        output reg [3:0] dec1, dec10
);
        always @(posedge clk or posedge reset_p)begin
                if(reset_p)begin
                   dec1 = 0;
                   dec10 = 0;
                end
                else begin
                if(clk_time) begin
                   if(dec1 <=1)begin
                      dec1 = 9;
                   if(dec10 <= 0) dec10 = 5;
                   else dec10 = dec10 - 1;
                end
                else dec1 = dec1 - 1;
                end
                end
                end
endmodule

module upcounter_dec_60(
        input clk, reset_p,
        input clk_time,
        output reg [3:0] dec1, dec10
);
        always @(posedge clk or posedge reset_p)begin
                if(reset_p)begin
                   dec1 = 0;
                   dec10 = 0;
                end
                else begin
                if(clk_time) begin
                   if(dec1 >=9)begin
                      dec1 = 0;
                   if(dec10 >= 5) dec10 = 0;
                   else dec10 = dec10 + 1;
                end
                else dec1 = dec1 + 1;
                end
                end
                end
endmodule

module timer_led(
    input clk, reset_p,
    input btn,timer_zero,
    output reg led_on);
    
    always@(posedge clk or posedge reset_p) begin
        if(reset_p) begin led_on=0; end //����
        
        else if(timer_zero==0) begin //timer_zero�� 0�̵Ǽ� ����
        led_on=1;
        end
        
        else if (btn)
        led_on =0; //��ư�� ���� LED�� ����.
    end
    
endmodule

module loadable_downcounter_dec_60(
        input clk, reset_p,
        input clk_time,
        input load_enable,
        input [3:0] set_value1, set_value10,
        output reg [3:0] dec1, dec10
);
        always @(posedge clk or posedge reset_p)begin
                if(reset_p)begin
                        dec1 = 0;
                        dec10 = 0;
                end
                else begin
                        if(load_enable)begin
                                dec1 = set_value1;
                                dec10 = set_value10;
                        end
                        else if(clk_time) begin
                                if(dec1 >=9)begin
                                        dec1 = 0;
                                        if(dec10 >= 5)dec10 = 0;
                                        else dec10 = dec10 + 1;
                                end
                                else dec1 = dec1 + 1;
                        end
               end
        end
endmodule


module cook_timer ( //�������� ���ֽ�
    input clk, reset_p,
    input [3:0] btn,
    output [3:0] com,
    output [7:0] seg_7);
   
   wire btn_start, inc_sec, inc_min, alarm_off; 
   wire [3:0] set_sec1, set_sec10, set_min1, set_min10;
   wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10;
   wire load_enable, dec_clk, clk_start;
   wire load_enable;
   reg start_stop;
   wire [15:0]value, cur_time, set_time;
   
//   assign led[5] = start_stop;
//   assign led[4] = 
   
//   assign clk_start= start_stop? clk: 0;
   clock_usec usec_clk(clk_start,reset_p,clk_usec); //��������. ������ ������� ������� �������ָ� ��.������ �����̸� ���̾�
   clock_div_1000 msec_clk(clk_start, reset_p,clk_usec,clk_msec);
   clock_div_1000 sec_clk(clk_start, reset_p,clk_msec, clk_sec);
   
   button_cntr btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]),.btn_ne(btn_start));
   button_cntr btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]),.btn_ne(inc_sec)); //�� ����
   button_cntr btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]),.btn_ne(inc_min)); //�� ����
   button_cntr btn3(.clk(clk), .reset_p(reset_p),.btn(btn[3]),.btn_ne(alarm_off));
   
   counter_dec_60 set_sec(clk, reset_p, inc_sec, set_sec1, set_sec10);
   counter_dec_60 set_min(clk, reset_p, inc_min, set_min1, set_min10);
   
   
   loadable_down_counter_dec_60 cur_sec(clk, reset_p,clk_sec,load_enable,set_sec1, set_sec10, cur_sec1, cur_sec10 ,dec_clk);
   loadable_down_counter_dec_60 cur_min(clk, reset_p,dec_clk,load_enable,set_min1, set_min10, cur_min1, cur_min10 );
   
   //���� �������Ϳ� �ΰ������� �����ϸ� >>���̽�>>��Ʈ�� �ƴ� 0���� 1���� �� �� �������� ���� ���δٸ� �ÿ�������� ���� �������Ϳ� �����ϸ� ���̽� �����޼��� �ȳ��ϱ� �����ض�
    //multiple driver 0,1��Ʈ ���� ���̾.. ������
    
    always@(posedge clk or posedge reset_p) begin
        if(reset_p) start_stop = 0;
        else begin
            if(btn_start) start_stop= ~start_stop;
            else if(timeout_pedge) start_stop =0;
        end
    end
    //T_flip_flop_p tff_start(clk, reset_p,btn_start, start_stop);
    edge_detector_n ed(clk, reset_p, start_stop, load_enable);
   
   reg time_out;
   always @(posedge clk or posedge reset_p) begin
    if(reset_p) time_out=0;
    else begin
        if(start_stop && clk_msec && cur_time ==0) time_out =1;
        else if( start_stop ==0 && clk_msec ) time_out=0; 
    end
   end
   wire timeout_pedge;
   edge_detector_n ed_timeout(clk, reset_p, time_out, timeout_pedge);
   reg alarm;
   always @(posedge clk or posedge reset_p) begin
    if(reset_p) begin
        alarm =0;
    end
    else begin
        if (timeout_pedge)alarm =1;
        else if (alarm && alarm_off) alarm =0;
        end
    end
  
   
   wire [15:0]value, cur_time, set_time;
   
   assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
   assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
   assign value= start_stop? cur_time: set_time;
   
   fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
endmodule


module loadable_down_counter_dec_60(//�����Բ�
        input clk, reset_p,
        input clk_time,
        input load_enable,
        input [3:0] set_value1, set_value10,
        output reg [3:0] dec1, dec10,
        output reg dec_clk //����Ʈ
);
        always @(posedge clk or posedge reset_p)begin
                if(reset_p)begin
                        dec1 = 0;
                        dec10 = 0;
                        dec_clk=0;
                end
                else begin
                        if(load_enable)begin
                                dec1 = set_value1;
                                dec10 = set_value10;
                        end
                        else if(clk_time) begin //�������
                                if(dec1 ==0)begin
                                        dec1 = 9;
                                        if(dec10 == 5)begin 
                                           dec10 = 5;
                                           dec_clk= 1;//����Ʈ!!1�б������
                                        end
                                        else dec10 = dec10 - 1;
                                end
                                else dec1 = dec1 - 1;
                        end
                        else dec_clk=0; //������� �ٽ�...��Ŭ�� ���ȸ� 1�̴�.������Ŭ �޽�
               end
        end
endmodule
