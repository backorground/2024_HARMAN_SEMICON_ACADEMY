
module clock_usec(
    input clk, reset_p,
    output clk_usec
    );
    
    reg [7:0] cnt_sysclk; // 10ns
    wire cp_usec;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)cnt_sysclk = 0;
        else if(cnt_sysclk >= 99) cnt_sysclk = 0;
        else cnt_sysclk = cnt_sysclk + 1; 
    end
    
    assign cp_usec = (cnt_sysclk < 50) ? 0 : 1;
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), 
                        .cp(cp_usec), .n_edge(clk_usec));
    
endmodule
