
module cook_timer (
    input clk, reset_p,
    input [3:0] btn,
    output [3:0] com,
    output [7:0] seg_7);

    //동작
    //start_stop=0일 때는 set_time 상태를 출력하고 있다.
    //btn[1]과 btn[2]을 눌러 초와 분을 세팅한다.
    //btn[0]을 눌러 세팅한 시간만큼 타이머가 작동한다.
    //설정한 시간이 지나 알람이 울리면 btn[3]을 눌러 알람을 끈다. 
   
   wire btn_start, inc_sec, inc_min, alarm_off; 
   wire [3:0] set_sec1, set_sec10, set_min1, set_min10;
   wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10;
   wire load_enable, dec_clk, clk_start;
   wire load_enable;
   reg start_stop;
   wire [15:0]value, cur_time, set_time;

   clock_usec usec_clk(clk_start,reset_p,clk_usec);
   clock_div_1000 msec_clk(clk_start, reset_p,clk_usec,clk_msec);
   clock_div_1000 sec_clk(clk_start, reset_p,clk_msec, clk_sec);
   
   button_cntr btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]),.btn_ne(btn_start));
   button_cntr btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]),.btn_ne(inc_sec)); //초 증가
   button_cntr btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]),.btn_ne(inc_min)); //분 증가
   button_cntr btn3(.clk(clk), .reset_p(reset_p),.btn(btn[3]),.btn_ne(alarm_off));
   
   counter_dec_60 set_sec(clk, reset_p, inc_sec, set_sec1, set_sec10);
   counter_dec_60 set_min(clk, reset_p, inc_min, set_min1, set_min10);
   
   
   loadable_down_counter_dec_60 cur_sec(clk, reset_p,clk_sec,load_enable,set_sec1, set_sec10, cur_sec1, cur_sec10 ,dec_clk);
   loadable_down_counter_dec_60 cur_min(clk, reset_p,dec_clk,load_enable,set_min1, set_min10, cur_min1, cur_min10 );
    
    always@(posedge clk or posedge reset_p) begin
        if(reset_p) start_stop = 0;
        else begin
            if(btn_start) start_stop= ~start_stop;
            else if(timeout_pedge) start_stop =0;
        end
    end
    //T_flip_flop_p tff_start(clk, reset_p,btn_start, start_stop);
    edge_detector_n ed(clk, reset_p, start_stop, load_enable);
   
   reg time_out;
   always @(posedge clk or posedge reset_p) begin
    if(reset_p) time_out=0;
    else begin
        if(start_stop && clk_msec && cur_time ==0) time_out =1;
        else if( start_stop ==0 && clk_msec ) time_out=0; 
    end
   end
   wire timeout_pedge;
   edge_detector_n ed_timeout(clk, reset_p, time_out, timeout_pedge);
   reg alarm;
   always @(posedge clk or posedge reset_p) begin
    if(reset_p) begin
        alarm =0;
    end
    else begin
        if (timeout_pedge)alarm =1;
        else if (alarm && alarm_off) alarm =0;
        end
    end
  
   
   wire [15:0]value, cur_time, set_time;
   
   assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
   assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
   assign value= start_stop? cur_time: set_time;
   
   fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
endmodule
