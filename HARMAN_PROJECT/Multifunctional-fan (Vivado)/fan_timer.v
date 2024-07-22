module fan_timer(   //타이머
    input clk, reset_p,
    input btn_str,
    input motor_sw,
    output reg motor_off,
    output [3:0]com,
    output [7:0]seg_7,
    output reg [2:0]timer_led
    );
  
    wire btn_str_pedge, btn_str_nedge, btn_sw;
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn_sw), .btn_pe(btn_str_pedge), .btn_ne(btn_str_nedge));
   
    assign btn_sw = motor_sw ? btn_str : 0;
   
    wire btn_start, inc_sec, inc_min, alarm_off; //버튼 0번 1번 2번 3번
    wire [3:0] set_sec1, set_sec10, set_min1, set_min10;
    wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10;
    wire load_enable, dec_clk, clk_start; //clk_start : start했을 때만 클럭이 나오도록 함
    reg start_stop;
    wire [16:0]cur_time,cur_time_1;
    wire [15:0]set_time;
    wire timeout_pedge;
    reg time_out;
    reg motor_e;
    
    assign clk_start = start_stop ?  clk : 0;
    
    clock_usec usec_clk(clk_start, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk_start,reset_p,clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk_start,reset_p,clk_msec, clk_sec);
    
    reg [1:0]setting_state;
    reg [2:0]setting_time;
    
    always@(posedge clk or posedge reset_p) begin //1->3->5분->타이머 해제
        if(reset_p) begin
            setting_time=0;
            timer_led =0;
        end
        else begin
            case(setting_state)
                2'b00: begin setting_time=0; timer_led = 3'b000; motor_e = 1; end
                2'b01: begin setting_time=1; timer_led = 3'b001; motor_e = 0; end
                2'b10: begin setting_time=3; timer_led = 3'b010; motor_e = 0; end
                2'b11: begin setting_time=5; timer_led = 3'b100; motor_e = 0; end
            endcase
         end
    end
    
    always@(posedge clk or posedge reset_p) begin
        if(reset_p) setting_state=0;
        else if(btn_str_pedge) setting_state = setting_state + 1;
        else if(timeout_pedge) setting_state = 2'b00;
    end
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) time_out =0;
        else begin
            if(start_stop &&clk_msec && cur_time ==0) time_out = 1;
            else  time_out = 0;
        end
    end
    
    edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(time_out), .p_edge(timeout_pedge));
    
    always @ (posedge clk or posedge reset_p)begin
         if(reset_p) begin
             start_stop = 0;
             motor_off = 0 ;
         end
         else begin
         if(btn_str_pedge) start_stop = 0;
         else if (btn_str_nedge) start_stop = 1; //start or stop
         else if(timeout_pedge) begin
             start_stop = 0;
             motor_off = 1;
         end
         else motor_off = 0;
         end
     end
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable));
    
    loadable_downcounter_dec_60_fan cur_sec(.clk(clk),
                                            .reset_p(reset_p),
                                            .clk_time(clk_sec),
                                            .load_enable(load_enable),
                                            .dec1(cur_sec1),
                                            .dec10(cur_sec10),
                                            .dec_clk(dec_clk));
    loadable_downcounter_dec_60_fan cur_min(.clk(clk),
                                            .reset_p(reset_p),
                                            .clk_time(dec_clk),
                                            .load_enable(load_enable),
                                            .set_value1(setting_time),
                                            .dec1(cur_min1),
                                            .dec10(0));
    wire [16:0]value;
    
    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1, motor_e};
    assign cur_time_1 = setting_time ? cur_time : 0;
    assign value = start_stop ? cur_time_1 : 0;
    
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value[16:1]), .seg_7_an(seg_7), .com(com));
  
endmodule
