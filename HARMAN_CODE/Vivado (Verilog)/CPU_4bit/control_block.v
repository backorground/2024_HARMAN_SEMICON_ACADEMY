`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/10 10:18:58
// Design Name: 
// Module Name: control_block
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


module control_block( //명령 제어신호를 포함하고 있다. 
    input clk, reset_p,
    input [7:0] ir_in,
    input zero_flag, sign_flag,
    output mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen,
           breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen,
           dreg_inen, dreg_oen, rreg_inen, rreg_oen, acc_high_reset_p,
           acc_in_select, acc_o_en, op_add, op_sub, op_and, op_mul, op_div,
           outreg_inen, inreg_oen, keych_oen, keyout_in, rom_en,
    output [1:0] acc_low_select, acc_high_select_in
    );
    wire nop,outb,outs,add_s,sub_s,and_s,shl,clr_s,psah,shr,load,jz,jmp,jge, div_s, mul_s, //_s는 signal을 뜻한다.
          mov_ah_cr,mov_ah_dr,mov_tmp_ah,mov_tmp_br,mov_tmp_cr,mov_tmp_dr,mov_tmp_rr,mov_cr_ah,
          mov_cr_br,mov_dr_ah,mov_dr_tmp,mov_dr_br,mov_rr_ah,mov_key_ah,mov_inr_tmp,mov_inr_rr;
    wire [11:0] t;
    ring_counter_clk12 rcount(.clk(clk),.reset_p(reset_p),.t(t));
    
    instr_decoder i_decoder(ir_in, nop,outb,outs,add_s,sub_s,and_s,shl,clr_s,psah,shr,load,jz,jmp,jge, div_s, mul_s, //_s는 signal을 뜻한다.
                            mov_ah_cr,mov_ah_dr,mov_tmp_ah,mov_tmp_br,mov_tmp_cr,mov_tmp_dr,mov_tmp_rr,mov_cr_ah,
                            mov_cr_br,mov_dr_ah,mov_dr_tmp,mov_dr_br,mov_rr_ah,mov_key_ah,mov_inr_tmp,mov_inr_rr);
        
    //jz는 연산의 결과가 0이면(비교 연산의 결과가 같을 때) 점프해라 => zero_flag를 본다. pc에 특정번지 주소를 덮어쓴다.
    
    control_signal c_signal( t,
                             nop,outb,outs,add_s,sub_s,and_s,shl,clr_s,psah,shr,load,jz,jmp,jge/*jump great equal jump*/, div_s, mul_s, //_s는 signal을 뜻한다.
                             mov_ah_cr,mov_ah_dr,mov_tmp_ah,mov_tmp_br,mov_tmp_cr,mov_tmp_dr,mov_tmp_rr,mov_cr_ah,
                             mov_cr_br,mov_dr_ah,mov_dr_tmp,mov_dr_br,mov_rr_ah,mov_key_ah,mov_inr_tmp,mov_inr_rr,
                             zero_flag, sign_flag,
                             
                             mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen,
                             breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen,
                             dreg_inen, dreg_oen, rreg_inen, rreg_oen, acc_high_reset_p,
                             acc_in_select, acc_o_en, op_add, op_sub, op_and, op_mul, op_div,
                             outreg_inen, inreg_oen, keych_oen, keyout_in, rom_en,
                             acc_low_select, acc_high_select_in);
endmodule

module control_signal( //조합회로, 디코더
    input [11:0] t, //링카운터의 출력
    input nop,outb,outs,add_s,sub_s,and_s,shl,clr_s,psah,shr,load,jz,jmp,jge/*jump great equal jump*/, div_s, mul_s, //_s는 signal을 뜻한다.
          mov_ah_cr,mov_ah_dr,mov_tmp_ah,mov_tmp_br,mov_tmp_cr,mov_tmp_dr,mov_tmp_rr,mov_cr_ah,
          mov_cr_br,mov_dr_ah,mov_dr_tmp,mov_dr_br,mov_rr_ah,mov_key_ah,mov_inr_tmp,mov_inr_rr,
    input zero_flag, sign_flag,
    output mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen,
           breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen,
           dreg_inen, dreg_oen, rreg_inen, rreg_oen, acc_high_reset_p,
           acc_in_select, acc_o_en, op_add, op_sub, op_and, op_mul, op_div,
           outreg_inen, inreg_oen, keych_oen, keyout_inen, rom_en,
    output [1:0] acc_low_select, acc_high_select_in
);
    assign pc_oen = t[0] | (t[3] & (load | jz | jmp | jge));
    assign mar_inen = t[0] | (t[3] & (load | jz | jmp | jge));
    assign pc_inc = t[1] | (t[4] & (load | jz | jmp | jge));
    assign mdr_oen = t[2] | (t[5] & (load | (jz & zero_flag) | jmp | (jge & ~sign_flag)));
    assign ir_inen = t[2];
    assign tmpreg_inen = (t[3]&(mov_dr_tmp|mov_inr_tmp))|(t[5]&load);
    assign tmpreg_oen = t[3]&(outb|mov_tmp_ah|mov_tmp_br|mov_tmp_cr | mov_tmp_dr|mov_tmp_rr);
    assign creg_inen = t[3]&(mov_ah_cr|mov_tmp_cr);
    assign creg_oen = t[3]&(mov_cr_ah|mov_cr_br);
    assign dreg_inen = t[3]&(mov_ah_dr|mov_tmp_dr);
    assign dreg_oen = t[3]&(mov_dr_ah|mov_dr_br|mov_dr_tmp);
    assign rreg_inen = t[3]&(mov_tmp_rr|mov_inr_rr);
    assign rreg_oen = t[3]&mov_rr_ah;
    assign breg_inen = t[3]&(mov_tmp_br|mov_cr_br|mov_dr_br);
    assign load_pc = t[5]&((zero_flag&jz)|(~sign_flag&jge)|jmp);
    assign acc_o_en = t[3]&(outs|mov_ah_cr|mov_ah_dr);
    assign acc_in_select = t[3]&(mov_tmp_ah|mov_cr_ah|mov_rr_ah|mov_key_ah|mov_dr_ah);
    assign acc_high_reset_p = t[3]&clr_s;
    assign acc_high_select_in[1] = (t[3]&(add_s|sub_s|and_s|div_s|mul_s|shl|mov_tmp_ah|mov_cr_ah|
           mov_rr_ah|mov_key_ah|mov_dr_ah))|(mul_s&(t[5]|t[7]|t[9]))|
          (div_s&(t[4]|t[5]|t[6]|t[7]|t[8]|t[9]|t[10]));
    assign acc_high_select_in[0] = (t[3]&(add_s|sub_s|and_s|mul_s|shr|mov_tmp_ah|mov_cr_ah|mov_rr_ah|
           mov_key_ah|mov_dr_ah))|(t[4]&(add_s|div_s|mul_s))|
          (mul_s&(t[5]|t[6]|t[7]|t[8]|t[9]|t[10]))| (div_s&(t[6]|t[8]|t[10]));
    assign acc_low_select[1] = (t[3]&(div_s|psah|shl))|(div_s&(t[5]|t[7]|t[9]|t[11]));
    assign acc_low_select[0] = (t[3]&(psah|shr))|(t[4]&(add_s|mul_s))|(mul_s&(t[6]|t[8]|t[10]));
    assign op_add = t[3]&add_s;
    assign op_sub = t[3]&sub_s;
    assign op_and = t[3]&and_s;
    assign op_div = div_s&(t[4]|t[6]|t[8]|t[10]);
    assign op_mul = mul_s&(t[3]|t[5]|t[7]|t[9]);
    assign rom_en = ~(t[1]|((load|jz|jmp|jge)&t[4]));
    assign mdr_inen = t[1]|((load|jz|jmp|jge)&t[4]);
    assign inreg_oen = t[3]&(mov_inr_tmp|mov_inr_rr);
    assign keych_oen = t[3]&mov_key_ah;
    assign outreg_inen = t[3]&outs;
    assign keyout_inen = t[3]&outb;
endmodule





