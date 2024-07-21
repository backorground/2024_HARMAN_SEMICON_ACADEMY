`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/11 14:37:12
// Design Name: 
// Module Name: calculator_top
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
module calculator_top(
    input clk, reset_p,
    input [3:0] row,
    output [3:0] col,
    output [7:0] seg_7,
    output [3:0] com
);

    wire key_valid;
    wire [3:0] key_value;
    
    wire [3:0] kout;
    wire [7:0] outreg_data;
    
    wire [15:0] value, dec_data;
    
    assign value = {kout, 4'hf, dec_data[7:0]};
    key_pad_cntr keypad(clk, reset_p, row, col, key_value, key_valid);
    
    processor cpu(
        .clk(clk), .reset_p(reset_p),
        .key_value(key_value),
        .key_valid(key_valid),
        .kout(kout),
        .outreg_data(outreg_data));
        
    bin_to_dec b2d(.bin({4'b0000, outreg_data}), .bcd(dec_data));

    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
endmodule