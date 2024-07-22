
module servomotor(
    input clk, reset_p,
    input btn_str,
    input motor_sw,
    output sg90
);
    wire btn_pedge;
    button_cntr btn_cntr(.clk(clk), .reset_p(reset_p), .btn(btn_str), .btn_pe(btn_pedge));
    reg turn_on;
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)turn_on = 0;
        else if(btn_pedge)     begin turn_on = turn_on + 1; end
        else if(motor_sw == 0) begin turn_on = 0; end
    end
    reg [31:0] clk_div;
  
    always @(posedge clk)clk_div = clk_div + 1;
  
    wire clk_div_pedge;
    edge_detector_n ed0(.clk(clk), .reset_p(reset_p), .cp(clk_div[22]), .p_edge(clk_div_pedge));
    reg [8:0] duty;
    reg up_down;
  
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            duty = 14;
            up_down = 1;
        end
        else if(motor_sw)begin
            if(turn_on)begin
                if(clk_div_pedge)begin
                    if(duty >= 70)up_down = 0;
                    else if(duty <= 8)up_down = 1;
                    if(up_down)duty = duty + 1;
                    else duty = duty - 1;
                end
            end
        end
    end
    
    pwm_512step servo0(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_freq(50), .pwm_512(sg90));
  
endmodule
