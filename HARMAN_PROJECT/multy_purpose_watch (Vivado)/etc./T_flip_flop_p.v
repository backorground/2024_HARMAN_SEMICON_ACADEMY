
module T_flip_flop_p(
   input clk, reset_p,
   input t,
   output reg q
   );

   always @(posedge clk or posedge reset_p) begin
      if (reset_p) begin q=0; end
      else begin 
         if(t) q=~q;
         else q=q;
      end
   end
endmodule
