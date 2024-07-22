module fan_top(
    input clk, reset_p,
    input [3:0]btn, // LED 밝기, 바람 세기, 타이머 버튼으로 3개
    input echo,
    output led_pwm_o, motor_pwm_o,//LED 밝기, 모터의 output
    output [3:0]com,
    output [7:0]seg_7,
    output [2:0]motor_led,timer_led,
    output trigger,
    output sg90
    );
    wire [11:0] distance;
    wire motor_off, motor_sw;
  
    led_brightness led_brightness(.clk(clk), //LED밝기 모듈
                                  .reset_p(reset_p),
                                  .btn(btn[0]),
                                  .led_pwm_o(led_pwm_o)); //JA1
  
    dc_motor_speed dc_motor_speed(.clk(clk), //모터 스피드 모듈
                                  .reset_p(reset_p),
                                  .motor_off(motor_off),
                                  .distance(distance),
                                  .btn(btn[1]),
                                  .motor_pwm_o(motor_pwm_o),
                                  .motor_led(motor_led),
                                  .motor_sw(motor_sw)); //JA2
  
    fan_timer fan_timer( .clk(clk),
                         .reset_p(reset_p),
                         .motor_sw(motor_sw),
                         .btn_str(btn[2]),
                         .motor_off(motor_off),
                         .timer_led(timer_led),
                         .com(com),
                         .seg_7(seg_7));
  
    ultra_sonic_prof ult(clk, reset_p, echo, trigger, distance);
  
    servomotor servo(.clk(clk), .reset_p(reset_p), .btn_str(btn[3]), .motor_sw(motor_sw), .sg90(sg90));
  
endmodule
