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


module alu( //+, -, x, %, and, �� ���� ������ ALU
    input clk, reset_p,
    input op_add, op_sub, op_mul, op_div, op_and,alu_lsb/*lsb�� ��������Ʈ*/, //���
    input [3:0]acc_high_data,bus_reg_data,
    output [3:0]alu_data,
    
    //�񱳿����� (-)�� ��ü �����ϴ�. 
    output zero_flag /*���� �� ���� ��, ���ϱ� �Ҷ��� ������ �ȵȴ�.*/, 
           sign_flag /*ū�� ������*/, 
           carry_flag, 
           cout /*carry�� ���(=carryout)*/
  
    );
    
    wire [3:0]sum;
    
    fadder_sub_4bit_df fadd_sub( .A(acc_high_data), //ACC�� 8bit������ ���� 4bit�� �޴´�.
                                 .B(bus_reg_data),  //BREG�� 4bit
                                 .s(op_sub | op_div), //1�̸� ����, 0�̸� ���ϱ� 
                                                      //�����⵵ ����� ���, ���ϱ�� ���ϱ�� ����Ѵ�.
                                 .sum(sum),
                                 .carry(cout)); 
    
    assign alu_data = op_and ? (acc_high_data & bus_reg_data) : sum;
    
    register_Nbit_p #(.N(1)) zero_f(.clk(clk), 
                                    .reset_p(reset_p),
                                    .d(~(|sum)),// |sum == sum[0]|sum[1]|sum[2]|sum[3] 
                                                //verilog ����, C�� ����. �� ��Ʈ�� OR�Ѵ�.
                                                //!�� �� NOT, ~�� ��Ʈ NOT
                                                //!sum�ص� �Ǳ��Ѵ�. �� ���� �ѹ� �Ẹ���� �Ѱ��̴�.
                                    .wr_en(op_sub), 
                                    .rd_en(1),//�׻� �о�� ��
                                    .q(zero_flag));
    
    register_Nbit_p #(.N(1)) sign_f(.clk(clk), 
                                    .reset_p(reset_p),
                                    .d(!cout & op_sub), //op_sub==1�̰� cout==0�̾����
                                    .wr_en(op_sub), 
                                    .rd_en(1),//�׻� �о�� ��
                                    .q(sign_flag));
                                    
    //���� �� ���� ���;��Ѵ�.                                
    register_Nbit_p #(.N(1)) carry_f(.clk(clk), 
                                     .reset_p(reset_p),
                                     .d(cout & ( op_add | op_div | (op_mul & alu_lsb))), //�����Ҷ� cout�� ���̳ʽ��� �ƴҶ��� 1�̳��´�. 
                                     .wr_en(1),//�׻� 
                                     .rd_en(1),//�׻�
                                     .q(carry_flag));
    
    
endmodule
