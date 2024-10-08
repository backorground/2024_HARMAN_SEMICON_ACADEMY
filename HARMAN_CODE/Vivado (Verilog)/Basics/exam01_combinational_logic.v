`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/27 12:01:22
// Design Name: 
// Module Name: exam01_combinational_logic
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


module and_gate(
   input A,
   input B,
   output F
    );
    
    and (F, A, B);  // (츨력, 입력...)_출력은 맨앞에 쓰고 무조건 1개
    
endmodule

module half_adder_structural( //구조적 모델링
   input A,B,
   output sum, carry 
   ); 
  
  xor(sum, A,B);
  and(carry, A,B);
   
endmodule

module half_adder_behavioral( //동작적 모델링
   input A, B,
   output reg sum, carry // wire(도선으로 취급) 와 reg(메모리_always문 안에서 바뀌고 그 값이 저장)
   );
   
   always @(A,B) begin
      case({A,B}) // case문은 모든 경우의 수 다 써주어야한다.
         2'b00: begin sum =0; carry = 0; end
         2'b01: begin sum =1; carry = 0; end
         2'b10: begin sum =1; carry = 0; end
         2'b11: begin sum =0; carry = 1; end
      endcase
   end
   
endmodule

module half_adder_dataflow(
   input A, B,
   output sum, carry
);

   wire [1:0] sum_value;
   
   assign sum_value = A + B; //assign문에 등호 왼쪽은 항상 wire 선언, always문는 항상 reg 선언
   
   assign sum = sum_value[0];
   assign carry = sum_value[1];
   
endmodule

module full_adder_structural(
   input A, B, cin,
   output sum, carry
   );
   
   wire sum_0, carry_0, carry_1;
   
   half_adder_structural ha0 (.A(A), .B(B), .sum(sum_0), .carry(carry_0)); //앞에 .은 HA의 A, 괄호 안에 것은 FA의 A
   half_adder_structural ha1 (.A(sum_0), .B(cin), .sum(sum), .carry(carry_1));
   
   or (carry, carry_0, carry_1);
   
endmodule

module full_adder_behavioral(
   input A, B, cin,
   output reg sum, carry
   );
   
   always @(A,B,cin) begin
      case({A,B,cin})
         3'b000: begin sum=0; carry =0; end
         3'b001: begin sum=1; carry =0; end
         3'b010: begin sum=1; carry =0; end
         3'b011: begin sum=0; carry =1; end
         3'b100: begin sum=1; carry =0; end
         3'b101: begin sum=0; carry =1; end
         3'b110: begin sum=0; carry =1; end
         3'b111: begin sum=1; carry =1; end
      endcase
   end
   
endmodule

module full_adder_dataflow(
   input A, B, cin,
   output sum, carry
   );
   
  wire [1:0] sum_value;
   
   assign sum_value = A + B + cin; //assign문에 등호 왼쪽은 항상 wire 선언, always문는 항상 reg 선언
   
   assign sum = sum_value[0];
   assign carry = sum_value[1];
   
endmodule

module fadder_4bit_s( //verilog에서는 거의 안씀
   input [3:0] A, B,
   input cin,
   output [3:0] sum,
   output carry
   );
   
   wire [2:0]carry_w;
   full_adder_structural fa0 (.A(A[0]), .B(B[0]), .cin(cin),.sum(sum[0]), .carry(carry_w[0]));
   full_adder_structural fa1 (.A(A[1]), .B(B[1]), .cin(carry_w[0]),.sum(sum[1]), .carry(carry_w[1]));
   full_adder_structural fa2 (.A(A[2]), .B(B[2]), .cin(carry_w[1]),.sum(sum[2]), .carry(carry_w[2]));
   full_adder_structural fa3 (.A(A[3]), .B(B[3]), .cin(carry_w[2]),.sum(sum[3]), .carry(carry));
     
endmodule

module fadder_4bit_df( //실제 설계시 주로 이것을 쓴다.
   input [3:0] A, B,
   input cin,
   output [3:0] sum,
   output carry
   );
   
   wire [4:0] temp;
   
   assign temp = A + B+ cin;
   assign sum = temp[3:0];
   assign carry = temp[4];
   
endmodule

module fadd_sub_4bit_s(
   input [3:0] A, B,
   input s, // add: s =0, sub : s=1
   output [3:0] sum,
   output carry
   );
   
   wire [3:0]carry_w;
   
   xor(s0, B[0], s); //primitive gate, 빼기를 위해 B는 s와 xor연산 후 대입한다.
   
   full_adder_structural fa0 (.A(A[0]), .B(s0), .cin(s),.sum(sum[0]), .carry(carry_w[0])); //비트연산자 xor :^, &:and, or: |, ~:not 
   full_adder_structural fa1 (.A(A[1]), .B(B[1]^s), .cin(carry_w[0]),.sum(sum[1]), .carry(carry_w[1]));
   full_adder_structural fa2 (.A(A[2]), .B(B[2]^s), .cin(carry_w[1]),.sum(sum[2]), .carry(carry_w[2]));
   full_adder_structural fa3 (.A(A[3]), .B(B[3]^s), .cin(carry_w[2]),.sum(sum[3]), .carry(carry_w[3]));
   
   not(carry, carry_w[3]);
   
   endmodule
   
module fadder_sub_4bit_df( //실제 설계시 주로 이것을 쓴다.
   input [3:0] A, B,
   input s,
   output [3:0] sum,
   output carry
   );
   
   wire [4:0] temp;
   
   assign temp = s ? A-B:A+B; // 3항연산자 : s가 1이면 좌항 대입, s=0 이면 우항 대입.
   assign sum = temp[3:0];
   assign carry = ~temp[4]; //carry를 반전 시키기 위해
   
endmodule


module comparator_t #(parameter N = 8)(
    input [N-1:0] A, B,
    output equal, greater, less);
    
    assign equal = (A == B) ? 1'b1 : 1'b0;
    assign greater = (A > B) ? 1'b1 : 1'b0;
    assign less = (A < B) ? 1'b1 : 1'b0;

endmodule


module comparator ( //데이터플로우는 비교논리연산자랑 조건논리연산자 사용
   input [1:0]A,B,
   output equal,greater,less //greater:A>B일때 1 아니면 0, less: A<B일때 1 아니면 0
   );
   
   assign equal = (A ==B)? 1'b1:1'b0;//assign equal = A~^B; //xnor:~^  <<구조적모델링 비트연산자
   assign greater = (A>B)? 1'b1:1'b0;//assign greater = A&~B;
   assign less =(A<B)? 1'b1:1'b0; //assign less =~A&B; 
   
endmodule

module comparator_4_bit #(parameter N = 4)( //데이터플로우는 비교논리연산자랑 조건논리연산자 사용
   input [N-1:0]A,B,
   output equal,greater,less //greater:A>B일때 1 아니면 0, less: A<B일때 1 아니면 0
   );
   
   assign equal = (A == B)? 1'b1:1'b0;//assign equal = A~^B; //xnor:~^  <<구조적모델링 비트연산자
   assign greater = ( A>B )? 1'b1:1'b0;//assign greater = A&~B;
   assign less =( A<B )? 1'b1:1'b0; //assign less =~A&B; 
   
endmodule

module comparator_N_bit_test(
   input[1:0]A, B,
   output equal, greater, less
   );
   
   comparator_dataflow_N_bit #(.N(2)) c_16 (.A(A), .B(B), .equal(equal), .greater(greater), .less(less));
   
 endmodule
 
 module comparator_N_bit_b #(parameter N=8)(
    input [N-1:0]A,B,
    output reg equal,greater,less
    );
    
    always @(A,B) begin 
       if(A==B) begin //assign은 조건연산자 가능뿐 if 불가.. always는 조건연산자, 반복문 가능 조건연산자 잘안쓰긴함
          equal = 1;
          greater =0;
          less = 0;
       end
       else if(A>B) begin 
          equal = 0;
          greater =1;
          less = 0;
       end
       else begin
          equal=0;
          greater =0;
          less =1;
       end
    end
    
 endmodule
 
 module decoder_2_4_s(
    input [1:0] code,
    output [3:0] signal 
    );
    
    wire [1:0] code_bar;
    
    not (code_bar[0], code[0]);
    not (code_bar[1], code[1]);
    
    and (signal[0], code_bar[1], code_bar[0]);
    and (signal[1], code_bar[1], code[0]);
    and (signal[2], code[1], code_bar[0]);
    and (signal[3], code[1], code[0]);
    
 endmodule
 
 module decoder_2_4_b(
    input [1:0] code,
    output reg [3:0] signal 
    ); 
    
    always @(code) begin //코드가 블럭이 아니라 1줄일때 begin end 생략 가능
       if     (code ==2'b00)  signal =4'b0001;
       else if(code == 2'b01) signal =4'b0010;
       else if(code ==2'b10)  signal =4'b0100;
       else signal = 4'b1000; //이건 if문 구문 1개로 침,if-else에 딸린 1개
    end
//    always @(code) begin //always문안에 왼쪽변수는 무조건 reg, assign은 begin end 없다. 그저 수식, 책 참고 문법
//       case(code)
//          2'b00: signal =4'b0001;
//          2'b00: signal =4'b0010;
//          2'b00: signal =4'b0100;
//          2'b00: signal =4'b1000; //case문도 1개로 침, case문안에도 한줄이니 생략 가능// 안되면 컨트로 시프트로 한글 입력키 변경
//       endcase
//    end // 컨트롤+ 슬래쉬 : 드래그한 부분 주석처리
 endmodule
 
 
module decoder_2_4_b_2(
    input [1:0] code,
    output reg [3:0] signal);
    
//    always @(code) 
//        if      (code == 2'b00) signal = 4'b0001;
//        else if (code == 2'b01) signal = 4'b0010;
//        else if (code == 2'b10) signal = 4'b0100;
//        else                    signal = 4'b1000;
    
    
    always @(code) 
        case(code)
            2'b00: signal = 4'b0001;
            2'b01: signal = 4'b0010;
            2'b10: signal = 4'b0100;
            2'b11: signal = 4'b1000;
        endcase
    
endmodule
 
module decoder_2_4_d(
    input [1:0] code,
    output [3:0] signal 
    ); 
    
    assign signal = (code == 2'b00) ? 4'b0001 :
                    (code==2'b01) ? 4'b0010 :
                    (code==2'b10) ? 4'b0100 : 4'b1000; //거짓일 경우 반복해서  조건 연산자 사용    
 endmodule
 
 module encoder_4_2(
    input [3:0] signal,
    output [1:0] code
    ); 
    
    assign code = (signal ==4'b0001) ? 2'b00: 
                  (signal ==4'b0010) ? 2'b01:
                  (signal ==4'b0100) ? 2'b10: 2'b11;  
 
 endmodule
 
 module decoder_2_4_en(
    input [1:0]code,
    input enable, //활성화 비활성화 ON OFF
    output [3:0] signal
    );
 
    assign signal = (enable == 1'b0) ? 4'b0000 :
                    (code == 2'b00) ? 4'b0001:
                    (code == 2'b01) ? 4'b0010:
                    (code == 2'b10) ? 4'b0100 : 4'b1000;
 
 endmodule
 
 module decoder_3_8_s( //구조적 설계 //q불러오기는 한번만
    input [2:0]code,
    output [7:0] signal
    );
 
    decoder_2_4_en dec_low(.code(code[1:0]), .enable(~code[2]), .signal(signal[3:0]));
    decoder_2_4_en dec_high (.code(code[1:0]), .enable(code[2]), .signal(signal[7:4]));
    
 endmodule
 
// module decoder_3_8_b(
//     input [2:0] code,
//     output reg [7:0] signal
//    );
    
////    always @(code) begin
////       case(code)
////          3'b000: signal =8'b00000001;
////          3'b001: signal =8'b00000010;
////          3'b010: signal =8'b00000100;
////          3'b011: signal =8'b00001000; 
////          3'b100: signal =8'b00010000;
////          3'b101: signal =8'b00100000;
////          3'b110: signal =8'b01000000;
////          3'b111: signal =8'b10000000; 
////       endcase
////    end 
    
////   always @(code) begin
////      if (code[2] ==1'b0) begin //000,001,010,011
////         if (code[1]==1'b0 ) begin
////            if(code[0]==1'b0) signal=8'b00000001; //000
////            else begin signal=8'b00000010; end //001
////         end
////         if (code[1]==1'b1 ) begin
////            if(code[0]==1'b0) signal=8'b00000100; //010
////            else begin signal=8'b00001000; end //011
////         end
////      end
////      if (code[2] ==1'b1) begin //100,101,110,111
////         if (code[1]==1'b0 ) begin
////            if(code[0]==1'b0) signal=8'b00010000; //100
////            else begin signal=8'b00100000; end //101
////         end
////         if (code[1]==1'b1 ) begin
////            if(code[0]==1'b0) signal=8'b01000000; //110
////            else begin signal=8'b10000000; end //111
////         end
////      end        

// endmodule
 
 

module decoder_2_4_en_b_t(
    input [1:0] code,
    input enable,
    output reg [3:0] signal);

    always @(code, enable)begin
        if (enable) begin
            if      (code == 2'b00) signal = 4'b0001;
            else if (code == 2'b01) signal = 4'b0010;
            else if (code == 2'b10) signal = 4'b0100;
            else                    signal = 4'b1000;
        end
        else begin
            signal = 4'b0000;
        end
    end

endmodule
 
 module decoder_2_4_en_b(
    input [1:0]code,
    input enable,
    output reg [3:0] signal
    );
    
    always @(code, enable) begin 
//       if (enable ==1'b0) signal =4'b0000; //enable=0
//       else if (enable ==1'b1)
//          if (code ==2'b00) signal =4'b0001; //00
//          else if (code ==2'b01) signal = 4'b0010; //01
//          else if (code ==2'b10) signal =4'b0100; //10
//          else if (code ==2'b11) signal = 4'b1000; //11
    
       if (enable) begin  
          if      (code== 2'b00) signal =4'b0001;
          else if (code== 2'b01) signal =4'b0010;
          else if (code== 2'b10) signal =4'b0100;
          else                   signal =4'b1000;
       end
       else signal =4'b0000;
    end
 endmodule
 
 module decoder_3_8_b(
    input [2:0]code,
    output [7:0] signal
    );
 
    decoder_2_4_en_b dec_low(.code(code[1:0]), .enable(~code[2]), .signal(signal[3:0]));
    decoder_2_4_en_b dec_high (.code(code[1:0]), .enable(code[2]), .signal(signal[7:4]));
    
 endmodule
 
 module decoder_7seg(
    input [3:0] hex_value,
    output reg [7:0] seg_7
    );
    
    always @(hex_value) begin
       case(hex_value) //언더바 유무 상관없음 숫자읽을때는
                              //abcd_efgp
           4'b0000: seg_7 = 8'b0000_0011; //8'b11 //4'd3 //0
           4'b0001: seg_7 = 8'b1001_1111; //1
           4'b0010: seg_7 = 8'b0010_0101; //2
           4'b0011: seg_7 = 8'b0000_1101; //3
           4'b0100: seg_7 = 8'b1001_1001; //4
           4'b0101: seg_7 = 8'b0100_1001; //5
           4'b0110: seg_7 = 8'b0100_0001; //6
           4'b0111: seg_7 = 8'b0001_1011; //7
           4'b1000: seg_7 = 8'b0000_0001; //8
           4'b1001: seg_7 = 8'b0001_1001; //9
           4'b1010: seg_7 = 8'b0001_0001; //10, A
           4'b1011: seg_7 = 8'b1100_0001; //11,b
           4'b1100: seg_7 = 8'b0110_0011; //12,C
           4'b1101: seg_7 = 8'b1000_0101; //13,d
           4'b1110: seg_7 = 8'b0110_0001; //14,E
           4'b1111: seg_7 = 8'b0111_0001; //15,F      
       endcase
    end
       
 endmodule
 
 module mux_2_1(
    input [1:0]d,
    input s,
    output f
    );
    
    assign f = s ? d[1]: d[0]; //f= d[s] 가능
    
//    wire sbar, w0, w1;
    
//    not (sbar, s);
//    and(w0, sbar,d[0]);
//    and(w1, s, d[1]);
    
//    or(f, w0, w1);
    
 endmodule
 
 module mux8_1(
    input[3:0]d,
    input [1:0]s,
    output f 
    );
    
    assign f = d[s];
    
 endmodule
 
 module demux_1_4(
    input d,
    input [1:0]s,
    output [3:0] f
    );
 
    assign f = (s == 2'b00) ? {3'b000, d} : //,(콤마)는 합치는 기호
               (s == 2'b01) ? {2'b00,d,1'b0}:
               (s == 2'b10) ? {1'b0,d ,2'b00 }: 
                              {d, 3'b000};
 
 endmodule
 
module mux_demux(
   input [7:0] d,
   input [2:0] s_mux,
   input [1:0] s_demux,
   output [3:0]f
   );
   
   wire w;
   
   mux8_1 mux(.d(d), .s(s_mux), .f(w)); //.이 붙은게 mux8_1꺼 괄호 안이 지금 모듈꺼
   demux_1_4 demux(.d(w), .s(s_demux), .f(f));

endmodule


module fadder_4bit( //

    input [3:0] A, B,
    input cin,
    output [3:0] sum,
    output carry);
    
    wire [4:0] temp;
    
    assign temp = A + B + cin;
    assign sum = temp[3:0];
    assign carry = temp[4];   
    

endmodule


module fadd_sub_4bit( //

    input [3:0] A, B,
    input s,
    output [3:0] sum,
    output carry);
    
    wire [4:0] temp;
    
    assign temp = s ? A - B : A + B;
    assign sum = temp[3:0];
    assign carry = ~temp[4];   
    
endmodule

module comparator_dataflow(
    input A, B,
    output equal, greater, less);
    
    assign equal = (A == B) ? 1'b1 : 1'b0;
    assign greater = (A > B) ? 1'b1 : 1'b0;
    assign less = (A < B) ? 1'b1 : 1'b0;

endmodule



module decoder_3_8(
    input [2:0] code,
    output [7:0] signal);
    
    decoder_2_4_en_b dec_low (.code(code[1:0]), .enable(~code[2]), .signal(signal[3:0]));
    decoder_2_4_en_b dec_high (.code(code[1:0]), .enable(code[2]), .signal(signal[7:4]));
    
endmodule




module mux_4_1(
    input [3:0] d,
    input [1:0] s,
    output f);
    
    assign f = d[s];
    
endmodule

module mux_8_1(
    input [7:0] d,
    input [2:0] s,
    output f);
    
    assign f = d[s];
    
endmodule


module mux_2_1d(
    input d0,d1,
    input s,
    output f
    );
    
    assign f = s ? d1: d0;
endmodule

module bin_to_dec( /////////////교수님이 보내줌!!10진화 2진코드
        input [11:0] bin,
        output reg [15:0] bcd
    );
    reg [3:0] i;
    always @(bin) begin
        bcd = 0;
        for (i=0;i<12;i=i+1)begin
            bcd = {bcd[14:0], bin[11-i]}; //좌시프트
            if(i < 11 && bcd[3:0] > 4) bcd[3:0] = bcd[3:0] + 3;
            if(i < 11 && bcd[7:4] > 4) bcd[7:4] = bcd[7:4] + 3;
            if(i < 11 && bcd[11:8] > 4) bcd[11:8] = bcd[11:8] + 3;
            if(i < 11 && bcd[15:12] > 4) bcd[15:12] = bcd[15:12] + 3;
        end
    end
endmodule
