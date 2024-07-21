`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/05 15:31:30
// Design Name: 
// Module Name: program_addr_counter
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


module program_addr_counter(
    input clk, reset_p,
    input pc_inc, load_pc, pc_rd_en,
    input [7:0] pc_in,
    output [7:0] pc_out
    );
    
    wire [7:0] sum, cur_addr, next_addr;
    assign next_addr = load_pc ? pc_in : sum;
    
    half_addr_N_bit #(.N(8)) pc(.inc(pc_inc), 
                                .load_data(cur_addr),
                                .sum(sum));
    
    register_Nbit_p #(.N(8)) pc_reg(.clk(clk),
                                    .reset_p(reset_p),
                                    .d(next_addr),
                                    .wr_en(1),
                                    .rd_en(pc_rd_en),
                                    .register_data(cur_addr),
                                    .q(pc_out)); 
endmodule
