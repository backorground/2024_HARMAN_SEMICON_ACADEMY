
 module fnd_4digit_cntr(
    input clk, reset_p,
    input [15:0] value,
    output [7:0] seg_7_an, seg_7_ca,
    output [3:0] com);
    
    reg [3:0] hex_value;
    
     ring_counter_fnd rc(.clk(clk), .reset_p(reset_p), .com(com));
  
   always@(posedge clk) begin
      case(com)
         4'b0111: hex_value = value[15:12];
         4'b1011: hex_value = value[11:8];
         4'b1101: hex_value = value[7:4];
         4'b1110: hex_value = value[3:0];
      endcase
      end
 
   decoder_7seg (.hex_value(hex_value), .seg_7(seg_7_an));
   assign seg_7_ca = ~seg_7_an;
    
 endmodule
