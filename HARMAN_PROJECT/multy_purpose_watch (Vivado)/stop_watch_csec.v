
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

    //동작
    // start_stop을 1로 만들면서(btn[1]을 누르면서) '초: 밀리초' 로 FND에 출력하면서 현재 시간이 흘러간다.
    //btn[1]을 누르면 start_stop이 토글 되고 btn[2]를 누르면 lap_swatch 또한 토글 된다.
    // lap_swatch가 1이 되는 순가 lap_load라는 엣지가 발생되면 그 순간 lap_time에 cur_time을 저장하고 lap_time을 FND에 출력한다.
    // btn[2]을 눌러 lap_time을 0으로 만들면 안보이지만 흘러가던 cur_time이 출력된다.
    
    clock_usec usec_clk(clk_start, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk_start, reset_p, clk_usec, clk_msec);
    clock_div_10 csec_clk(clk_start, reset_p, clk_msec, clk_csec);
    clock_div_1000 sec_clk(clk_start, reset_p, clk_msec, clk_sec);
    
    T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[1]), .q(start_stop));
    
    assign clk_start = start_stop ? clk : 0;
    
    counter_dec_100 counter_csec(clk, reset_p, clk_csec, csec1, csec10);
    counter_dec_60 counter_sec(clk, reset_p, clk_sec, sec1, sec10);
    
    T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_pedge[2]), .q(lap_swatch));
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch), .p_edge(lap_load));
    
    assign cur_time = {sec10, sec1, csec10, csec1};
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)lap_time = 0;
        else if(lap_load)lap_time = cur_time;
    end
    
    assign value = lap_swatch ? lap_time : cur_time;

endmodule
