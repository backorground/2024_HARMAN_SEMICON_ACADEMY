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

module down_counter_async( //�񵿱�
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
    input down_up, //1�϶� down�̹Ƿ� �տ� down�� ������.0�϶� up�̴�.
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
 
module up_down_bcd_counter(  // 10�� BCD ī���͸� ������ ī���ͷ� ǥ��
    input clk, reset_p,
    input down_up,  // 1�� ��, �����̰� 0�� ��, ����
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
   
   reg[31:0] clk_div; //clk����
   
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
 
 module ring_counter_16( //LED 16�� 0�� ���� 15������ ��ī���͸� �̿��ؼ� ������� ��ȯ�ϸ� ������ �ϱ�
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
 
 module ring_counter_led( //LED 16�� 0�� ���� 15������ ��ī���͸� �̿��ؼ� ������� ��ȯ�ϸ� ������ �ϱ�
    input clk, reset_p,
    output reg [15:0] count
    );
        
    wire  posedge_clk_24;     
    reg [31:0]clk_div =0; //�ٸ� always������ ���� ������ �����Ϸ����ϸ� �ȵȴ�. ��������..�ٸ� �ÿ������ =0�س����� ���� ���� �Ǿ� �־���� �ȶ��. 
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
      else begin //blcoking�տ� �ڵ� ����Ǵµ��� �����ڵ带 ���ϰ� ���°�  nonblocking ���ÿ� ���� ���ķ� ����
         ff_cur<=cp; //���� �׳� =�� ��ŷ�� <=�ϸ� ���ŷ always���ȿ��� �������� �������� ������
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
      else begin //blcoking�տ� �ڵ� ����Ǵµ��� �����ڵ带 ���ϰ� ���°�  nonblocking ���ÿ� ���� ���ķ� ����
         ff_cur<=cp; //���� �׳� =�� ��ŷ�� <=�ϸ� ���ŷ always���ȿ��� �������� �������� ������
         ff_old<= ff_cur;
      end
   end
   
   assign p_edge = ({ff_cur,ff_old} == 2'b10) ? 1 : 0;
   assign n_edge = ({ff_cur,ff_old} == 2'b01) ? 1 : 0;
endmodule

module shift_register_PISO(
   input clk,reset_p,
   input [3:0]d,
   input shift_load, //�տ� �ִ� �� 1, �ڿ��ִ°� 0�϶� Ȱ��ȭ
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

module register_Nbit_p #(parameter N=8)( //���� �Է�, ���� ���
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
   input clk,// memory�� reset�� ����. �ƴϸ� ���ٰ� Ű��
   input wr_en, rd_en,
   input [9:0]addr,
   inout [7:0] data //inout <<input, output �Ѵ� �����ϴ�. ������ ������� ���� ���� ����.
                    //������� ���� ���� �ݵ�� ���Ǵ����� ����� �����ش�.   
   );

   reg [7:0]mem[0:1023];//�տ��� ��Ʈ�� ����, �ڿ��� � ������ �迭 ����(=8��Ʈ �޸� 1024�� �����)
   
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
   
   assign q= rd_en? sipo_reg:4'bz;//������
   //primitive_gate
//   bufif1(q[0], sipo_reg[0], rd_en);
//   bufif1(q[1], sipo_reg[1], rd_en);
//   bufif1(q[2], sipo_reg[2], rd_en);
//   bufif1(q[3], sipo_reg[3], rd_en);//1���� Ȱ��ȭ �Ǵ� ������
   
   //������ ������ ����������, ��� �������� �ο��̺�,1���� Ȱ��ȭ �Ǵ� ����
endmodule //�ַ� ����Ҷ� �� �ø�������Ҷ� ����Ĩ �ݴ�� �۽��Ҷ� , �޸𸮴� �����Է� �������

module shift_register_SISO_n_2(
   input clk, reset_p,
   input d,
   output q);

   reg [3:0] siso_reg;

   always @(negedge clk or posedge reset_p)begin
      if(reset_p) siso_reg <= 0;
      else begin
         siso_reg[3]<= d; //nonblocking ������ ����ؾ��Ѵ�.
         siso_reg[2]<= siso_reg[3];
         siso_reg[1]<= siso_reg[2];
         siso_reg[0]<= siso_reg[1];
      end
   end

   assign q= siso_reg[0];

endmodule

