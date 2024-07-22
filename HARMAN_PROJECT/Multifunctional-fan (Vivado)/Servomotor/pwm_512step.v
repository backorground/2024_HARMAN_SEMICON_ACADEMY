
module pwm_512step(   // duty비를 512 단계로 제어하는 모듈
    input clk, reset_p,
    input [8:0] duty,
    input [13:0] pwm_freq,  // 주파수
    output reg pwm_512);
    
    parameter sys_clk_freq = 100_000_000;   // basys 100_000_000, cora 125_000_000
    
    integer cnt;
    reg pwm_freqX512;
    
    wire [26:0] temp;
    assign temp = sys_clk_freq / pwm_freq; 
    
  always @(posedge clk, posedge reset_p) begin    // 512 분주
        if(reset_p) begin
            pwm_freqX512 = 0;
            cnt = 0;
        end
        else begin    // if cnt가 5면  000_0000_0000_0000_0000_0000_0000
            if(cnt >= temp[26:9] - 1) cnt = 0;   // 7번 우시프트
            else cnt = cnt + 1;
            
            if(cnt < temp[26:10]) pwm_freqX512 = 0;
            else pwm_freqX512 = 1;
        end
    end
    
    wire pwm_freqX512_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX512), .n_edge(pwm_freqX512_nedge));
    
    reg [8:0] cnt_duty;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
           cnt_duty = 0;
           pwm_512 = 0; 
        end
        else begin
            if(pwm_freqX512_nedge) begin
                cnt_duty =  cnt_duty + 1;
                
                if(cnt_duty < duty) pwm_512 = 1;
                else pwm_512 = 0;
            end
            else begin
            end
        end
    end
endmodule
