
module clock_min( //1분에 한번씩 
   input clk, reset_p,
   input clk_sec,
   output clk_min);
   
   reg [4:0]cnt_sec;
   reg cp_min;
   
   always@(posedge clk or posedge reset_p) begin
      if(reset_p)  begin
         cnt_sec = 0;
         cp_min = 0;
      end
      else if (clk_sec) begin
         if (cnt_sec >= 29) begin
            cnt_sec =0;
            cp_min = ~cp_min;
         end
         else cnt_sec = cnt_sec +1; 
      end
   end
         
   edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_min), .n_edge(clk_min));
endmodule
