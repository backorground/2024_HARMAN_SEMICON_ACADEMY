
module counter_dec_60(
    input clk, reset_p, 
    input clk_time, 
    output reg [3:0] dec1, dec10);
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
        end 
        else begin 
            if(clk_time) begin 
                if(dec1 >= 9) begin 
                   dec1 = 0; //초의 두자리 중 일의자리에서 9가 되면 0이된다. 
                   if(dec10 >= 5) dec10 =0; //십의자리에서 5다음에는 0이 되야 함 
                   else dec10 = dec10 + 1; 
                 end 
              else dec1 = dec1 + 1; //초 클럭 받고 들어올 때마다 증가시키는 dec1은 초 두자리 중에 1의 자리를 증가시킴 
             end
        end 
            
        end
endmodule


module counter_dec_100 (
   input clk, reset_p,
   input clk_time,
   output reg [3:0] dec1, dec10);
   
   always @(posedge clk or posedge reset_p) begin
      if(reset_p) begin
         dec1=0;
         dec10=0;
      end
      else begin
         if(clk_time) begin
            if(dec1>= 9) begin
               dec1=0;
               if(dec10 >=5) dec10=0;
               else dec10 = dec10+1;
            end
            else dec1= dec1+1;
         end
      end
   end

endmodule
