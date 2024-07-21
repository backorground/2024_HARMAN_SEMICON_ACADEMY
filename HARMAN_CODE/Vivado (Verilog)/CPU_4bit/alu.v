`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/04 11:17:45
// Design Name: 
// Module Name: alu
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


module alu( //+, -, x, %, and, 비교 연산 가능한 ALU
    input clk, reset_p,
    input op_add, op_sub, op_mul, op_div, op_and,alu_lsb/*lsb는 최하위비트*/, //명령
    input [3:0]acc_high_data,bus_reg_data,
    output [3:0]alu_data,
    
    //비교연산은 (-)로 대체 가능하다. 
    output zero_flag /*빼기 후 같을 때, 더하기 할때는 나오면 안된다.*/, 
           sign_flag /*큰지 작은지*/, 
           carry_flag, 
           cout /*carry의 출력(=carryout)*/
  
    );
    
    wire [3:0]sum;
    
    fadder_sub_4bit_df fadd_sub( .A(acc_high_data), //ACC는 8bit이지만 상위 4bit만 받는다.
                                 .B(bus_reg_data),  //BREG는 4bit
                                 .s(op_sub | op_div), //1이면 빼기, 0이면 더하기 
                                                      //나누기도 빼기로 취급, 곱하기는 더하기로 취급한다.
                                 .sum(sum),
                                 .carry(cout)); 
    
    assign alu_data = op_and ? (acc_high_data & bus_reg_data) : sum;
    
    register_Nbit_p #(.N(1)) zero_f(.clk(clk), 
                                    .reset_p(reset_p),
                                    .d(~(|sum)),// |sum == sum[0]|sum[1]|sum[2]|sum[3] 
                                                //verilog 문법, C언어에 없다. 각 비트를 OR한다.
                                                //!는 논리 NOT, ~는 비트 NOT
                                                //!sum해도 되긴한다. 저 문법 한번 써보려고 한것이다.
                                    .wr_en(op_sub), 
                                    .rd_en(1),//항상 읽어야 함
                                    .q(zero_flag));
    
    register_Nbit_p #(.N(1)) sign_f(.clk(clk), 
                                    .reset_p(reset_p),
                                    .d(!cout & op_sub), //op_sub==1이고 cout==0이어야함
                                    .wr_en(op_sub), 
                                    .rd_en(1),//항상 읽어야 함
                                    .q(sign_flag));
                                    
    //덧셈 할 때만 나와야한다.                                
    register_Nbit_p #(.N(1)) carry_f(.clk(clk), 
                                     .reset_p(reset_p),
                                     .d(cout & ( op_add | op_div | (op_mul & alu_lsb))), //빼기할때 cout은 마이너스가 아닐때만 1이나온다. 
                                     .wr_en(1),//항상 
                                     .rd_en(1),//항상
                                     .q(carry_flag));
    
    
endmodule
