
module button_cntr(
    input clk, reset_p,
    input btn,
    output btn_pe, btn_ne);

    reg [16:0] clk_div = 0;
    wire clk_div_16;
    reg [3:0]debounced_btn;
    
    always @(posedge clk) clk_div = clk_div + 1;
    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16));
        
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) debounced_btn = 0;
        else if(clk_div_16) debounced_btn = btn;
    end
    edge_detector_n ed2(.clk(clk), .reset_p(reset_p), 
                        .cp(debounced_btn), .p_edge(btn_pe), .n_edge(btn_ne));
    
endmodule
