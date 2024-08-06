
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
    
    T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[1]), .q(start_stop));
    
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
