
module clock_div_1000( //1000분주기 
   input clk, reset_p,
   input clk_source,
   output clk_div_1000);
   
   reg [9:0]cnt_clk_source;
   reg cp_div_1000;
   
   always@(posedge clk or posedge reset_p) begin
      if(reset_p)  begin
         cnt_clk_source = 0;
         cp_div_1000 = 0;
      end
      else if (clk_source) begin
         if (cnt_clk_source >= 499) begin
            cnt_clk_source =0;
            cp_div_1000 = ~cp_div_1000;
         end
         else cnt_clk_source = cnt_clk_source +1; 
      end
   end
   
   edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_div_1000), .n_edge(clk_div_1000));
endmodule
