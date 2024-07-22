
module sr04_div58(
    input clk, reset_p,
    input clk_usec, cnt_e,
    output reg [11:0] cm
    );    
    integer cnt;     
     always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            cm = 0;
            cnt = 0;
        end
        else begin
            if(cnt_e) begin 
                if(clk_usec)begin
                    cnt = cnt +1;
                    if(cnt >= 58) begin
                        cnt = 0;
                        cm = cm +1;
                    end               
                end     
            end    
        
            else begin
                cnt = 0;
                cm  = 0;
            end
        end    
      end               
endmodule
