`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/27 12:03:09
// Design Name: 
// Module Name: controler
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


 
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

module key_pad_cntr(
   input clk, reset_p,
   input [3:0] row,
   output reg [3:0] col,
   output reg [3:0] key_value,
   output reg key_valid   
   );
    
   reg [19:0] clk_div;
   always @(posedge clk) clk_div = clk_div+1;
   wire clk_8msec_p, clk_8msec_n;
   
   edge_detector_n ed1(.clk(clk),.reset_p(reset_p), .cp(clk_div[19]), .p_edge(clk_8msec_p),.n_edge(clk_8msec_n));
   
   always @(posedge clk or posedge reset_p) begin
      if(reset_p) col =4'b0001;
      else if(clk_8msec_p  && !key_valid) begin
         case(col)
            4'b0001: col = 4'b0010;
            4'b0010: col = 4'b0100;
            4'b0100: col = 4'b1000;
            4'b1000: col = 4'b0001;
            default: col = 4'b0001;
            endcase
      end
   end
   
   always@(posedge clk, posedge reset_p) begin
      if(reset_p) begin
         key_value=0;
         key_valid=0;
      end
      else begin
        if(clk_8msec_n)begin
         if(row) begin
            key_valid =1;
            case ({col, row})
               8'b0001_0001: key_value= 4'h0 ;//0
               8'b0001_0010: key_value= 4'h1 ;//1
               8'b0001_0100: key_value= 4'h2 ;//2
               8'b0001_1000: key_value= 4'h3 ;//3  
               
               8'b0010_0001: key_value= 4'h4 ;//4
               8'b0010_0010: key_value= 4'h5 ;//5
               8'b0010_0100: key_value= 4'h6 ;//6
               8'b0010_1000: key_value= 4'h7 ;//7
               
               8'b0100_0001: key_value= 4'h8 ;//8
               8'b0100_0010: key_value= 4'h9 ;//9
               8'b0100_0100: key_value= 4'hA ;//10
               8'b0100_1000: key_value= 4'hb ;//11
               
               8'b1000_0001: key_value= 4'hC ;//12
               8'b1000_0010: key_value= 4'hD ;//13
               8'b1000_0100: key_value= 4'hE ;//14
               8'b1000_1000: key_value= 4'hF ;//15                                                  
            endcase            
         end
         else begin
            key_valid =0;
            key_value =0; //�������� Ű���� ���´�.
         end
      end
   end
 end
endmodule

module keypad_cntr_fsm( //FSM ������ ���¿��� ��� �Ǵ���
   input clk, reset_p,
   input [3:0] row,
   output reg [3:0] col,
   output reg [3:0] key_value,
   output reg key_valid);
   
   parameter SCAN_0     =5'b00001; //parameter ��� ����
   parameter SCAN_1     =5'b00010;
   parameter SCAN_2     =5'b00100;
   parameter SCAN_3     =5'b01000;
   parameter KEY_PROCESS=5'b10000; //<<�̷����ϸ� ȸ�ΰ� ��ī����ó�� ����ϰ� �������
   
   reg[2:0] state, next_state;
   
   always @* begin
      case(state)
         SCAN_0: begin
            if(row) next_state = KEY_PROCESS;
            else next_state=SCAN_1;
         end
         SCAN_1: begin
            if(row) next_state = KEY_PROCESS;
            else next_state=SCAN_2;
         end
         SCAN_2: begin
            if(row) next_state = KEY_PROCESS;
            else next_state=SCAN_3;
         end
         SCAN_3: begin
            if(row) next_state = KEY_PROCESS;
            else next_state=SCAN_0;
         end
         KEY_PROCESS:begin
            if (row) next_state = KEY_PROCESS;
            else next_state=SCAN_0;
         end
      endcase
   end
   
   reg [19:0] clk_div;
   always @(posedge clk) clk_div = clk_div +1;
   
   wire clk_8msec;
   edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[19]),.p_edge(clk_8msec));
   
   always @(posedge clk or posedge reset_p)begin
      if(reset_p) state = SCAN_0;
      else if(clk_8msec) state = next_state;
   end
   
   always @(posedge clk or posedge reset_p) begin
      if(reset_p) begin
         key_value =0;
         key_valid=0;
         col =4'b0000;   
      end
      else begin
         case(state)
            SCAN_0: begin col = 4'b0001; key_valid=0; end
            SCAN_1: begin col = 4'b0010; key_valid=0; end
            SCAN_2: begin col = 4'b0100; key_valid=0; end
            SCAN_3: begin col = 4'b1000; key_valid=0; end
            KEY_PROCESS: begin
               key_valid =1;
               case ({col, row})
               8'b0001_0001: key_value= 4'h0 ;//0
               8'b0001_0010: key_value= 4'h1 ;//1
               8'b0001_0100: key_value= 4'h2 ;//2
               8'b0001_1000: key_value= 4'h3 ;//3  
               
               8'b0010_0001: key_value= 4'h4 ;//4
               8'b0010_0010: key_value= 4'h5 ;//5
               8'b0010_0100: key_value= 4'h6 ;//6
               8'b0010_1000: key_value= 4'h7 ;//7
               
               8'b0100_0001: key_value= 4'h8 ;//8
               8'b0100_0010: key_value= 4'h9 ;//9
               8'b0100_0100: key_value= 4'hA ;//10
               8'b0100_1000: key_value= 4'hb ;//11
               
               8'b1000_0001: key_value= 4'hC ;//12
               8'b1000_0010: key_value= 4'hD ;//13
               8'b1000_0100: key_value= 4'hE ;//14
               8'b1000_1000: key_value= 4'hF ;//15                                                  
               endcase            
            end
            
         endcase
      end
   end
   
endmodule



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


module keypad_cntr_FSM(
    input clk, reset_p,
    input [3:0] row,
    output reg [3:0] col,
    output reg [3:0] key_value,
    output reg key_valid);

    parameter SCAN_0 =      5'b00001;
    parameter SCAN_1 =      5'b00010;
    parameter SCAN_2 =      5'b00100;
    parameter SCAN_3 =      5'b01000;
    parameter KEY_PROCESS = 5'b10000;
    
    reg [4:0] state, next_state;
    
    always @* begin
        case(state)
            SCAN_0: begin
                if(row == 0)next_state = 2;
                else next_state = KEY_PROCESS;
            end
            SCAN_1: begin
                if(row == 0)next_state = SCAN_2;
                else next_state = KEY_PROCESS;
            end
            SCAN_2: begin
                if(row == 0)next_state = SCAN_3;
                else next_state = KEY_PROCESS;
            end
            SCAN_3: begin
                if(row == 0)next_state = SCAN_0;
                else next_state = KEY_PROCESS;
            end
            KEY_PROCESS: begin
                if(row != 0)next_state = KEY_PROCESS;
                else next_state = SCAN_0;
            end
        endcase
    end
    
    reg [19:0] clk_div;
    always @(posedge clk) clk_div = clk_div + 1;
    wire clk_8msec;
    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[19]), 
        .p_edge(clk_8msec));
        
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)state = SCAN_0;
        else if(clk_8msec) state = next_state;
    end
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            key_value = 0;
            key_valid = 0;
            col = 4'b0001;
        end
        else begin
            case(state)
                SCAN_0:begin col = 4'b0001; key_valid = 0; end
                SCAN_1:begin col = 4'b0010; key_valid = 0; end
                SCAN_2:begin col = 4'b0100; key_valid = 0; end
                SCAN_3:begin col = 4'b1000; key_valid = 0; end
                KEY_PROCESS: begin
                    key_valid = 1;
                    case({col, row})
                        8'b0001_0001: key_value = 4'hd;     //0
                        8'b0001_0010: key_value = 4'hE;     //1
                        8'b0001_0100: key_value = 4'hb;     //2
                        8'b0001_1000: key_value = 4'hA;     //3
                        8'b0010_0001: key_value = 4'hF;     //4
                        8'b0010_0010: key_value = 4'h3;     //5
                        8'b0010_0100: key_value = 4'h6;     //6
                        8'b0010_1000: key_value = 4'h9;     //7
                        8'b0100_0001: key_value = 4'h0;     //8
                        8'b0100_0010: key_value = 4'h2;     //9
                        8'b0100_0100: key_value = 4'h5;     //A
                        8'b0100_1000: key_value = 4'h8;     //b
                        8'b1000_0001: key_value = 4'hC;     //C
                        8'b1000_0010: key_value = 4'h1;     //d
                        8'b1000_0100: key_value = 4'h4;     //E
                        8'b1000_1000: key_value = 4'h7;     //F
                    endcase
                end
            endcase
        end
    end 
    

endmodule

module T_flip_flop_p_cntr(
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

//module dht11(
//    input clk, reset_p,
//    inout dht11_data, //inout�� reg������ �ȵȴ�. input�� wire
//    output reg[7:0] humidity, temperature,
//    output [7:0] led_bar
//    );
    
//    parameter S_IDLE = 6'b000001;
//    parameter S_LOW_18MS = 6'b000010;
//    parameter S_HIGH_20US = 6'b000100;
//    parameter S_LOW_80US = 6'b001000;
//    parameter S_HIGH_80US = 6'b010000;
//    parameter S_READ_DATA = 6'b100000;
    
//    parameter S_WAIT_PEDGE = 2'b01;
//    parameter S_WAIT_NEDGE = 2'b10;
    
//    //us_����ũ�μ�ũ ī����(22bit)
//    reg[21:0] count_usec;
//    wire clk_usec;
//    reg count_usec_e;
//    clock_usec usec_clk(clk, reset_p, clk_usec);
    
//    assign led_bar[5:0] = state;
    
//    always @(negedge clk or posedge reset_p) begin
//        if(reset_p) count_usec = 0;
//        else begin //enable�� 1�� �� �ʸ� ī��Ʈ�ϴٰ� 0�̵Ǹ� 0���� �ʱ�ȭ�ϰ� ī��Ʈ�� �����. 
//            if(clk_usec && count_usec_e)count_usec = count_usec +1;
//            else if(!count_usec_e) count_usec =0;
//        end
//    end
    
//    wire dht_pedge, dht_nedge;
//    edge_detector_n ed(.clk(clk),.reset_p(reset_p),.cp(dht11_data),.p_edge(dht_pedge),.n_edge(dht_nedge));
    
//    reg [5:0] state, next_state;
//    reg [1:0] read_state;
    
//    always@(negedge clk or posedge reset_p) begin
//        if(reset_p) state = S_IDLE;
//        else state = next_state;
//    end    
    
//    reg [39:0] temp_data;
//    reg [5:0] data_count;
    
//    reg dht11_buffer;
//    assign dht11_data = dht11_buffer; //inout�� reg������ �ȵǼ� 1��Ʈ reg�ϳ� ���� �����Ϳ� �������ش�.
    
//    always @(posedge clk or posedge reset_p) begin
//        if(reset_p) begin
//            count_usec_e =0;
//            next_state = S_IDLE;
//            dht11_buffer = 1'bz; //���Ǵ���
//            read_state = S_WAIT_PEDGE;
//            data_count = 0;
            
//        end
//        else begin
//            case(state)
//                S_IDLE: begin
//                    if(count_usec <22'd3_000_000)begin
//                        count_usec_e =1;
//                        dht11_buffer = 1'bz;
//                    end
//                    else begin
//                        next_state = S_LOW_18MS;
//                        count_usec_e =0; //clear
//                    end
//                end
//                S_LOW_18MS: begin
//                    if(count_usec < 22'd20_000) begin
//                        count_usec_e =1;
//                        dht11_buffer =0;
//                    end
//                    else begin
//                        count_usec_e =0;
//                        next_state = S_HIGH_20US;
//                        dht11_buffer = 1'bz;
//                    end
//                end
//                S_HIGH_20US: begin
//                    count_usec_e =1;
//                    if(dht_nedge) begin
//                        next_state = S_LOW_80US;
//                        count_usec_e =0;
//                    end
//                    if(count_usec > 22'd20_000)begin
//                    dht11_buffer = 1'bz; 
//                /////////////
//                    if(dht_nedge) begin
//                            next_state = S_LOW_80US;
//                            count_usec_e =0;
               
//                    end
//                end
//                else begin
//                    next_state = S_HIGH_80US;
//                    end
//                end
//                S_LOW_80US: begin
//                if(count_usec <22'd20_000) begin
//                    count_usec_e =1;
//                    dht11_buffer = 1'bz; 
                
//                    if(dht_nedge) begin
//                            next_state = S_LOW_80US;
//                            count_usec_e =0;
               
//                    end
//                end
//                else begin
//                    next_state = S_HIGH_80US;
//                    end
//                end
//                 S_HIGH_80US: begin
//                    if(dht_nedge) begin
//                        next_state = S_READ_DATA;
//                    end
//                end
//                S_READ_DATA: begin
//                    case(read_state)
//                        S_WAIT_PEDGE: begin
//                            if(dht_pedge) begin
//                                read_state = S_WAIT_NEDGE;  
//                           end
//                           count_usec_e =0;
//                        end
//                        S_WAIT_NEDGE: begin
//                            if(dht_nedge) begin
//                                if(count_usec < 50) begin
//                                    temp_data = {temp_data[38:0], 1'b0};
//                                    end
//                                    else begin
//                                        temp_data ={temp_data[38:0], 1'b1};
//                                    end
//                                    data_count = data_count +1;
//                                    read_state = S_WAIT_PEDGE;
//                                 end
//                                 else begin
//                                    count_usec_e =1;
//                                 end
//                               end
//                            endcase
//                            if(data_count >= 40) begin
//                                data_count =0;
//                                next_state = S_IDLE;
//                                humidity = temp_data[39:32];
//                                temperature = temp_data[23:16];
//                            end
//                         end
//                        default: next_state = S_IDLE;
//            endcase
//        end 
//    end
    
//endmodule

 module dht11(
    input clk, reset_p,
    inout dht11_data, 
    output reg [7:0] humidity, temperature,
    output [7:0] led_bar);
    
    parameter S_IDLE = 6'b000001;
    parameter S_LOW_18MS = 6'b000010;
    parameter S_HIGH_20US = 6'b000100;
    parameter S_LOW_80US = 6'b001000;
    parameter S_HIGH_80US = 6'b010000;
    parameter S_READ_DATA = 6'b100000;
    
    parameter S_WAIT_PEDGE = 2'b01;
    parameter S_WAIT_NEDGE = 2'b10;
    
    reg [21:0] count_usec;
    wire clk_usec;
    reg count_usec_e;
    clock_usec usec_clk(clk, reset_p, clk_usec);
    
    
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)  count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e) count_usec = 0;
        end
    end
    
    wire dht_pedge, dht_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(dht11_data), .p_edge(dht_pedge), .n_edge(dht_nedge));
    
    reg [5:0] state, next_state;
    reg [1:0] read_state;
    
    assign led_bar[5:0] = state;
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = S_IDLE;
        else state = next_state;
    end
    
    reg [39:0] temp_data;
    reg [5:0] data_count;
    
    reg dht11_buffer;
    assign dht11_data = dht11_buffer;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec_e = 0;
            next_state = S_IDLE;
            dht11_buffer = 1'bz;
            read_state = S_WAIT_PEDGE;
            data_count = 0;
            
        end
        else begin
            case(state)
                S_IDLE:begin
                    if(count_usec < 22'd3_000_000)begin  //3_000_000
                        count_usec_e = 1;
                        dht11_buffer = 1'bz;
                    end
                    else begin
                        next_state = S_LOW_18MS;
                        count_usec_e = 0;
                    end
                end
                S_LOW_18MS:begin
                    if(count_usec < 22'd20_000)begin
                        count_usec_e =1;
                        dht11_buffer = 0;
                    end
                    else begin
                         count_usec_e = 0;
                         next_state = S_HIGH_20US;
                         dht11_buffer = 1'bz;
                    end
                end
                S_HIGH_20US:begin
                    count_usec_e = 1;
                    if(dht_nedge)begin
                        next_state = S_LOW_80US;
                        count_usec_e = 0;
                    end
                    if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                S_LOW_80US:begin
                    count_usec_e = 1;
                    if(dht_pedge)begin
                        next_state = S_HIGH_80US;
                        count_usec_e = 0;
                    end
                    if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                S_HIGH_80US:begin
                    count_usec_e = 1;
                    if(dht_nedge)begin
                        next_state = S_READ_DATA;
                        count_usec_e = 0;
                    end
                    if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                    
                end
                S_READ_DATA:begin
                    case(read_state)
                        S_WAIT_PEDGE:begin
                            if(dht_pedge)begin
                                read_state = S_WAIT_NEDGE;
                            end
                            count_usec_e = 0;
                        end
                        S_WAIT_NEDGE:begin
                            if(dht_nedge)begin
                                if(count_usec < 50)begin
                                    temp_data = {temp_data[38:0], 1'b0};
                                end
                                else begin
                                    temp_data = {temp_data[38:0], 1'b1};
                                end
                                data_count = data_count + 1;
                                read_state = S_WAIT_PEDGE;
                            end
                            else begin
                                count_usec_e = 1;
                            end
                        end
                    endcase
                    if(data_count >= 40)begin
                        data_count = 0;
                        next_state = S_IDLE;
                        humidity = temp_data[39:32];
                        temperature = temp_data[23:16];
                    end
   
                    if(count_usec > 22'd50_000)begin
                        data_count=0;
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                default:next_state = S_IDLE;
            endcase
        end
    end   
    
endmodule

module dht11_t(
    input clk, reset_p,
    inout dht11_data, 
    output reg [7:0] humidity, temperature,
    output [7:0] led_bar);
    
    parameter S_IDLE = 6'b000001;
    parameter S_LOW_18MS = 6'b000010;
    parameter S_HIGH_20US = 6'b000100;
    parameter S_LOW_80US = 6'b001000;
    parameter S_HIGH_80US = 6'b010000;
    parameter S_READ_DATA = 6'b100000;
    
    parameter S_WAIT_PEDGE = 2'b01;
    parameter S_WAIT_NEDGE = 2'b10;
    
    reg [21:0] count_usec;
    wire clk_usec;
    reg count_usec_e;
    clock_usec usec_clk(clk, reset_p, clk_usec);
    
    
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)  count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e) count_usec = 0;
        end
    end
    wire dht_pedge, dht_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(dht11_data), .p_edge(dht_pedge), .n_edge(dht_nedge));
    
    reg [5:0] state, next_state;
    reg [1:0] read_state;
    
    assign led_bar[5:0] = state;
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = S_IDLE;
        else state = next_state;
    end
    
    reg [39:0] temp_data;
    reg [5:0] data_count;
    
    reg dht11_buffer;
    assign dht11_data = dht11_buffer;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec_e = 0;
            next_state = S_IDLE;
            dht11_buffer = 1'bz;
            read_state = S_WAIT_PEDGE;
            data_count = 0;
            
        end
        else begin
            case(state)
                S_IDLE:begin
                    if(count_usec < 22'd3_000_000)begin  //3_000_000
                        count_usec_e = 1;
                        dht11_buffer = 1'bz;
                    end
                    else begin
                        next_state = S_LOW_18MS;
                        count_usec_e = 0;
                    end
                end
                S_LOW_18MS:begin
                    if(count_usec < 22'd20_000)begin
                        count_usec_e =1;
                        dht11_buffer = 0;
                    end
                    else begin
                         count_usec_e = 0;
                         next_state = S_HIGH_20US;
                         dht11_buffer = 1'bz;
                    end
                end
                S_HIGH_20US:begin
                    count_usec_e = 1;
                    if(dht_nedge)begin
                        next_state = S_LOW_80US;
                        count_usec_e = 0;
                    end
                    if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                S_LOW_80US:begin
                    count_usec_e = 1;
                    if(dht_pedge)begin
                        next_state = S_HIGH_80US;
                        count_usec_e = 0;
                    end
                    if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                S_HIGH_80US:begin
                    count_usec_e = 1;
                    if(dht_nedge)begin
                        next_state = S_READ_DATA;
                        count_usec_e = 0;
                    end
                    if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                    
                end
                S_READ_DATA:begin
                    case(read_state)
                        S_WAIT_PEDGE:begin
                            if(dht_pedge)begin
                                read_state = S_WAIT_NEDGE;
                            end
                            count_usec_e = 0;
                        end
                        S_WAIT_NEDGE:begin
                            if(dht_nedge)begin
                                if(count_usec < 45)begin
                                    temp_data = {temp_data[38:0], 1'b0};
                                end
                                else begin
                                    temp_data = {temp_data[38:0], 1'b1};
                                end
                                data_count = data_count + 1;
                                read_state = S_WAIT_PEDGE;
                            end
                            else begin
                                count_usec_e = 1;
                            end
                        end
                    endcase
                    if(data_count >= 40)begin
                        data_count = 0;
                        next_state = S_IDLE;
                        humidity = temp_data[39:32];
                        temperature = temp_data[23:16];
                    end
                    if(count_usec > 22'd50_000)begin
                        data_count = 0;
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                default:next_state = S_IDLE;
            endcase
        end
    end
    
    
    
    
    
endmodule


module ultrasonic( //FSM ����ϱ�
    //5V ���� 
    input clk, reset_p,
    input echo,
    output reg trig,
    output reg [11:0]distance ,  
    output [2:0]led_bar
);
    /////////////////
     
    parameter IDLE = 3'b001;
    parameter INITIATE = 3'b010;
    parameter ECHO_BACK = 3'b100;
    
    reg [2:0]state, next_state;
    reg cnt_e;
    wire [11:0]cm;

    reg [21:0] count_usec;
    wire clk_usec;
    reg count_usec_e;
    clock_usec usec_clk(clk, reset_p, clk_usec); //����ũ����
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) begin 
            count_usec = 0;
        end
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e) count_usec = 0;
        end
    end
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = IDLE;
        else state = next_state;
    end
    
    reg [11:0] echo_time;
    
    wire echo_pedge, echo_nedge;
    edge_detector_n ed1( .clk(clk),  .reset_p(reset_p), .cp(echo), .p_edge(echo_pedge), .n_edge(echo_nedge));  
    ///////////////////////
   
    
    sr04_div58 sr04(clk, reset_p,count_usec, cnt_e, cm);
    
    assign led_bar = state;
    
    always@(posedge clk or posedge reset_p) begin
        if(reset_p)begin
            next_state=IDLE;
            count_usec_e =0;
        end
        else begin
            case(state)
                IDLE : begin //10ms ���
                if(count_usec < 22'd500_000) begin //0.5�ʸ��� ����
                        count_usec_e=1;
                        trig=0;
                    end
                    else begin
                        next_state =INITIATE;
                        count_usec_e=0;
                    end    
    
                end
                INITIATE : begin //10us Ʈ���� �޽� �߻�
                    count_usec_e=1; /////////////////�� ������ȴ�/???
                    if(count_usec < 22'd10) begin //10us pulse
                        
                        trig=1;
                    end
                    else begin
                        next_state =ECHO_BACK;
                        count_usec_e=0;
                        trig=0;
                    end
                end 
               
                ECHO_BACK : begin //100us~18ms���� ���� �޽��� ���ƿ��� �ð��� �ν�
                    if(echo_pedge) begin
                        count_usec_e=1;
                        cnt_e=1;
                    end
                    if(echo_nedge) begin
                        //distance = count_usec/58; 
                        distance =cm;
                        next_state=IDLE;
                        count_usec_e = 0;
                        cnt_e=0;
                    end
//                    if(count_usec > 22'd40)begin
//                        next_state=IDLE;
//                        count_usec_e = 0;
//                    end
                 end
                 default : next_state =IDLE;
            endcase
        end
    end
    

//    always@(posedge clk or posedge reset_p/*sensitivity...~*/) begin
//        if(reset_p) distance=0;
//         else begin
         
                // distance = echo_time / 58;
                
//                if(echo_time < 58) distance = 0;
//                else if(echo_time < 116) distance = 1;
//                else if(echo_time < 174) distance = 2;
//                else if(echo_time < 232) distance = 3;
//                else if(echo_time < 290) distance = 4;
//                else if(echo_time < 348) distance = 5;
//                else if(echo_time < 406) distance = 6;
//                else if(echo_time < 464) distance = 7;
//                else if(echo_time < 522) distance = 8;
//                else if(echo_time < 580) distance = 9;
//                else if(echo_time < 638) distance = 10;
//                else if(echo_time < 696) distance = 11;
//                else if(echo_time < 754) distance = 12;
//                else if(echo_time < 812) distance = 13;
//                else if(echo_time < 870) distance = 14;
//                else if(echo_time < 928) distance = 15;
//                else if(echo_time < 986) distance = 16;
//                else if(echo_time < 1044) distance = 17;
//                else if(echo_time < 1102) distance = 18;
//                else if(echo_time < 1160) distance = 19;
//                else if(echo_time < 1218) distance = 20;
//                else if(echo_time < 1276) distance = 21;
//                else if(echo_time < 1334) distance = 22;
//                else if(echo_time < 1392) distance = 23;
//                else if(echo_time < 1450) distance = 24;
//                else if(echo_time < 1508) distance = 25;
//                else if(echo_time < 1566) distance = 26;
//                else if(echo_time < 1624) distance = 27;
//                else if(echo_time < 1682) distance = 28;
//                else if(echo_time < 1740) distance = 29;
//                else if(echo_time < 1798) distance = 30;
//        end
//    end
    
endmodule

module sr04_div58(
    input clk, reset_p,
    input clk_usec, cnt_e,
    output reg [11:0] cm
);

    integer cnt;

    always@(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            cm = 0;
            cnt = 0;
        end
        else begin
            if(cnt_e) begin
                if(clk_usec)begin
                    cnt = cnt + 1;
                    if(cnt>= 58) begin
                        cnt =0;
                        cm = cm+1;
                    end        
                end
            end
        else begin
            cnt =0;
            cm = 0;
        end     
      end
    end
endmodule

module pwm_100pc(
    input clk, reset_p,
    input [6:0] duty, //���� ������ ��Ƽ ��
    input [13:0] pwm_freq,//���� ������ ���ļ�
    output reg pwm_100pc //100���� �����ϹǷ� 100��
);
    parameter sys_clk_freq = 100_000_000;    //cora �� 125_000_000
    
    integer cnt=0;
    reg pwm_freqX100=0;
    reg [6:0] cnt_duty=0;
    wire pwm_freq_nedge;
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX100), .n_edge(pwm_freq_nedge));
    
    always @(posedge clk or posedge reset_p) begin  //�Էµ� ���ļ��� ������ ���� clk pulse ����
        if(reset_p)begin
            pwm_freqX100 = 0;
            cnt = 0;
        end
        else begin
            if(cnt >= sys_clk_freq / pwm_freq / 100 -1) cnt =0;
            else cnt = cnt +1;
            
            if (cnt<sys_clk_freq / pwm_freq/ 100/ 2) pwm_freqX100=0;
            else pwm_freqX100 = 1;
        end
    end
    
    always @(posedge clk or posedge reset_p)begin //��Ƽ �� ����
        if(reset_p)begin
            cnt_duty = 0;
            pwm_100pc = 0;
        end
        else begin
                if(pwm_freq_nedge)begin
                    if(cnt_duty >= 99) cnt_duty = 0;
                    else cnt_duty = cnt_duty + 1;
                    if(cnt_duty < duty)pwm_100pc = 1;
                    else pwm_100pc = 0;
                end
        end
    end
endmodule

module pwm_128step(   // duty�� 128 �ܰ�� �����ϴ� ���
    input clk, reset_p,
    input [6:0] duty,
    input [13:0] pwm_freq,  // ���ļ�
    output reg pwm_128);
    
    parameter sys_clk_freq = 100_000_000;   // basys 100_000_000
    
    integer cnt;
    reg pwm_freqX128;
    
    wire [26:0] temp;    // 27��Ʈ? sys_clk 100MHz �� �������� ǥ��
    assign temp = sys_clk_freq / pwm_freq;  // ��� ���?
    // ?????????
    
    always @(posedge clk, posedge reset_p) begin    // 128 ����
        if(reset_p) begin
            pwm_freqX128 = 0;
            cnt = 0;
        end
        else begin    // if cnt�� 5��  000_0000_0000_0000_0000_0000_0000
            if(cnt >= temp[26:7] - 1) cnt = 0;   // 7�� �����Ʈ
            else cnt = cnt + 1;
            
            if(cnt < temp[26:8]) pwm_freqX128 = 0;
            else pwm_freqX128 = 1;
        end
    end
    
    wire pwm_freqX128_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX128), .n_edge(pwm_freqX128_nedge));
    
    reg [6:0] cnt_duty;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
           cnt_duty = 0;
           pwm_128 = 0; 
        end
        else begin
            if(pwm_freqX128_nedge) begin
                cnt_duty =  cnt_duty + 1;
                
                if(cnt_duty < duty) pwm_128 = 1;
                else pwm_128 = 0;
            end
            else begin
            end
        end
    end
endmodule

module pwm_256step(   // duty�� 256 �ܰ�� �����ϴ� ���
    input clk, reset_p,
    input [7:0] duty,
    input [13:0] pwm_freq,  // ���ļ�
    output reg pwm_256);
    
    parameter sys_clk_freq = 100_000_000;   // basys 100_000_000, cora 125_000_000
    
    integer cnt;
    reg pwm_freqX256;
    
    wire [26:0] temp;
    assign temp = sys_clk_freq / pwm_freq; 
    
    always @(posedge clk, posedge reset_p) begin    // 256 ����
        if(reset_p) begin
            pwm_freqX256 = 0;
            cnt = 0;
        end
        else begin    // if cnt�� 5��  000_0000_0000_0000_0000_0000_0000
            if(cnt >= temp[26:8] - 1) cnt = 0;   // 7�� �����Ʈ
            else cnt = cnt + 1;
            
            if(cnt < temp[26:9]) pwm_freqX256 = 0;
            else pwm_freqX256 = 1;
        end
    end
    
    wire pwm_freqX256_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX256), .n_edge(pwm_freqX256_nedge));
    
    reg [6:0] cnt_duty;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
           cnt_duty = 0;
           pwm_256 = 0; 
        end
        else begin
            if(pwm_freqX256_nedge) begin
                cnt_duty =  cnt_duty + 1;
                
                if(cnt_duty < duty) pwm_256 = 1;
                else pwm_256 = 0;
            end
            else begin
            end
        end
    end
endmodule

module microservo( //�޺޺޺޺޺޺޺޺޺޺޺κ��̺��̺�
    input clk, reset_p,
    input [1:0]btn,
    output angle,
    output [2:0]debug_led
    );
    wire btn0_nedge;
   wire btn1_nedge;
    button_cntr btn0_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(btn0_nedge));
    button_cntr btn1_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(btn1_nedge));
    
    
    
    reg [7:0]duty;
    wire pwm_256;
    pwm_256step pwm_256_a(.clk(clk),
                     .reset_p(reset_p),
                     .duty(duty),
                     .pwm_freq(50),//50hz /*pwm_freq*/
                     .pwm_256(pwm_256)
                     );
    
    reg [2:0]state;                 
    parameter state_0 =  3'b010;
    parameter state_minus_90 =  3'b100;
    parameter state_plus_90 =  3'b001;       
   
   assign debug_led=state;
   
   always@(posedge clk or posedge reset_p) begin
        if(reset_p)begin
            state = state_0;
        end
        else if(btn0_nedge) begin //+90
            if(state== state_minus_90) state= state_0;
            else if(state== state_0) state= state_plus_90;
            else if(state==state_plus_90) state = state_plus_90;
        end 
        else if(btn1_nedge) begin //-90
            if(state== state_plus_90) state= state_0;
            else if(state== state_0) state= state_minus_90;
            else if(state==state_minus_90) state = state_minus_90;
        end
   end
             
assign angle = pwm_256;                     
                     
always@(posedge clk or posedge reset_p) begin
    if(reset_p) begin
        state= state_0;    
    end
    else if(state==state_0) begin //"0" :1.5 ms pulse ->reset_p�� 0���� ���ƿ���
        duty = 19;//19.2; //duty = 7.5%
    end
    else if(state==state_plus_90) begin //"90" (~2ms pulse) -> btn[0]
            duty = 26;//25.6; //duty = 10%  
         end
    else if(state==state_minus_90) begin //"-90" (~1ms pulse) -> btn[1]
            duty =13;//12.8; //duty = 5%
         end
    end

endmodule
module pwm512_period(
    input clk, reset_p,
    input [20:0] duty,
    input [20:0] pwm_period,
    output reg pwm_512
);
    parameter sys_clk_freq = 100_000_000;    //cora | basys�� 100_000_000
    reg [20:0] cnt_duty;

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            cnt_duty = 0;
            pwm_512 = 0;
        end
        else begin
            if(cnt_duty >= pwm_period)cnt_duty = 0;
            else cnt_duty = cnt_duty + 1;

            if(cnt_duty < duty)pwm_512 = 1;
            else pwm_512 = 0;
        end
    end
endmodule
            
            //��ư�Ѱ���
            //pwm_512_period servo(.clk(clk),.reset_p(reset_p),.duty(duty),.)pwm_period(3906),. pwm(_512)sg90;;
//sysclk=100_000_000
//..50�츣���� �������ϴϱ� �Ǹ���� 2_000_000

