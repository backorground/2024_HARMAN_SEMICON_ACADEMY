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
   
   reg [7:0] cnt_sysclk; //코라는 8ns,베이시스는 10ns
   wire cp_usec;
   
   always @(posedge clk or posedge reset_p) begin
      if(reset_p) cnt_sysclk =0;
      else if (cnt_sysclk >=99) cnt_sysclk =0; 
      else cnt_sysclk =cnt_sysclk +1;
   end
   
   assign cp_usec = (cnt_sysclk < 50) ? 0 : 1; //코라는 63
   
   edge_detector_n ed (.clk(clk), .reset_p(reset_p), .cp(cp_usec), .n_edge(clk_usec));
   
endmodule

module clock_div_1000( //1000분 주기 
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

module clock_min( //1분에 한번씩 
   input clk, reset_p,
   input clk_sec,
   output clk_min);
   
   reg [4:0]cnt_sec; //용량 어떻게 세는거지??/
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

module clock_div_10( //10분 주기 
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
                   dec1 = 0; //초의 두자리 중 일의자리에서 9가 되면 0이된다. 
                   if(dec10 >= 5) dec10 =0; //십의자리에서 5다음에는 0이 되야 함 
                   else dec10 = dec10 + 1; 
                 end 
              else dec1 = dec1 + 1; //초 클럭 받고 들어올 때마다 증가시키는 dec1은 초 두자리 중에 1의 자리를 증가시킴 
             end
        end 
            
        end
endmodule


//다운카운트 만듦, decreasement clk 만들 
//0 0에서 59가 될 때 클럭이 하나 다운되는 것 만듦 
module loadable_down_counter_dec_60(
    input clk, reset_p, 
    input clk_time, 
    input load_enable, 
    input [3:0] set_value1, set_value10, //초, 분이니까 0~9까지 출력 -> 4bit 필요 
    output reg [3:0] dec1, dec10,
    output reg dec_clk);
    
    always @(posedge clk, posedge reset_p) begin
     if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
     end 
    else begin //else문 매클럭의 pos엣지 
        if(load_enable) begin // 1이면 외부에서 쓰는 카운터로 덮어씀 
            dec1 = set_value1;  // dec1 : 현재 일의자리에 출력되는 값 ( cur값 or setting값 이 들어올 수 있음)
            dec10 = set_value10;  //set_value : 내가 현재 셋팅한 값 (셋팅모드 -셋팅값 or 시게모드 - 시계값 이 들어올 수 있음) 
        end
        else if(clk_time) begin  //load_enable이 1이아니면 이전에 쓰던 60진 카운터와 같음 
                if(dec1 == 0) begin 
                   dec1 = 9; //초의 두자리 중 일의자리에서 9가 되면 0이된다. 
                     if(dec10 == 0) begin
                         dec10 =5; 
                         dec_clk =1; //엣지 잡은 필요 없음 1cycle pulse 
                      end
                     else dec10 = dec10 - 1; 
                     end 
                     else dec1 = dec1 - 1; //초 클럭 받고 들어올 때마다 증가시키는 dec1은 초 두자리 중에 1의 자리를 증가시킴 
       end
       else dec_clk=0; //posedge 들어올 때 매 클럭마다 한클럭동안만 1이 됨 그 이후 0 
        end 
            
     end
endmodule


