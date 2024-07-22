
module pwm_100pc_sf(
    input clk, reset_p,
    input [6:0] duty, //내가 설정한 듀티 비
    input [13:0] pwm_freq,//내가 설정한 주파수
    output reg pwm_100pc //100까지 세야하므로 100배
);
    parameter sys_clk_freq = 100_000_000;    //cora 는 125_000_000
    
    integer cnt=0;
    reg pwm_freqX100=0;
    reg [6:0] cnt_duty=0;
    wire pwm_freq_nedge;
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX100), .n_edge(pwm_freq_nedge));
    
    always @(posedge clk or posedge reset_p) begin  //입력된 주파수를 가지는 느린 clk pulse 생성
        if(reset_p)begin
            pwm_freqX100 = 0;
            cnt = 0;
        end
        else begin
            if(cnt >= sys_clk_freq / pwm_freq / 100 -1) cnt =0;
            else cnt = cnt +1;
            
            if (cnt<sys_clk_freq / pwm_freq/ 100/ 2) pwm_freqX100=0;
            else pwm_freqX100 = 1;
        end
    end
    
    always @(posedge clk or posedge reset_p)begin //듀티 비 결정
        if(reset_p)begin
            cnt_duty = 0;
            pwm_100pc = 0;
        end
        else begin
                if(pwm_freq_nedge)begin
                    if(cnt_duty >= 99) cnt_duty = 0;
                    else cnt_duty = cnt_duty + 1;
                    if(cnt_duty < duty)pwm_100pc = 1;
                    else pwm_100pc = 0;
                end
        end
    end
endmodule
