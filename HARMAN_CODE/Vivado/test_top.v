`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/27 11:56:23
// Design Name: 
// Module Name: test_top
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module button_ledbar_top( ////////////
   input clk, reset_p,
   input [3:0]btn,
   output [7:0]seg_7,
   output [3:0]com);
    
    reg [15:0]btnU_counter;
    wire [3:0]btnU_pedge;
     button_cntr btnU_cntr0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btnU_pedge[0])); 
     button_cntr btnU_cntr1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btnU_pedge[1])); 
     button_cntr btnU_cntr2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btnU_pedge[2])); 
     button_cntr btnU_cntr3 (.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btnU_pedge[3]));   
      
     /* genvar i; for문 용으로 쓰이는 변수, generate문 안에서만 사용, 위에 4줄을 for문으로 써보기
     generate
        for(i=0;i<4;i=i+1) begin :btn_cntr
           button_cntr btn_inst(.clk(clk), .reset_p(reset_p), .btn(btn[i]), .btn_pe(btnU_pedge[i]));      
        end
     endgenerate      
   */
   
   always @(posedge clk, posedge reset_p) begin
      if(reset_p) btnU_counter = 0;
      else begin
         if(btnU_pedge[0]) btnU_counter = btnU_counter + 1;
         else if(btnU_pedge[1]) btnU_counter = btnU_counter - 1;
         else if(btnU_pedge[2]) btnU_counter = {btnU_counter[14:0], btnU_counter[15]};
         else if(btnU_pedge[3]) btnU_counter = {btnU_counter[0], btnU_counter[15:1]};
      end
   end
   
    fnd_4digit_cntr(.clk(clk), .reset_p(reset_p),.value(btnU_counter), .seg_7_an(seg_7), .com(com));

 endmodule
 
 module button_test_top( //완전한 카운터
   input clk, reset_p,
   input btnU,
   output [7:0] seg_7,
   output [3:0] com
   );
   
   reg [15:0] btn_counter;
   reg [3:0] value;
   wire btnU_pedge;
 //17비트중 왜 16썼는지 0번비트 20나노 1번 40나노 2번 ㅓ 80나노 3번 160나노 ...16번 1280마이크로 = 1.28ms속도
   
   button_cntr btnU_cntr (.clk(clk), 
                          .reset_p(reset_p), 
                          .btn(btnU), 
                          .btn_pe(btnU_pedge)); //모듈 컨트롤러
                          
   fnd_4digit_cntr fnd(.clk(clk), 
                       .reset_p(reset_p), 
                       .value(btn_counter), 
                       .seg_7_ca(seg_7), 
                       .com(com));
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)btn_counter = 0;
        else begin
            if(btnU_pedge) btn_counter = btn_counter + 1;
        end
    end
    
endmodule

module led_bar_top(
   input clk, reset_p,
   output [7:0]led_bar,
   output reg clk_div_16);
   
   reg [28:0] clk_div;
   always @(posedge clk) clk_div = clk_div+1;
   
   assign led_bar= ~clk_div[28:21];
endmodule

  
module up_conter_test_top(
   input clk,reset_p,
   output [15:0]count,
   output [7:0]seg_7,
   output [3:0]com
   );
    reg [31:0] count_32;

   always @(posedge clk, posedge reset_p) begin
      if(reset_p) count_32=0;
      else count_32 = count_32 +1;
   end
   
   assign count = count_32 [31:16];

   ring_counter_fnd rc(.clk(clk), .reset_p(reset_p), .com(com));
   
   reg [3:0] value;
   
   always @(posedge clk) begin
      case(com)
         4'b0111: value = count_32[15:12];
         4'b1011: value = count_32[11:8];
         4'b1101: value = count_32[7:4];
         4'b1110: value = count_32[3:0];
         default: value = count_32[3:0];
      endcase   
   end
   
   wire [7:0]seg_7_bar;
   
   decoder_7seg fnd(.hex_value(value), .seg_7(seg_7_bar));
   
   assign seg_7= ~seg_7_bar;
   
endmodule


module key_pad_test_top(
   input clk, reset_p,
   input [3:0] row,
   output [3:0] col,
   output [7:0] seg_7,
   output [3:0] com,
   output [3:0] key_value,
   output key_valid   
   );
  
  //1비트 와이어 생략가능
//  wire [3:0] key_value;
  reg [15:0] key_counter;  
  keypad_cntr_fsm key_pad(.clk(clk), .reset_p(reset_p), .row(row), .col(col), .key_value(key_value), .key_valid(key_valid));  
  
  edge_detector_n ed1(.clk(clk), .reset_p(reset_p),.cp(key_valid),.p_edge(key_valid_pe));
  
  always @(posedge clk or posedge reset_p) begin
     if(reset_p) key_counter =0;
     else if(key_valid_pe) begin
        if (key_value ==1) key_counter = key_counter+1;
        else if(key_value==2) key_counter= key_counter-1;
     end   
  end
  
  fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(key_counter), .seg_7_ca(seg_7), .com(com));
  
endmodule

module watch_top(
   input clk, reset_p,
   input [2:0] btn,
   output [3:0] com,
   output [7:0] seg_7,
   output reg set_mode
   );

   wire clk_usec, clk_msec, clk_sec, clk_min; //1bit 와이어는 생략 가능
   wire [3:0]sec1, sec10, min1, min10;
      
   clock_usec usec_clk(clk,reset_p,clk_usec); //생략가능. 하지만 입출력의 순서대로 연결해주면 됨.보통은 변수이름 같이씀
   clock_div_1000 msec_clk(clk, reset_p,clk_usec,clk_msec);
   clock_div_1000 sec_clk(clk, reset_p,clk_msec,clk_sec);
   clock_min min_clk(clk, reset_p,clk_sec_btn, clk_min);
   
   counter_dec_60 counter_sec(clk,reset_p,clk_sec_btn,sec1, sec10);
   counter_dec_60 counter_min(clk,reset_p,clk_min_btn,min1, min10);
     
   fnd_4digit_cntr fnd(.clk(clk),.reset_p(reset_p), .value({min10,min1,sec10,sec1}), .seg_7_ca(seg_7), .com(com));
   
   //버튼 추가
  
   wire [2:0]btn_edge;
  
   button_cntr btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]),.btn_ne(btn_edge[0]));
   button_cntr btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]),.btn_ne(btn_edge[1]));
   button_cntr btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]),.btn_ne(btn_edge[2]));
   
   always@(posedge clk or posedge reset_p)begin //set_mode_toggle
      if (reset_p) begin
         set_mode<=0;
      end
      else if (btn_edge[0]) begin
         set_mode<= ~set_mode; end
   end   
   
   assign clk_sec_btn = set_mode? btn_edge[1]:clk_sec;
   assign clk_min_btn = set_mode? btn_edge[2]:clk_min;
   
endmodule//내가한거

module loadable_watch_top_t( //셋팅을 취소하고원래 돌고있는 시계로 돌아갈수있다. 이전에는 수정중에는 시계가 안돌음.
   input clk, reset_p,
   input [2:0] btn,
   output [3:0] com,
   output [7:0] seg_7,
   output set_mode //보통 1일 때 셋모드
   );
   
   wire sec_edge, min_edge;
   wire clk_usec, clk_msec, clk_sec, clk_min; //1bit 와이어는 생략 가능
   
   clock_usec usec_clk(clk,reset_p,clk_usec); //생략가능. 하지만 입출력의 순서대로 연결해주면 됨.보통은 변수이름 같이씀
   clock_div_1000 msec_clk(clk, reset_p,clk_usec,clk_msec);
   clock_div_1000 sec_clk(clk, reset_p,clk_msec,clk_sec);
   clock_min min_clk(clk, reset_p,sec_edge, clk_min);

   wire [3:0]sec1, sec10, min1, min10;

   wire cur_time_load_en, set_time_load_en;
   wire [3:0] cur_sec1, cur_sec10, set_sec1, set_sec10;
   wire [3:0] cur_min1, cur_min10, set_min1, set_min10;
   
   loadable_counter_dec_60 cur_time_sec(.clk(clk), .reset_p(reset_p),.clk_time(clk_sec),
                                        .load_enable(cur_time_load_en),.set_value1(set_sec1),.set_value10(set_sec10),
                                        .dec1(cur_sec1),.dec10(cur_sec10));
                                        
   loadable_counter_dec_60 cur_time_min(.clk(clk), .reset_p(reset_p),.clk_time(clk_min),
                                        .load_enable(cur_time_load_en),.set_value1(set_min1),.set_value10(set_min10),
                                        .dec1(cur_min1),.dec10(cur_min10));
                                        
   loadable_counter_dec_60 set_time_sec(.clk(clk), .reset_p(reset_p),.clk_time(btn_pedge[1]),
                                        .load_enable(set_time_load_en),.set_value1(cur_sec1),.set_value10(cur_sec10),
                                        .dec1(set_sec1),.dec10(set_sec10));    
   loadable_counter_dec_60 set_time_min(.clk(clk), .reset_p(reset_p),.clk_time(btn_pedge[2]),
                                        .load_enable(set_time_load_en),.set_value1(cur_min1),.set_value10(cur_min10),
                                        .dec1(set_min1),.dec10(set_min10));                                  
   
   wire[15:0] value;
   
   assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
   assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
   assign value = set_mode ? set_time : cur_time;
    
   fnd_4digit_cntr fnd(.clk(clk),.reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
   
   // 버튼 추가
   wire [2:0] btn_pedge;
   button_cntr btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]),.btn_ne(btn_pedge[0]));
   button_cntr btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]),.btn_ne(btn_pedge[1]));
   button_cntr btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]),.btn_ne(btn_pedge[2]));

   T_flip_flop_p t(.clk(clk), .reset_p(reset_p),.t(btn_pedge[0]),.q(set_mode));
   
   edge_detector_n ed(.clk(clk),.reset_p(reset_p), .cp(set_mode), .n_edge(cur_time_load_en),.p_edge(set_time_load_en));
   
   
   assign sec_edge = set_mode? btn_pedge[1]: clk_sec; 
   assign min_edge = set_mode? btn_pedge[2]: clk_min; 
  
endmodule

module watch_top_t( input clk, reset_p,
   input [2:0] btn,
   output [3:0] com,
   output [7:0] seg_7,
   output set_mode //보통 1일 때 셋모드
   );
    
   wire sec_edge, min_edge; 
   wire clk_usec, clk_msec, clk_sec, clk_min; //1bit 와이어는 생략 가능
   
   clock_usec usec_clk(clk,reset_p,clk_usec); //생략가능. 하지만 입출력의 순서대로 연결해주면 됨.보통은 변수이름 같이씀
   clock_div_1000 msec_clk(clk, reset_p,clk_usec,clk_msec);
   clock_div_1000 sec_clk(clk, reset_p,clk_msec,clk_sec);
   clock_min min_clk(clk, reset_p,sec_edge, clk_min);

   wire [3:0]sec1, sec10, min1, min10;
   counter_dec_60 counter_sec(clk,reset_p,sec_edge,sec1, sec10);
   counter_dec_60 counter_min(clk,reset_p,min_edge,min1, min10);
   
   fnd_4digit_cntr fnd(.clk(clk),.reset_p(reset_p), .value({min10,min1, sec10,sec1}), .seg_7_ca(seg_7), .com(com));
   
   // 버튼 추가
   wire [2:0] btn_pedge;
   button_cntr btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]),.btn_ne(btn_pedge[0]));
   button_cntr btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]),.btn_ne(btn_pedge[1]));
   button_cntr btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]),.btn_ne(btn_pedge[2]));

   T_flip_flop_p t(.clk(clk), .reset_p(reset_p),.t(btn_pedge[0]),.q(set_mode));
   
   
   assign sec_edge = set_mode? btn_pedge[1]: clk_sec; 
   assign min_edge = set_mode? btn_pedge[2]: clk_min; 
endmodule

module stop_watch_top(
    input clk, reset_p,
    input [4:0]btn,
    output [3:0] com,
    output [7:0]seg_7
    );
    
    wire clk_usec, clk_msec, clk_sec, clk_min;
    wire [3:0] btn_pedge;
    wire start_stop;
    wire clk_start; 
    wire [3:0] sec1, sec10,min1,min10;
   
   clock_usec usec_clk(clk_start,reset_p,clk_usec); //생략가능. 하지만 입출력의 순서대로 연결해주면 됨.보통은 변수이름 같이씀
   clock_div_1000 msec_clk(clk_start, reset_p,clk_usec,clk_msec);
   clock_div_1000 sec_clk(clk_start, reset_p,clk_msec,clk_sec);
   clock_min min_clk(clk_start, reset_p,clk_sec, clk_min);

   button_cntr btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]),.btn_ne(btn_pedge[0]));
   button_cntr btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]),.btn_ne(btn_pedge[1]));
   button_cntr btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]),.btn_ne(btn_pedge[2]));
   
   T_flip_flop_p t(.clk(clk), .reset_p(reset_p),.t(btn_pedge[0]),.q(start_stop));
   
   assign clk_start = start_stop? clk :0;
   
   counter_dec_60 counter_sec(clk,reset_p,clk_sec,sec1, sec10);
   counter_dec_60 counter_min(clk,reset_p,clk_min,min1, min10);
   
   reg [15:0]lap_time;
   wire lap_swatch, lab_load;
   T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p),.t(btn_pedge[1]),.q(lap_swatch));
   
   edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch),.p_edge(lap_load));
   
    
   always @(posedge clk or posedge reset_p) begin
    if(reset_p) lap_time =0;
    else if(lap_load) lap_time= {min10,min1, sec10, sec1};
   end
     
   wire[15:0] value, cur_time;
   assign cur_time = {min10, min1, sec10, sec1};
   assign value = lap_swatch? lap_time : {min10, min1, sec10, sec1};
  
   fnd_4digit_cntr fnd1(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
      
endmodule


module stop_watch_csec_top(//100분의 1초 해보기
   input clk, reset_p,
    input [4:0]btn,
    output [3:0] com,
    output [7:0]seg_7
    );
    
    wire clk_usec, clk_msec, clk_sec, clk_min;
    wire [3:0] btn_pedge;
    wire start_stop;
    wire clk_start; 
    wire [3:0] sec1, sec10,csec1,csec10;
   
   clock_usec usec_clk(clk_start,reset_p,clk_usec); //생략가능. 하지만 입출력의 순서대로 연결해주면 됨.보통은 변수이름 같이씀
   clock_div_1000 msec_clk(clk_start, reset_p,clk_usec,clk_msec);
   clock_div_1000 sec_clk(clk_start, reset_p,clk_msec,clk_sec);
   clock_min min_clk(clk_start, reset_p,clk_sec, clk_min);
    

   button_cntr btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]),.btn_ne(btn_pedge[0]));
   button_cntr btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]),.btn_ne(btn_pedge[1]));
   button_cntr btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]),.btn_ne(btn_pedge[2]));
  
   T_flip_flop_p t(.clk(clk), .reset_p(reset_p),.t(btn_pedge[0]),.q(start_stop));
   
   assign clk_start = start_stop? clk :0;
   
   counter_dec_60 counter_sec(clk,reset_p,clk_sec,sec1, sec10);
   counter_dec_60 counter_min(clk,reset_p,clk_min,min1, min10);
   
   reg [15:0]lap_time;
   wire lap_swatch, lab_load;
   T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p),.t(btn_pedge[1]),.q(lap_swatch));
   
   edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch),.p_edge(lap_load));
   
    
   always @(posedge clk or posedge reset_p) begin
    if(reset_p) lap_time =0;
    else if(lap_load) lap_time= {min10,min1, sec10, sec1};
   end
     
   wire[15:0] value, cur_time;
   assign cur_time = {min10, min1, sec10, sec1};
   assign value = lap_swatch? lap_time : {min10,min1, sec10, sec1};
  
   fnd_4digit_cntr fnd1(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
      
endmodule

//////m초 해보기!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module up_counter_test_top(
    input clk, reset_p,
    output [15:0] count,
    output [7:0] seg_7,
    output [3:0] com);

    reg [31:0] count_32;

    always @(posedge clk, posedge reset_p)begin
        if(reset_p) count_32 = 0;
        else count_32 = count_32 + 1;
    end
    
    assign count = count_32[31:16];
    
    ring_counter_fnd rc(.clk(clk), .reset_p(reset_p), .com(com));
    
    reg [3:0] value;
    
    always @(posedge clk)begin
        case(com)
            4'b0111: value = count_32[31:28];
            4'b1011: value = count_32[27:24];
            4'b1101: value = count_32[23:20];
            4'b1110: value = count_32[19:16];
        endcase 
    end
    
    decoder_7seg fnd (.hex_value(value), .seg_7(seg_7));

endmodule




module keypad_test_top(
    input clk, reset_p,
    input [3:0] row,
    output [3:0] col,
    output [7:0] seg_7,
    output [3:0] com);
    
    wire [3:0] key_value;
    reg [15:0] key_counter;
    keypad_cntr_FSM key_pad(.clk(clk), .reset_p(reset_p),
            .row(row), .col(col), .key_value(key_value), .key_valid(key_valid));
            
    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(key_valid), .p_edge(key_valid_pe));
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) key_counter = 0;
        else if(key_valid_pe)begin
            if(key_value == 1) key_counter = key_counter + 1;
            else if(key_value == 2) key_counter = key_counter - 1;
        end
    end     
    wire [15:0] value;
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(key_counter),
            .seg_7_ca(seg_7), .com(com));
    
    
endmodule

//module watch_top(
//    input clk, reset_p,
//    input [2:0] btn,
//    output [3:0] com,
//    output [7:0] seg_7,
//    output [15:0]value);
    
//    wire clk_usec, clk_msec, clk_sec, clk_min;
//    wire [2:0]btnU_pedge;
//    wire set_mode;
//    wire w1, w2;
//    wire [3:0] sec1, sec10, min1, min10;
    
//    clock_usec usec_clk(clk, reset_p, clk_usec);
//    clock_div_1000 msec_clk(clk, reset_p, clk_usec, clk_msec);
//    clock_div_1000 sec_clk(clk, reset_p, clk_msec, clk_sec);
//    clock_min min_clk(clk, reset_p, w1, clk_min);
    
//    button_cntr btnU_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btnU_pedge[0]));
//    button_cntr btnU_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btnU_pedge[1]));
//    button_cntr btnU_cntr3(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btnU_pedge[2]));
    
//    T_flip_flop_p_cntr T0(.clk(clk), .reset_p(reset_p), .t(btnU_pedge[2]), .q(set_mode));
    
//    mux_2_1d mux1(.d0(btnU_pedge[0]), .d1(clk_sec), .s(set_mode), .f(w1));
//    mux_2_1d mux2(.d0(btnU_pedge[1]), .d1(clk_min), .s(set_mode), .f(w2));
    
//    counter_dec_60 counter_sec(clk, reset_p, w1, sec1, sec10);
//    counter_dec_60 counter_min(clk, reset_p, w2, min1, min10);
    
//    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value({min10, min1, sec10, sec1}),.seg_7_ca(seg_7), .com(com));
//endmodule


module loadable_watch( //엣지받고 값까지만 만들어주는 모듈
    input clk, reset_p,
    input [2:0]btn_pedge,
    output [15:0] value
);

    wire clk_usec, clk_msec, clk_sec, clk_min;
    wire sec_edge, min_edge;
    wire set_mode;
    wire cur_time_load_en, set_time_load_en;
    wire [3:0] cur_sec1, cur_sec10, set_sec1, set_sec10;
    wire [3:0] cur_min1, cur_min10, set_min1, set_min10;
    wire [15:0] cur_time, set_time;     
    
    clock_usec usec_clk(clk, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk, reset_p, clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk, reset_p, clk_msec, clk_sec);
    clock_min min_clk(clk, reset_p, sec_edge, clk_min);
    
    loadable_counter_dec_60 cur_time_sec(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec),
                .load_enable(cur_time_load_en), .set_value1(set_sec1), .set_value10(set_sec10),
                .dec1(cur_sec1), .dec10(cur_sec10));
    loadable_counter_dec_60 cur_time_min(.clk(clk), .reset_p(reset_p), .clk_time(clk_min),
                .load_enable(cur_time_load_en), .set_value1(set_min1), .set_value10(set_min10),
                .dec1(cur_min1), .dec10(cur_min10));
                
    loadable_counter_dec_60 set_time_sec(.clk(clk), .reset_p(reset_p), .clk_time(btn_pedge[1]),
                .load_enable(set_time_load_en), .set_value1(cur_sec1), .set_value10(cur_sec10),
                .dec1(set_sec1), .dec10(set_sec10));
    loadable_counter_dec_60 set_time_min(.clk(clk), .reset_p(reset_p), .clk_time(btn_pedge[2]),
                .load_enable(set_time_load_en), .set_value1(cur_min1), .set_value10(cur_min10),
                .dec1(set_min1), .dec10(set_min10));
    
    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
    assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
    
    assign value = set_mode ? set_time : cur_time;   

    T_flip_flop_p tff_setmode(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(set_mode));
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), 
                 .cp(set_mode), .n_edge(cur_time_load_en), .p_edge(set_time_load_en));
    
    assign sec_edge = set_mode ? btn_pedge[1] : clk_sec;
    assign min_edge = set_mode ? btn_pedge[2] : clk_min;
    
endmodule

module loadable_watch_top(
    input clk, reset_p,
    input [2:0] btn,
    output [3:0] com,
    output [7:0] seg_7);
 
    wire [15:0] value;
    wire [2:0] btn_pedge;                                                                      
  
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
   
    loadable_watch watch(clk, reset_p, btn_pedge, value);
   
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
    
endmodule


module stop_watch_csec(
    input clk, reset_p,
    input [2:0] btn_pedge,
    output [15:0]value);
    
    wire clk_usec, clk_msec, clk_csec, clk_sec;
    wire start_stop;
    wire clk_start;
    wire [3:0] csec1, csec10, sec1, sec10;
    wire lap_swatch, lap_load;
    reg [15:0] lap_time;
    wire [15:0] cur_time;
    
    clock_usec usec_clk(clk_start, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk_start, reset_p, clk_usec, clk_msec);
    clock_div_10 csec_clk(clk_start, reset_p, clk_msec, clk_csec);
    clock_div_1000 sec_clk(clk_start, reset_p, clk_msec, clk_sec);
    
    T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop));
    
    assign clk_start = start_stop ? clk : 0;
    
    counter_dec_100 counter_csec(clk, reset_p, clk_csec, csec1, csec10);
    counter_dec_60 counter_sec(clk, reset_p, clk_sec, sec1, sec10);
    
    T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_pedge[1]), .q(lap_swatch));
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch), .p_edge(lap_load));
    
    assign cur_time = {sec10, sec1, csec10, csec1};
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)lap_time = 0;
        else if(lap_load)lap_time = cur_time;
    end
    
    assign value = lap_swatch ? lap_time : cur_time;

endmodule

module cook_timer(
    input clk, reset_p, 
    input [3:0] btn_pedge,
    output [15:0]value,
    output [5:0] led,
    output buzz_clk
    );
 
    reg alarm;
    wire btn_start, inc_sec, inc_min, alarm_off; //버튼 0번 1번 2번 3번
    wire [3:0] set_sec1, set_sec10, set_min1, set_min10; 
    wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10; 
    wire load_enable, dec_clk, clk_start; //clk_start : start했을 때만 클럭이 나오도록 함 
    reg start_stop;  
    wire [15:0]cur_time, set_time; 
    wire timeout_pedge;
    reg time_out; 
    
    assign {alarm_off, inc_min, inc_sec, btn_start} = btn_pedge;
    
    assign led[5] = start_stop; 
    assign led[4] = time_out; 
  
    assign clk_start = start_stop ?  clk : 0; //start(1) ->clk, stop(0) -> 0
    //모듈의 입출력 변수 명을 생략할 수 있음 대신 순서는 맞춰야함 .을 찍으면 순서 바꿔도 상관없음 
    ////////////////////////////////////////////////////
    clock_usec usec_clk(clk_start, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    clock_div_1000 msec_clk(clk_start,reset_p,clk_usec, clk_msec); //m clock //clk_start로 동작하게끔 함 
    clock_div_1000 sec_clk(clk_start,reset_p,clk_msec, clk_sec); //

//버튼 입력을 받는 count
    counter_dec_60 set_sec( clk, reset_p,inc_sec  ,set_sec1, set_sec10); 
    counter_dec_60 set_min( clk, reset_p,inc_min ,set_min1, set_min10); 
    
    //start or stop 상태 표현 tff
 //   T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_start), .q(start_stop)); 
     always @ (posedge clk or posedge reset_p)begin 
         if(reset_p) start_stop = 0; 
         else begin 
         if(btn_start) start_stop = ~start_stop; //start or stop 
        else if(timeout_pedge) start_stop = 0; //현재 시간이 0000이면 stop이 되도록 함 //1msec하고도 1클럭 후에 0이 됨 
      end
     end
 
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable)); //t-ff나올 때니까 posedge일 때 잡아야함 button이 아니니까 nedge잡으면 안됨 
    
 //스타트할 때 settime을 load해야함 load_enable그 엣지 잡아서 넣으면됨 
loadable_down_counter_dec_60 cur_sec(.clk(clk),  //1초 다운 카운터 
                           .reset_p(reset_p), 
                            .clk_time(clk_sec), 
                            .load_enable(load_enable), 
                            .set_value1(set_sec1), 
                            .set_value10(set_sec10),
                            .dec1(cur_sec1), 
                            .dec10(cur_sec10), 
                            .dec_clk(dec_clk)); 
    
loadable_down_counter_dec_60 cur_min(.clk(clk), //1분 다운 카운터 
                            .reset_p(reset_p), 
                            .clk_time(dec_clk),
                            .load_enable(load_enable),  //dec_clk을 받을 때마다  하나씩 깎음 
                            .set_value1(set_min1), 
                            .set_value10(set_min10), 
                            .dec1(cur_min1), 
                            .dec10(cur_min10));
    

  
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) time_out =0; 
        else begin                                  //time_out =0 //0000초 
            if(start_stop &&clk_msec && cur_time ==0) time_out = 1; //start_stop 1, cut_time 0 이 되면 1msec 후에 time_out이 1이됨 그 엣지가지고 start_stop이 0이됨 ㅇ
            else  time_out = 0; //1msec에 한번씩 time_out을 0으로 clear 
        end
    end 

    edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(time_out), .p_edge(timeout_pedge));  //time_out이 현재시간이 0일 때 1이됨 -> 그 타이밍이 timeout_pedge
    
//상승엣지 잡아서 1씩 깎음 스타트 상태에서 깎음 
 
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p)begin
            alarm  = 0;
        end
        else begin
            if(timeout_pedge) alarm = 1; 
            else if(alarm && alarm_off)alarm =0; 
        end
    end
    assign led[0] = alarm;

    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1}; //현재 시간 
    assign set_time ={set_min10, set_min1, set_sec10, set_sec1};
    assign value = start_stop ? cur_time : set_time; 
   
    reg[16:0] clk_div = 0; 
    always @(posedge clk)clk_div = clk_div +1; 
    
    assign buzz_clk = alarm ? clk_div[14] :0;  //13은 8000~9000h정도  된다. 

endmodule


///////////////////////////// 주방 카운터 /////////////////////////////
module cook_timer_top(
    input clk, reset_p, 
    input [3:0] btn,
    output [3:0] com, 
    output [7:0] seg_7,
    output [5:0] led,
    output buzz_clk
   // output [15:0]value
   );
    
    wire [15:0]value;
    wire btn_start, inc_sec, inc_min, alarm_off;
    wire [3:0] btn_pedge;
        
    button_cntr btn_cntr0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0])); //wire 이름만 btn_pedge 실제로는 n edge뽑아냄 
    button_cntr btn_cntr1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn_cntr2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
    button_cntr btn_cntr3 (.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btn_pedge[3]));
   
    cook_timer cook(clk, reset_p, btn_pedge,value,led, buzz_clk);
        
    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value),
        .seg_7_an(seg_7), .com(com)); 

endmodule

module multipurpose_clock(//다목적 시계_과제
    input clk, reset_p,
    input [4:0]btn,
    output [3:0] com,
    output [7:0] seg_7,
    output [2:0]debug_led,
    output [5:0]led
   );
    
    wire [4:0]btn_pe;
    reg [2:0]mode;
   
   assign debug_led = mode;
   
    always @(posedge clk or posedge reset_p)begin //링카운터 : 모드 버튼을 누르면 001->010->100
        if(reset_p)begin 
            mode =3'b001;
        end 
        else begin 
            if (btn_pe[0]) begin
                if (mode ==3'b001) mode=3'b010;
                else if(mode == 3'b010) mode=3'b100;
                else if(mode == 3'b100) mode=3'b001;
            end 
        end
    end   
    
    wire [15:0] value_watch, value_stop, value_cook;
    
    reg [2:0]btn_watch;
    reg [2:0]btn_stop;
    reg [3:0]btn_cook;    
  
    wire buzz_clk;

    
    watch_top watch(.clk(clk), .reset_p(reset_p),.btn(btn_watch),.value(value_watch)); //시계
    stop_watch_top stop_watch(.clk(clk), .reset_p(reset_p),.btn(btn_stop), .value(value_stop)); //스톱워치
    cook_timer cook_timer(.clk(clk), .reset_p(reset_p),.btn(btn_cook),.led(led),.value(value_cook)); //주방타이머
    
    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pe[0])); //모드 변경

        
    reg [15:0]value_select;
    reg [3:0]btn_select;
   
    always@(posedge clk or posedge reset_p) begin //먹스 : 모드에 따라 나오는 FND화면이 다르게 한다.
        if(reset_p) begin end
        else begin 
            case(mode)
                3'b001: begin 
                    value_select= value_watch;
                    btn_watch=btn[3:1];
                    btn_stop=0;
                    btn_cook=0;
               end//시계
                3'b010: begin 
                    value_select= value_stop; 
                    btn_watch=0;
                    btn_stop=btn[3:1];
                    btn_cook=0;
                end//스톱워치
                3'b100: begin 
                    value_select= value_cook; 
                    btn_watch=0;
                    btn_stop=0;
                    btn_cook=btn[4:1];
                end//주방타이머
            endcase
        end
    end
    
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value_select), .seg_7_an(seg_7), .com(com));
    
endmodule

module multy_purpose_watch( //교수님꺼 베껴
    input clk, reset_p,
    input [4:0] btn,
    output [3:0]com,
    output [7:0]seg_7,
    output [5:0]led,
    output buzz_clk,
    output [2:0]debug_led);
   
    ///가독성, 코드공유를 위한 파라미터
    parameter watch_mode = 3'b001;
    parameter stop_watch_mode = 3'b010;
    parameter cook_timer_mode= 3'b100;
        
    wire [2:0] watch_btn, stopw_btn;
    wire [3:0] cook_btn;
    wire [15:0] value, watch_value, stop_watch_value, cook_timer_value;
    reg [2:0] mode;
    wire btn_mode;
    wire [3:0] btn_pedge;
    
    assign debug_led= mode;
    
    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
    button_cntr btn3(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btn_pedge[3]));
    button_cntr btn4(.clk(clk), .reset_p(reset_p), .btn(btn[4]), .btn_pe(btn_mode));
    
    always@(posedge clk or posedge reset_p) begin
        if(reset_p) mode = watch_mode;
        else if(btn_mode) begin
            case(mode)
                watch_mode : mode = stop_watch_mode;
                stop_watch_mode : mode = cook_timer_mode;
                cook_timer_mode : mode = watch_mode;            
                default : mode = watch_mode;
            endcase
        end
    end

    ///한곳의 여러비트에 버튼입력을 부여하기 위하여
    assign {watch_btn, stopw_btn,cook_btn} = (mode == cook_timer_mode) ? {7'b0, btn_pedge[2:0]} : // {...} = 총 10bit
                                             (mode == stop_watch_mode) ? {4'b0, btn_pedge[2:0], 3'b0}: {btn_pedge[3:0], 6'b0};                                          
    
    loadable_watch  watch(clk, reset_p, watch_btn, watch_value);
    stop_watch_csec stop(clk, reset_p, stopw_btn, stop_watch_value );
    cook_timer       cook(clk, reset_p, cook_btn, cook_timer_value, led, buzz_clk );
    
    assign value= (mode == cook_timer_mode) ? cook_timer_value :
                  (mode == stop_watch_mode) ? stop_watch_value : watch_value;                                          
    
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
    
endmodule

module clock(
    input clk, reset_p,
    output clk_usec,clk_msec, clk_csec, clk_sec, clk_min    
    );

   clock_usec usec_clk(clk,reset_p,clk_usec);
   clock_div_1000 msec_clk(clk, reset_p,clk_usec,clk_msec);
   clock_div_10 csec_clk(clk, reset_p, clk_msec, clk_csec);
   clock_div_1000 sec_clk(clk, reset_p,clk_msec,clk_sec);
   clock_min min_clk(clk, reset_p,clk_sec, clk_min);

endmodule

module clock_top(
    input clk, reset_p,
    input [1:0]btn,
    output [1:0]debug_led,
    output [3:0]com,
    output [7:0] seg_7
    );
     
   wire clk_start;
   wire btn_start;
   wire start_stop;
   reg [1:0] mode;
   wire [15:0] value;
   wire [3:0] min10, min1, sec10, sec1, csec10, csec1;
   
   assign debug_led[0]= mode;
   assign debug_led[1] = start_stop;
        
   button_cntr mode_set(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_mode));
   button_cntr start_set(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_start));
   
   always@(posedge clk or posedge reset_p)begin
    if(reset_p) begin 
        mode=0;
    end
    else if (btn_mode) begin
        case(mode)
            0: mode=1;
            1: mode=0;
        endcase
    end
   end
      
   T_flip_flop_p tff(.clk(clk), .reset_p(reset_p), .t(btn_start), .q(start_stop)); 
   
   assign clk_start = start_stop? clk :0;
  
   clock clock(clk_start, reset_p, clk_usec, clk_msec, clk_csec, clk_sec, clk_min);
   
    counter_dec_100 counter_csec(clk, reset_p, clk_csec, csec1, csec10);
    counter_dec_60   counter_sec(clk, reset_p, clk_sec, sec1, sec10);
    counter_dec_60   counter_min(clk, reset_p, clk_min, min1, min10);
    
    wire [15:0] csec_value,sec_value; 
    
    assign csec_value = {sec10, sec1, csec10, csec1};
    assign sec_value  = {min10, min1, sec10, sec1};
   
   assign value = (mode == 1) ? sec_value : csec_value;
               
   fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
    
endmodule

module dht11_top(
    input clk, reset_p,
    inout dht11_data,
    output [3:0]com,
    output [7:0] seg_7,
    output [7:0]led_bar
    );
    
    wire[7:0] humidity, temperature;
    
    dht11 (clk, reset_p,dht11_data,humidity, temperature, led_bar);
    
    wire[15:0] bcd_humi, bcd_tmpr;
    bin_to_dec humi(.bin({4'b0000, humidity}),.bcd(bcd_humi));
    bin_to_dec tmpr(.bin({4'b0000, temperature}),.bcd(bcd_tmpr));
    
    wire [15:0] value;
    assign value ={bcd_humi[7:0], bcd_tmpr[7:0]};
    //assign value={humidity, temperature};
    
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
endmodule

module ultrasonic_top(
    input clk, reset_p,
    output trig,
    input echo,
    output [3:0]com,
    output [7:0] seg_7,
    output [2:0]led_bar
);
     wire [11:0]distance;
    wire [15:0] value;

    ultrasonic DUT(
        .clk(clk), .reset_p(reset_p),
        .echo(echo),
        .trig(trig),
        .distance(distance),
        .led_bar(led_bar)        
    );
    
    bin_to_dec humi(.bin(distance),.bcd(value));
       
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
    

endmodule

module led_pwm_top(
    input clk, reset_p,
    output [2:0]led_pwm
);

    reg [27:0] clk_div = 0;
    always@(posedge clk) clk_div =clk_div+1;
    
    pwm_100pc r(.clk(clk),
              .reset_p(reset_p),
              .duty(clk_div[27:21]),
              .pwm_freq(10_000),
              .pwm_100pc(led_pwm[0])
              );
              
    pwm_100pc g(.clk(clk),
              .reset_p(reset_p),
              .duty(clk_div[26:20]),
              .pwm_freq(10_000),
              .pwm_100pc(led_pwm[1])
              );

    pwm_100pc b(.clk(clk),
              .reset_p(reset_p),
              .duty(clk_div[27:21]),
              .pwm_freq(10_000),
              .pwm_100pc(led_pwm[2])
              );
endmodule 


module dc_motor_pwm_top(
    input clk, reset_p,
    output motor_pwm
);
    reg [29:0] clk_div;
    always @(posedge clk) clk_div = clk_div+1;
    
    
    pwm_128step pwm_motor(.clk(clk),.reset_p(reset_p),.duty(clk_div[29:23]),.pwm_freq(1_00),.pwm_128(motor_pwm));


endmodule















