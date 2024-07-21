`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/05 09:18:09
// Design Name: 
// Module Name: block_alu_acc
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


module block_alu_acc( // ALU + ACC
    input clk, reset_p, acc_high_reset_p,
    input rd_en, acc_in_select,
    input [1:0] acc_high_select_in, acc_low_select,
    input [3:0] bus_data, bus_reg_data,
    input op_add, op_sub, op_mul, op_div, op_and,
    output zero_flag, sign_flag,
    output [7:0] acc_data
    );
    
   //acc
    wire fill_value;
    wire [3:0] high_data2bus, acc_high_data2alu;
    wire [3:0] low_data2bus, acc_low_data;
    wire [3:0] alu_data;
    wire [1:0] acc_high_select;

    //alu
    wire [3:0] acc_high_data;
    wire alu_lsb, carry_flag, cout;
    
    assign acc_data = {high_data2bus, low_data2bus};
    assign acc_high_select[1] = (op_mul|op_div) ? ((op_mul & acc_low_data[0]) | (op_div & cout)) : acc_high_select_in[1];
    assign acc_high_select[0] = (op_mul|op_div) ? ((op_mul & acc_low_data[0]) | (op_div & cout)) : acc_high_select_in[0];
    assign fill_value = carry_flag;
    assign alu_lsb = acc_high_data2alu[0];
    assign acc_high_data = acc_high_data2alu;
    
    acc blcok_acc(.clk(clk), .reset_p(reset_p),
                  .acc_high_reset_p(acc_high_reset_p), 
                  .fill_value(fill_value), 
                  .rd_en(rd_en),
                  .acc_in_select(acc_in_select),
                  .acc_high_select(acc_high_select),
                  .acc_low_select(acc_low_select),
                  .bus_data(bus_data), 
                  .alu_data(alu_data),
                  .high_data2bus(high_data2bus), 
                  .acc_high_data2alu(acc_high_data2alu),
                  .low_data2bus(low_data2bus), 
                  .acc_low_data(acc_low_data));

    alu block_alu(.clk(clk), .reset_p(reset_p),
                  .op_add(op_add), 
                  .op_sub(op_sub), 
                  .op_mul(op_mul), 
                  .op_and(op_and),
                  .op_div(op_div),
                  .alu_lsb(alu_lsb),
                  .acc_high_data(acc_high_data),
                  .bus_reg_data(bus_reg_data),
                  .alu_data(alu_data),
                  .zero_flag(zero_flag), 
                  .sign_flag(sign_flag), 
                  .carry_flag(carry_flag), 
                  .cout(cout));

endmodule
