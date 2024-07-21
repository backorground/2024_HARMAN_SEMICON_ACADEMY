
module loadable_down_counter_dec_60(
        input clk, reset_p,
        input clk_time,
        input load_enable,
        input [3:0] set_value1, set_value10,
        output reg [3:0] dec1, dec10,
        output reg dec_clk
);
        always @(posedge clk or posedge reset_p)begin
                if(reset_p)begin
                        dec1 = 0;
                        dec10 = 0;
                        dec_clk=0;
                end
                else begin
                        if(load_enable)begin
                                dec1 = set_value1;
                                dec10 = set_value10;
                        end
                        else if(clk_time) begin
                                if(dec1 ==0)begin
                                        dec1 = 9;
                                        if(dec10 == 5)begin 
                                           dec10 = 5;
                                           dec_clk= 1;
                                        end
                                        else dec10 = dec10 - 1;
                                end
                                else dec1 = dec1 - 1;
                        end
                        else dec_clk=0;
               end
        end
endmodule
