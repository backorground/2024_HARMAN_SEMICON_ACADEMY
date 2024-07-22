
module led_brightness( //pull-up 저항으로 하자
    input clk, reset_p,
    input btn,
    output reg led_pwm_o
);
    wire [1:0]led_pwm;
    reg [27:0] clk_div = 0;
    always@(posedge clk) clk_div =clk_div+1;
    pwm_100pc_sf led0(.clk(clk), //1단
              .reset_p(reset_p),
              .duty(50),
              .pwm_freq(1_000_000),
              .pwm_100pc(led_pwm[0])
              );
    pwm_100pc_sf led1(.clk(clk), //2단
              .reset_p(reset_p),
              .duty(90),
              .pwm_freq(1_000_000),
              .pwm_100pc(led_pwm[1])
              );
    wire btn_pedge;
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge));
    reg [1:0]cnt_btn; //0,1,2,3 -> 꺼짐, 1,2,3단계 밝기
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            cnt_btn =0;
        end
        else if(btn_pedge) begin
            cnt_btn= cnt_btn+1;
        end
    end
    always@(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            led_pwm_o =0;
        end
        else begin
            case(cnt_btn)
                2'b00: begin led_pwm_o = 1; end
                2'b01: begin led_pwm_o = led_pwm[1]; end
                2'b10: begin led_pwm_o = led_pwm[0]; end
                2'b11: begin led_pwm_o = 0; end
            endcase
        end
    end
endmodule
