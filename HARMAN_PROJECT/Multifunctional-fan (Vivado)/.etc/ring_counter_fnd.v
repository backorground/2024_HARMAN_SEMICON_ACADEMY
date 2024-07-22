
module ring_counter_fnd(
    input clk, reset_p,
    output reg [3:0] com);
    
    reg [16:0] clk_div;
    wire clk_div_16;
    
    always @(posedge clk) clk_div = clk_div + 1;
    
    edge_detector_n ed (.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16));

    always @(posedge clk or posedge reset_p)begin
        if(reset_p) com = 4'b1110;
        else if(clk_div_16)begin
            case(com)
                4'b1110: com = 4'b1101;
                4'b1101: com = 4'b1011;
                4'b1011: com = 4'b0111;
                4'b0111: com = 4'b1110;
                default: com = 4'b1110;
            endcase
        end
    end

endmodule
