
module dc_motor_speed(
    input clk, reset_p,
    input btn,
    input motor_off,
    input [11:0]distance,
    output reg motor_pwm_o,
    output reg [2:0]motor_led,
    output reg motor_sw
);
    wire [1:0]motor_pwm;
    reg [27:0] clk_div = 0;
    always@(posedge clk) clk_div =clk_div+1;
  
    pwm_100pc_sf led0(.clk(clk), //1단
              .reset_p(reset_p),
              .duty(25),
              .pwm_freq(1_00),
              .pwm_100pc(motor_pwm[0])
              );
  
    pwm_100pc_sf led1(.clk(clk), //2단
              .reset_p(reset_p),
              .duty(45),
              .pwm_freq(1_00),
              .pwm_100pc(motor_pwm[1])
              );
  
    wire btn_pedge;
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge));
    reg [1:0]cnt_btn; //0,1,2,3 -> 꺼짐, 1,2,3단계 밝기
   
  always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            cnt_btn =0;
        end
        else if(btn_pedge) begin cnt_btn= cnt_btn+1; end
        else if(motor_off) begin cnt_btn=0; end
        else if(distance>=11'h20) begin cnt_btn = 0; end
    end
  
    always@(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            motor_pwm_o =0;
            motor_sw = 0;
        end
        else begin
            case(cnt_btn)
                2'b00: begin motor_pwm_o = 0;               motor_sw =0;      motor_led=3'b000; end
                2'b01: begin motor_pwm_o = motor_pwm[0];    motor_sw =1;      motor_led=3'b001; end
                2'b10: begin motor_pwm_o = motor_pwm[1];    motor_sw =1;      motor_led=3'b010; end
                2'b11: begin motor_pwm_o = 1;               motor_sw =1;      motor_led=3'b100; end
            endcase
        end
    end
  
endmodule
