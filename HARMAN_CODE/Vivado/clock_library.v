`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/27 12:04:41
// Design Name: 
// Module Name: clock_library
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


module clock_usec(
   input clk, reset_p,
   output clk_usec);
   
   reg [7:0] cnt_sysclk; //�ڶ�� 8ns,���̽ý��� 10ns
   wire cp_usec;
   
   always @(posedge clk or posedge reset_p) begin
      if(reset_p) cnt_sysclk =0;
      else if (cnt_sysclk >=99) cnt_sysclk =0; 
      else cnt_sysclk =cnt_sysclk +1;
   end
   
   assign cp_usec = (cnt_sysclk < 50) ? 0 : 1; //�ڶ�� 63
   
   edge_detector_n ed (.clk(clk), .reset_p(reset_p), .cp(cp_usec), .n_edge(clk_usec));
   
endmodule

module clock_div_1000( //1000�� �ֱ� 
   input clk, reset_p,
   input clk_source,
   output clk_div_1000);
   
   reg [9:0]cnt_clk_source;
   reg cp_div_1000;
   
   always@(posedge clk or posedge reset_p) begin
      if(reset_p)  begin
         cnt_clk_source = 0;
         cp_div_1000 = 0;
      end
      else if (clk_source) begin
         if (cnt_clk_source >= 499) begin
            cnt_clk_source =0;
            cp_div_1000 = ~cp_div_1000;
         end
         else cnt_clk_source = cnt_clk_source +1; 
      end
   end
      
   //assign cp_msec = cnt_usec >=499?1:0;
   
   edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_div_1000), .n_edge(clk_div_1000));
endmodule

module clock_min( //1�п� �ѹ��� 
   input clk, reset_p,
   input clk_sec,
   output clk_min);
   
   reg [4:0]cnt_sec; //�뷮 ��� ���°���??/
   reg cp_min;
   
   always@(posedge clk or posedge reset_p) begin
      if(reset_p)  begin
         cnt_sec = 0;
         cp_min = 0;
      end
      else if (clk_sec) begin
         if (cnt_sec >= 29) begin
            cnt_sec =0;
            cp_min = ~cp_min;
         end
         else cnt_sec = cnt_sec +1; 
      end
   end
         
   edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_min), .n_edge(clk_min));
endmodule

module loadable_counter_dec_60(
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

module clock_div_10( //10�� �ֱ� 
   input clk, reset_p,
   input clk_source,
   output clk_div_10);
   
   integer cnt_clk_source;
   reg cp_div_10;
   
   always@(posedge clk or posedge reset_p) begin
      if(reset_p)  begin
         cnt_clk_source = 0;
         cp_div_10 = 0;
      end
      else if (clk_source) begin
         if (cnt_clk_source >= 4) begin
            cnt_clk_source =0;
            cp_div_10 = ~cp_div_10;
         end
         else cnt_clk_source = cnt_clk_source +1; 
      end
   end
      
   //assign cp_msec = cnt_usec >=499?1:0;
   
   edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_div_10), .n_edge(clk_div_10));
endmodule


module counter_dec_100 (
   input clk, reset_p,
   input clk_time,
   output reg [3:0] dec1, dec10);
   
   always @(posedge clk or posedge reset_p) begin
      if(reset_p) begin
         dec1=0;
         dec10=0;
      end
      else begin
         if(clk_time) begin
            if(dec1>= 9) begin
               dec1=0;
               if(dec10 >=5) dec10=0;
               else dec10 = dec10+1;
            end
            else dec1= dec1+1;
         end
      end
   end

endmodule


module counter_dec_60(
    input clk, reset_p, 
    input clk_time, 
    output reg [3:0] dec1, dec10);
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
        end 
        else begin 
            if(clk_time) begin 
                if(dec1 >= 9) begin 
                   dec1 = 0; //���� ���ڸ� �� �����ڸ����� 9�� �Ǹ� 0�̵ȴ�. 
                   if(dec10 >= 5) dec10 =0; //�����ڸ����� 5�������� 0�� �Ǿ� �� 
                   else dec10 = dec10 + 1; 
                 end 
              else dec1 = dec1 + 1; //�� Ŭ�� �ް� ���� ������ ������Ű�� dec1�� �� ���ڸ� �߿� 1�� �ڸ��� ������Ŵ 
             end
        end 
            
        end
endmodule


//�ٿ�ī��Ʈ ����, decreasement clk ���� 
//0 0���� 59�� �� �� Ŭ���� �ϳ� �ٿ�Ǵ� �� ���� 
module loadable_down_counter_dec_60(
    input clk, reset_p, 
    input clk_time, 
    input load_enable, 
    input [3:0] set_value1, set_value10, //��, ���̴ϱ� 0~9���� ��� -> 4bit �ʿ� 
    output reg [3:0] dec1, dec10,
    output reg dec_clk);
    
    always @(posedge clk, posedge reset_p) begin
     if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
     end 
    else begin //else�� ��Ŭ���� pos���� 
        if(load_enable) begin // 1�̸� �ܺο��� ���� ī���ͷ� ��� 
            dec1 = set_value1;  // dec1 : ���� �����ڸ��� ��µǴ� �� ( cur�� or setting�� �� ���� �� ����)
            dec10 = set_value10;  //set_value : ���� ���� ������ �� (���ø�� -���ð� or �ðԸ�� - �ð谪 �� ���� �� ����) 
        end
        else if(clk_time) begin  //load_enable�� 1�̾ƴϸ� ������ ���� 60�� ī���Ϳ� ���� 
                if(dec1 == 0) begin 
                   dec1 = 9; //���� ���ڸ� �� �����ڸ����� 9�� �Ǹ� 0�̵ȴ�. 
                     if(dec10 == 0) begin
                         dec10 =5; 
                         dec_clk =1; //���� ���� �ʿ� ���� 1cycle pulse 
                      end
                     else dec10 = dec10 - 1; 
                     end 
                     else dec1 = dec1 - 1; //�� Ŭ�� �ް� ���� ������ ������Ű�� dec1�� �� ���ڸ� �߿� 1�� �ڸ��� ������Ŵ 
       end
       else dec_clk=0; //posedge ���� �� �� Ŭ������ ��Ŭ�����ȸ� 1�� �� �� ���� 0 
        end 
            
     end
endmodule


