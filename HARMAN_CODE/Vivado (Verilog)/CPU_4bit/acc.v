`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/04 12:15:11
// Design Name: 
// Module Name: acc
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


module half_acc(
    input clk, reset_p,
    input load_msb, load_lsb,
    input rd_en,
    input [1:0] s, //01좌시프트, 10 우쉬프트, 11은 데이터로드, 00은 데이터 유지
    input [3:0] data_in,
    output [3:0] data2bus, register_data
    );
    
    reg [3:0] d;
    always @* begin //@*은 레벨 트리거, 조합회로 만들기
        case(s)
            2'b00: d= register_data; //데이터 유지
            2'b01: d= {load_msb, register_data[3:1]}; //우시프트
            2'b10: d= {register_data[2:0], load_lsb}; //좌시프트
            2'b11: d= data_in; //데이터 로드
        endcase    
    end
    
    register_Nbit_p #(.N(4)) h_acc(.clk(clk),
                                   .reset_p(reset_p),
                                   .d(d),
                                   .wr_en(1), //항상
                                   .rd_en(rd_en),
                                   .register_data(register_data),
                                   .q(data2bus));
    
endmodule

module acc(
    input clk, reset_p,acc_high_reset_p, fill_value, rd_en,
    input acc_in_select,
    input [1:0] acc_high_select,acc_low_select,
    input [3:0] bus_data, alu_data,
    output [3:0] high_data2bus, acc_high_data2alu,
    output [3:0] low_data2bus, acc_low_data
    
    );
    
    wire [3:0] acc_high_in;
    assign acc_high_in = acc_in_select ? bus_data : alu_data;
    
    half_acc acc_high(.clk(clk), 
                      .reset_p(reset_p | acc_high_reset_p),//상위 4bit만 reset하기 위해서
                      .load_msb(fill_value), 
                      .load_lsb(acc_low_data[3]),
                      .rd_en(rd_en),
                      .s(acc_high_select),
                      .data_in(acc_high_in),
                      .data2bus(high_data2bus), 
                      .register_data(acc_high_data2alu));
                      
    half_acc acc_low(.clk(clk), 
                     .reset_p(reset_p),
                     .load_msb(acc_high_data2alu[0]), 
                     .load_lsb(fill_value),
                     .rd_en(rd_en),
                     .s(acc_low_select),
                     .data_in(acc_high_data2alu),
                     .data2bus(low_data2bus), 
                     .register_data(acc_low_data));

endmodule