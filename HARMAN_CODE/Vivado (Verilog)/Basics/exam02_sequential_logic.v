`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/27 12:06:38
// Design Name: 
// Module Name: exam02_sequential_logic
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


module D_flip_flop(
   input d,
   input clk,
   input reset_p,
   output reg q 
   );

   always @(negedge clk or posedge reset_p) begin
      if(reset_p) begin q = 0; end
      else begin q = d; end
   end

endmodule

module T_flip_flop_n(
   input clk, reset_p,
   input t,
   output reg q
   );

   always @(negedge clk or posedge reset_p) begin
      if (reset_p) begin q=0; end
      else begin 
         if(t) q=~q;
         else q=q;
      end
   end
endmodule

module T_flip_flop_p(
   input clk, reset_p,
   input t,
   output reg q
   );

   always @(posedge clk or posedge reset_p) begin
      if (reset_p) begin q=0; end
      else begin 
         if(t) q=~q;
         else q=q;
      end
   end
endmodule

module down_counter_async( //비동기
   input clk, reset_p,
   output [3:0] count
   ); 
   
   T_flip_flop_p T0 (.clk(clk), .reset_p(reset_p), .t(1), .q(count[0]));
   T_flip_flop_p T1 (.clk(count[0]), .reset_p(reset_p), .t(1), .q(count[1]));
   T_flip_flop_p T2 (.clk(count[1]), .reset_p(reset_p), .t(1), .q(count[2]));
   T_flip_flop_p T3 (.clk(count[3]), .reset_p(reset_p), .t(1), .q(count[3]));
endmodule
   
module up_conter_p(
   input clk,reset_p,
   output reg [15:0] count
   );

   always @(posedge clk, posedge reset_p) begin
      if(reset_p) count=0;
      else count = count +1;
   end
endmodule   
 

module down_conter_p(
   input clk,reset_p, enable,
   output reg [3:0] count
   );

   always @(posedge clk, posedge reset_p) begin
      if(reset_p) count=0;
      else begin 
         if(enable) count = count -1;
         else count = count;
      end
   end
endmodule

module down_conter_Nbit_p #(parameter N = 8) (
   input clk,reset_p, enable,
   output reg [N-1:0] count
   );

   always @(posedge clk, posedge reset_p) begin
      if(reset_p) count=0;
      else begin 
         if(enable) count = count -1;
         else count = count;
      end
   end
endmodule

module bcd_up_conter_p(
   input clk,reset_p,
   output reg [3:0] count
   );

   always @(posedge clk, posedge reset_p) begin
      if(reset_p) count=0;
      else begin
         count = count +1;
         if(count ==10) count =0;
      end
    end
 endmodule
 
 module up_down_counter(
    input clk, reset_p,
    input down_up, //1일때 down이므로 앞에 down을 적었다.0일때 up이다.
    output reg [3:0]count
    );
    
    always @(posedge clk or posedge reset_p)begin
       if(reset_p) count=0;
       else begin
          if(down_up) count= count-1;
          else count =count +1;
       end
    end
    
 endmodule
 
module up_down_bcd_counter(  // 10진 BCD 카운터를 상하향 카운터로 표현
    input clk, reset_p,
    input down_up,  // 1일 때, 감소이고 0일 때, 증가
    output reg [15:0] count
    );
    
    always @(posedge clk or posedge reset_p)begin
        if (reset_p) count = 0;
        else begin
            if ((down_up ==1) && (count ==0)) count = 9;
            else if ((down_up == 1) && (count !=0)) count = count-1;
            else if ((count == 0) &&(count == 9)) count =0;
            else if ((down_up ==0 ) && (count !=9))count = count + 1;
        end
    end
endmodule

module ring_counter(
    input clk, reset_p,
    output reg [3:0] q);

    always @(posedge clk or posedge reset_p)begin
        if(reset_p) q = 4'b0001;
        else begin
            if(q == 4'b0001) q = 4'b1000;
            else if(q == 4'b1000) q = 4'b0100;
            else if(q == 4'b0100) q = 4'b0010;
            else q = 4'b0001;
            
//            case(q)
//                4'b0001: q = 4'b1000;
//                4'b1000: q = 4'b0100;
//                4'b0100: q = 4'b0010;
//                4'b0010: q = 4'b0001;
//                default: q = 4'b0001;
//            endcase
        end
    end

endmodule
 
module ring_counter_fnd(
   input clk, reset_p,
   output reg [3:0] com
   );
   
   reg[31:0] clk_div; //clk분주
   
   always @(posedge clk) clk_div = clk_div + 1;
   wire clk_div_16;
   edge_detector_n ed( .clk(clk), .reset_p(reset), .cp(clk_div[16]), .p_edge(clk_div_16));
   
      
   always @(posedge clk or posedge reset_p) begin
      if(reset_p) com = 4'b1110;
      else if(clk_div_16)begin      
         case(com)
            4'b1110: com= 4'b1101; 
            4'b1101: com= 4'b1011; 
            4'b1011: com= 4'b0111; 
            4'b0111: com= 4'b1110;
            default  com= 4'b1110;
          endcase
       end
    end
 endmodule
 
 module ring_counter_16( //LED 16개 0번 부터 15번까지 링카운터를 이용해서 순서대로 순환하며 켜지게 하기
    input clk, reset_p,
    output reg [15:0] com
    );
    
    reg [31:0]clk_div =0;
    always @(posedge clk) clk_div= clk_div+1;
    
    always @(posedge clk_div[10] or posedge reset_p) begin
       if(reset_p) com = 16'b0000_0000_0000_0000;
       else begin
          case(com)
              
              16'b0000_0000_0000_0001: com = 16'b0000_0000_0000_0010;
              16'b0000_0000_0000_0010: com = 16'b0000_0000_0000_0100;
              16'b0000_0000_0000_0100: com = 16'b0000_0000_0000_1000;
              
              16'b0000_0000_0000_1000: com = 16'b0000_0000_0001_0000;
              16'b0000_0000_0001_0000: com = 16'b0000_0000_0010_0000;
              16'b0000_0000_0010_0000: com = 16'b0000_0000_0100_0000;
              16'b0000_0000_0100_0000: com = 16'b0000_0000_1000_0000;
              
              16'b0000_0000_1000_0000: com = 16'b0000_0001_0000_0000;
              16'b0000_0001_0000_0000: com = 16'b0000_0010_0000_0000;
              16'b0000_0010_0000_0000: com = 16'b0000_0100_0000_0000;
              16'b0000_0100_0000_0000: com = 16'b0000_1000_0000_0000;
              
              16'b0000_1000_0000_0000: com = 16'b0001_0000_0000_0000;
              16'b0001_0000_0000_0000: com = 16'b0010_0000_0000_0000;
              16'b0010_0000_0000_0000: com = 16'b0100_0000_0000_0000;
              16'b0100_0000_0000_0000: com = 16'b1000_0000_0000_0000;
              16'b1000_0000_0000_0000: com = 16'b0000_0000_0000_0001;
              default com = 16'b0000_0000_0000_0000;
          endcase
       end
    end
 endmodule
 
 module ring_counter_led( //LED 16개 0번 부터 15번까지 링카운터를 이용해서 순서대로 순환하며 켜지게 하기
    input clk, reset_p,
    output reg [15:0] count
    );
        
    wire  posedge_clk_24;     
    reg [31:0]clk_div =0; //다른 always문에서 같은 변수를 조종하려고하면 안된다. 오류나고..다른 올웨이즈문에 =0해놨으면 접지 연결 되어 있어서값이 안뜬다. 
    always @(posedge clk) clk_div= clk_div+1;
    
    always @(posedge clk_div[22] or posedge reset_p) begin
       if(reset_p) count = 16'b0000_0000_0000_0001;
       else count = {count[14:0], count[15]}; end

    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(clk_div[20]), .p_edge(posedge_clk_div_24));
       
 endmodule
 
module edge_detector_n(
   input clk, reset_p, 
   input cp,
   output p_edge, n_edge);
   
   reg ff_cur, ff_old;
   
   always @(negedge clk or posedge reset_p) begin
      if(reset_p) begin
         ff_cur=0;
         ff_old=0;
      end
      else begin //blcoking앞에 코드 실행되는동안 뒤의코드를 못하게 막는것  nonblocking 동시에 동작 병렬로 동작
         ff_cur<=cp; //지금 그냥 =는 블럭킹문 <=하면 논블럭킹 always문안에서 병렬인지 직렬인지 생각하
         ff_old<= ff_cur;
      end
   end
   
   assign p_edge = ({ff_cur,ff_old} == 2'b10) ? 1 : 0;
   assign n_edge = ({ff_cur,ff_old} == 2'b01) ? 1 : 0;
endmodule

module edge_detector_p(
   input clk, reset_p, 
   input cp,
   output p_edge, n_edge);
   
   reg ff_cur, ff_old;
   
   always @(negedge clk or posedge reset_p) begin
      if(reset_p) begin
         ff_cur=0;
         ff_old=0;
      end
      else begin //blcoking앞에 코드 실행되는동안 뒤의코드를 못하게 막는것  nonblocking 동시에 동작 병렬로 동작
         ff_cur<=cp; //지금 그냥 =는 블럭킹문 <=하면 논블럭킹 always문안에서 병렬인지 직렬인지 생각하
         ff_old<= ff_cur;
      end
   end
   
   assign p_edge = ({ff_cur,ff_old} == 2'b10) ? 1 : 0;
   assign n_edge = ({ff_cur,ff_old} == 2'b01) ? 1 : 0;
endmodule

module shift_register_PISO(
   input clk,reset_p,
   input [3:0]d,
   input shift_load, //앞에 있는 건 1, 뒤에있는게 0일때 활성화
   output q);
   
   reg [3:0] piso_reg;
   
   always @(posedge clk or posedge reset_p)begin
      if(reset_p) piso_reg=0;
      else begin
         if (shift_load) piso_reg = {1'b0, piso_reg[3:1]};
         else piso_reg = d; 
      end
   end

   assign q= piso_reg[0];
endmodule

module register_Nbit_p #(parameter N=8)( //병렬 입력, 병렬 출력
   input clk, reset_p,
   input [N-1:0] d,
   input wr_en, rd_en,
   output [N-1:0] q
   );

   reg [N-1:0] register;
   always @(posedge clk or posedge reset_p)begin
      if(reset_p) register =0;
      else if(wr_en) register =d;
   end
   assign q = rd_en? register: 'bz ;
endmodule

module sram_8bit_1024(
   input clk,// memory는 reset이 없다. 아니면 껐다가 키기
   input wr_en, rd_en,
   input [9:0]addr,
   inout [7:0] data //inout <<input, output 둘다 가능하다. 데이터 입출력을 같은 선을 쓴다.
                    //출력하지 않을 때는 반드시 임피던스로 출력을 끊어준다.   
   );

   reg [7:0]mem[0:1023];//앞에는 비트수 선언, 뒤에는 몇개 만들지 배열 선언(=8비트 메모리 1024개 만들기)
   
   always@(posedge clk) begin
      if(wr_en) mem[addr]<= data;
   end
   
   assign data = rd_en ? mem[addr] : 'bz;
endmodule
module D_flip_flop_n(
    input d,
    input clk, 
    input reset_p,
    output reg q);
    
    always @(negedge clk or posedge reset_p) begin
        if(reset_p) begin q = 0; end
        else begin q = d; end
    end

endmodule

module D_flip_flop_p(
    input d,
    input clk, 
    input reset_p,
    output reg q);
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin q = 0; end
        else begin q = d; end
    end

endmodule


module up_counter_asyc(
    input clk, reset_p,
    output [3:0] count);

    T_flip_flop_n T0(.clk(clk), .reset_p(reset_p), .t(1), .q(count[0]));
    T_flip_flop_n T1(.clk(count[0]), .reset_p(reset_p), .t(1), .q(count[1]));
    T_flip_flop_n T2(.clk(count[1]), .reset_p(reset_p), .t(1), .q(count[2]));
    T_flip_flop_n T3(.clk(count[2]), .reset_p(reset_p), .t(1), .q(count[3]));

endmodule

module down_counter_asyc(
    input clk, reset_p,
    output [3:0] count);

    T_flip_flop_p T0(.clk(clk), .reset_p(reset_p), .t(1), .q(count[0]));
    T_flip_flop_p T1(.clk(count[0]), .reset_p(reset_p), .t(1), .q(count[1]));
    T_flip_flop_p T2(.clk(count[1]), .reset_p(reset_p), .t(1), .q(count[2]));
    T_flip_flop_p T3(.clk(count[2]), .reset_p(reset_p), .t(1), .q(count[3]));

endmodule


module up_counter_p(
    input clk, reset_p, enable,
    output reg [3:0] count);

    always @(posedge clk, posedge reset_p)begin
        if(reset_p) count = 0;
        else begin
            if (enable) count = count + 1;
            else count = count;
        end
    end

endmodule

module down_counter_p(
    input clk, reset_p, enable,
    output reg [3:0] count);

    always @(posedge clk, posedge reset_p)begin
        if(reset_p) count = 0;
        else begin
            if (enable) count = count - 1;
            else count = count;
        end
    end

endmodule

module down_counter_Nbit_p #(parameter N = 8)(
    input clk, reset_p, enable,
    output reg [N-1:0] count);

    always @(posedge clk, posedge reset_p)begin
        if(reset_p) count = 0;
        else begin
            if (enable) count = count - 1;
            else count = count;
        end
    end

endmodule

module bcd_up_counter_p(
    input clk, reset_p,
    output reg [3:0] count);

    always @(posedge clk, posedge reset_p)begin
        if(reset_p) count = 0;
        else begin
            count = count + 1;
            if(count >= 10) count = 0;
        end
    end

endmodule

  


module shift_register_SISO_n(
    input clk, reset_p,
    input d,
    output q);
    
    reg [3:0] siso_reg;

    always @(negedge clk or posedge reset_p)begin
        if(reset_p) siso_reg <= 0;
        else begin
            siso_reg[3] <= d;
            siso_reg[2] <= siso_reg[3];
            siso_reg[1] <= siso_reg[2];
            siso_reg[0] <= siso_reg[1];
        end
    end
    assign q = siso_reg[0];
endmodule 

module shift_register_SIPO_n(
    input clk, reset_p,
    input d,
    input rd_en,
    output [3:0] q);

    reg [3:0] sipo_reg;
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)begin
            sipo_reg = 0;
        end
        else begin
            sipo_reg = {d, sipo_reg[3:1]};
        end
    end
    
    assign q = rd_en ? sipo_reg : 4'bz;
//    bufif1 (q[0], sipo_reg[0], rd_en);
//    bufif1 (q[1], sipo_reg[1], rd_en);
//    bufif1 (q[2], sipo_reg[2], rd_en);
//    bufif1 (q[3], sipo_reg[3], rd_en);
endmodule


module shift_register_SIPO_n_2(
   input clk, reset_p,
   input d,
   input rd_en,
   output [3:0] q);
   
   reg [3:0] sipo_reg;
   
   always@(negedge clk or posedge reset_p ) begin
      if(reset_p) 
         begin sipo_reg =0; end
      else begin
         sipo_reg ={d, sipo_reg[3:1]};
      end   
   end
   
   assign q= rd_en? sipo_reg:4'bz;//삼상버퍼
   //primitive_gate
//   bufif1(q[0], sipo_reg[0], rd_en);
//   bufif1(q[1], sipo_reg[1], rd_en);
//   bufif1(q[2], sipo_reg[2], rd_en);
//   bufif1(q[3], sipo_reg[3], rd_en);//1에서 활성화 되는 삼상버퍼
   
   //삼상버퍼 순서가 정해져있음, 출력 레지스터 인에이블,1에서 활성화 되는 ㅂ퍼
endmodule //주로 통신할때 씀 시리얼통신할때 수신칩 반대는 송신할때 , 메모리는 병렬입력 병렬출력

module shift_register_SISO_n_2(
   input clk, reset_p,
   input d,
   output q);

   reg [3:0] siso_reg;

   always @(negedge clk or posedge reset_p)begin
      if(reset_p) siso_reg <= 0;
      else begin
         siso_reg[3]<= d; //nonblocking 문으로 사용해야한다.
         siso_reg[2]<= siso_reg[3];
         siso_reg[1]<= siso_reg[2];
         siso_reg[0]<= siso_reg[1];
      end
   end

   assign q= siso_reg[0];

endmodule

