`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/27 12:30:20
// Design Name: 
// Module Name: I2C
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

///I2C 통신모듈 TOP
// 0번 누르면 data에 0 8개 보내고 back light 켜지고, 1번 누르면 data에 1 8개 보내고 back light 꺼진다.
module I2C_master_top(
    input clk, reset_p,
    input [1:0] btn,
    output sda, scl,
    output [1:0]debug_btn_led
);
    // 우리는 write만 쓸건데, read가 1, write가 0 이어서 rd_wr에 0을 준거다.
    // addr 주소값은 datasheet에 0x27로 정해져있는 값이다.
    reg [7:0] data;
    reg valid;
    I2C_master master(.clk(clk), .reset_p(reset_p), .rd_wr(0), .addr(7'h27), .data(data), .valid(valid), .sda(sda), .scl(scl));
    wire [1:0] btn_pedge, btn_nedge;
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]), .btn_ne(btn_nedge[0]));
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]), .btn_ne(btn_nedge[1]));
    
     assign debug_btn_led = btn;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            data = 0;
            valid = 0;
        end
        else begin
            if(btn_pedge[0])begin
                data = 8'b0000_0000;
                valid = 1;
            end
            else if(btn_nedge[0]) valid = 0;
            else if(btn_pedge[1])begin
                data = 8'b1111_1111;
                valid = 1;
            end
            else if(btn_nedge[1]) valid = 0;
        end
    end
endmodule









module I2C_master_top_nk(
    input clk, reset_p,
    input [1:0]btn,
    output sda, scl
);

    
    reg [7:0] data;
    reg valid;
    
    I2C_master master(.clk(clk), 
                      .reset_p(reset_p),
                      .rd_wr(0),
                      .addr(7'h27),
                      .data(data),
                      .valid(valid),
                      .sda(sda), 
                      .scl(scl));
                    
    wire [1:0] btn_pedge, btn_nedge;                
    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]),.btn_ne(btn_nedge[0]));
    button_cntr btn1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]),.btn_ne(btn_nedge[1]));                      
    //data = 8'b0000_0000(backlight off)
    //data = 8'b1111_1111(backlight on)
                      
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            data =0;
            valid =0;
        end
        else begin
            if(btn_pedge[0]) begin
                data=8'b0000_0000;
                valid =1;
            end
            else if (btn_nedge[0]) valid =0;
            else if (btn_pedge[1]) begin
                data =8'b1111_1111; //0000_1000
                valid = 1;
            end
            else if(btn_nedge[1]) valid =0;
        end
    end                  
endmodule
module I2C_master(
    input clk, reset_p,
    input rd_wr,
    input valid,
    input [6:0] addr,
    input [7:0] data,
    output reg sda,
    output reg scl
);
parameter IDLE =        7'b000_0001;
parameter COMM_START =  7'b000_0010;
parameter SND_ADDR =    7'b000_0100;       //send address
parameter RD_ACK =      7'b000_1000;
parameter SND_DATA =    7'b001_0000;       //send data
parameter SCL_STOP =    7'b010_0000;
parameter COMM_STOP =   7'b100_0000;
wire [7:0] addr_rw;
wire clk_usec;
wire scl_nedge, scl_pedge;
wire valid_pedge;
reg [2:0] cnt_bit;
reg [2:0] count_usec5;
reg [6:0] state, next_state;
reg scl_toggle_e;
reg stop_data;
clock_usec usec_clk(clk,reset_p,clk_usec);
edge_detector_n ed_scl(.clk(clk), .reset_p(reset_p), .cp(scl), .n_edge(scl_nedge), .p_edge(scl_pedge));
edge_detector_n ed_valid(.clk(clk), .reset_p(reset_p), .cp(valid), .p_edge(valid_pedge));
assign addr_rw = {addr, rd_wr};
always @(posedge clk or posedge reset_p) begin
    if (reset_p) begin
        count_usec5 = 0;
        scl = 1;
    end
    else if(scl_toggle_e)begin
        if (clk_usec) begin
            if (count_usec5 >= 4) begin
                count_usec5 = 0;
                scl = ~scl;
            end
            else count_usec5 = count_usec5 + 1;
        end
    end
    else if (scl_toggle_e == 0) count_usec5 = 0;
end
always @(negedge clk or posedge reset_p) begin
    if (reset_p) state = IDLE;
    else state = next_state;
end
always @(posedge clk or posedge reset_p) begin
    if (reset_p) begin
        sda = 1;
        next_state = IDLE;
        scl_toggle_e = 0;
        cnt_bit = 7;
        stop_data = 0;
    end
    else begin
        case (state)
            IDLE:begin
                if (valid_pedge) next_state = COMM_START;
            end
            COMM_START:begin
                sda = 0;
                scl_toggle_e = 1;
                next_state = SND_ADDR;
            end
            SND_ADDR:begin
                if (scl_nedge) sda = addr_rw[cnt_bit];
                else if (scl_pedge) begin
                    if (cnt_bit == 0) begin
                        cnt_bit = 7;
                        next_state = RD_ACK;
                    end
                    else cnt_bit = cnt_bit - 1;
                end
            end
            RD_ACK:begin
                if (scl_nedge) sda = 'bz;
                else if (scl_pedge) begin
                    if (stop_data) begin
                        stop_data = 0;
                        next_state = SCL_STOP;
                    end
                    else begin
                        next_state = SND_DATA;
                    end
                end
            end
            SND_DATA:begin
                if (scl_nedge) sda = data[cnt_bit];
                else if (scl_pedge) begin
                    if (cnt_bit == 0) begin
                        cnt_bit = 7;
                        next_state = RD_ACK;
                        stop_data = 1;
                    end
                    else cnt_bit = cnt_bit - 1;
                end
            end
            SCL_STOP:begin
                if (scl_nedge) begin
                    sda = 0;
                end
                else if (scl_pedge) begin
                    next_state = COMM_STOP;
                end
            end
            COMM_STOP:begin
                if(count_usec5 >= 3)begin
                    sda = 1;
                    scl_toggle_e = 0;
                    next_state = IDLE;
                end
            end
        endcase
    end
end
endmodule

module I2C_master_nk(
    input clk, reset_p,
    input rd_wr,
    input [6:0] addr,
    input [7:0] data,
    input valid,
    output reg sda, //inout
    output reg scl );

    //FSM
    parameter IDLE =        7'b000_0001;
    parameter COMM_START =  7'b000_0010;
    parameter SND_ADDR =    7'b000_0100;
    parameter RD_ACK =      7'b000_1000; //acknoledge
    parameter SND_DATA =    7'b001_0000;
    parameter SCL_STOP =    7'b010_0000;
    parameter COMM_STOP =   7'b100_0000;

    wire [7:0] addr_rw;
    assign addr_rw = {addr, rd_wr};
    
    wire clk_usec;
    clock_usec usec_clk(clk, reset_p, clk_usec);

    reg [2:0] count_usec5;
    reg scl_toggle_e;
    
    always@(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            count_usec5 =0;
            scl = 1; //IDLE에서 1로 유지되어야 한다.
        end
        else if(scl_toggle_e)begin
            if(clk_usec) begin
                if(count_usec5 >= 4 ) begin
                    count_usec5 = 0;
                    scl = ~scl;
                end    
                else count_usec5 = count_usec5 +1;
            end            
        end
        else if(scl_toggle_e == 0) count_usec5 =0;
    end

    wire scl_nedge, scl_pedge;
    edge_detector_n ed(.clk(clk),.reset_p(reset_p),.cp(scl),.n_edge(scl_nedge),.p_edge(scl_pedge));
    
     wire valid_pedge;
    edge_detector_n ed_valid(.clk(clk),.reset_p(reset_p),.cp(valid),.p_edge(valid_pedge));
    
    
    reg [6:0] state, next_state; //state 는 nedge, next_state는 pedge에서 바꾼다.
    always @(negedge clk or posedge reset_p ) begin
        if(reset_p) state= IDLE;
        else state = next_state;
    end
    
    reg [2:0] cnt_bit;
    reg stop_data;
    
    always@ (posedge clk or posedge reset_p) begin
        if(reset_p) begin
            sda=1; //초기값은 high
            next_state = IDLE;
            scl_toggle_e =0;   
            cnt_bit = 7;
            stop_data = 0;    
        end
        else begin
            case(state)
                IDLE: begin
                    if(valid_pedge) next_state = COMM_START;
                end
                COMM_START: begin
                    sda = 0; //start
                    scl_toggle_e =1; //clk이 toggle되게 한다.
                    next_state = SND_ADDR;
                end
                SND_ADDR: begin
                    if(scl_nedge) sda= addr_rw[cnt_bit];//counter 사용
                    else if(scl_pedge) begin 
                        if(cnt_bit ==0) begin
                            cnt_bit =7;
                            next_state =RD_ACK;
                        end
                        else cnt_bit = cnt_bit -1;
                    end
                end
                RD_ACK : begin
                    if(scl_nedge) sda = 'bz; //임피던스 출력
                    else if(scl_pedge) begin
                        if(stop_data) begin
                            stop_data=0;
                            next_state = SCL_STOP;
                        end    
                        else begin
                            next_state = SND_DATA;
                        end
                    end                                       
                end
                SND_DATA: begin
                      if(scl_nedge) sda= data[cnt_bit];//counter 사용
                    else if(scl_pedge) begin 
                        if(cnt_bit ==0) begin
                            cnt_bit =7;
                            next_state =RD_ACK;
                            stop_data =1;
                        end
                        else cnt_bit = cnt_bit -1;
                    end
                end
                SCL_STOP: begin
                    if(scl_nedge) begin
                        sda =0;
                    end
                    else if(scl_pedge) begin
                        next_state = COMM_STOP;
                    end
                end
                COMM_STOP : begin
                    if(count_usec5 >=3) begin
                        sda =1;
                        scl_toggle_e =0;
                        next_state =IDLE;
                    end
                end
            endcase
        end
    end
endmodule




module i2c_lcd_send_byte_nk(
    input clk, reset_p,
    input [6:0] addr,
    input [7:0] send_buffer,
    input send, rs,
    output scl, sda,
    output reg busy
);
    parameter   IDLE                       = 6'b00_0001;
    parameter   SEND_HIGH_NIBBLE_DISABLE   = 6'b00_0010;
    parameter   SEND_HIGH_NIBBLE_ENABLE    = 6'b00_0100;
    parameter   SEND_LOW_NIBBLE_DISABLE    = 6'b00_1000;
    parameter   SEND_LOW_NIBBLE_ENABLE     = 6'b01_0000;
    parameter   SEND_DISABLE               = 6'b10_0000;
    
    wire clk_usec;
    wire send_pedge;
    reg [21:0] count_usec;
    reg [5:0] state, next_state;
    reg [7:0] data;
    reg count_usec_e;
    reg valid;
    clock_usec usec_clk(clk,reset_p,clk_usec);
    edge_detector_n ed_send(.clk(clk), .reset_p(reset_p), .cp(send), .p_edge(send_pedge));
    always @(negedge clk or posedge reset_p) begin
        if (reset_p) begin
            count_usec = 0;
        end
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e)count_usec = 0; //뭔차이??
        end
//      else if(clk_usec)begin
//          if(clk_usec && count_usec_e) count_usec = count_usec + 1;
//          else if(!count_usec_e)count_usec = 0;
//      end
    end
    always @(negedge clk or posedge reset_p) begin
        if (reset_p) state = IDLE;
        else state = next_state;
    end
    always @(posedge clk or posedge reset_p)begin
        if (reset_p) begin
            next_state = IDLE;
        end
        else begin
            case (state)
                IDLE:begin
                    if (send_pedge) begin
                        next_state = SEND_HIGH_NIBBLE_DISABLE;
                        busy = 1;
                    end
                end
                SEND_HIGH_NIBBLE_DISABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[7:4], 3'b100, rs};   //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_HIGH_NIBBLE_ENABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_HIGH_NIBBLE_ENABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[7:4], 3'b110, rs} ;  //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_LOW_NIBBLE_DISABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_LOW_NIBBLE_DISABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[3:0], 3'b100, rs};   //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_LOW_NIBBLE_ENABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_LOW_NIBBLE_ENABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[3:0], 3'b110, rs} ;  //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_DISABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_DISABLE:begin
                 if (count_usec <= 22'd200) begin
                        data = {send_buffer[3:0], 3'b100, rs} ;  //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = IDLE;
                        count_usec_e = 0;
                        valid = 0;
                        busy = 0;
                    end
                end
            endcase
        end
    end
    I2C_master master(.clk(clk), .reset_p(reset_p), .rd_wr(0), .valid(valid), .addr(7'h27), .data(data), .sda(sda), .scl(scl));
endmodule

module i2c_txtlcd_top_nk(  //btn누르면 LCD에 A출력
    input clk, reset_p,
    input [1:0]btn,
    output scl, sda
    );
    parameter IDLE          = 6'b00_0001;
    parameter INIT          = 6'b00_0010;
    parameter SEND          = 6'b00_0100;
    parameter SAMPLE_DATA   = "A";
    parameter MOVE_CURSOR    =6'b00_1000;
  
    
    wire [1:0]btn_pedge, btn_nedge;
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]),
            .btn_pe(btn_pedge[0]), .btn_ne(btn_nedge[0]));
            
       button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]),
            .btn_pe(btn_pedge[1]), .btn_ne(btn_nedge[1]));
            
    reg [7:0] send_buffer;
    reg send_e, rs;
    wire busy;
    i2c_lcd_send_byte send_byte(.clk(clk), .reset_p(reset_p), .addr(7'h27),
        .send_buffer(send_buffer), .send(send_e), .rs(rs), .scl(scl), .sda(sda), .busy(busy));
    reg [21:0] count_usec;
    reg count_usec_e;
    wire clk_usec;
    clock_usec usec_clk(clk, reset_p, clk_usec);
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec = 0;
        end
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e)count_usec = 0; //뭔차이??
        end
    end
    
    
     
    
    
    
    reg [5:0] state, next_state;
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)state = IDLE;
        else state = next_state;
    end
    reg init_flag;// 초기화 됐는지 확인하는 변수
    reg [3:0] cnt_data;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            next_state = IDLE;
            send_buffer = 0;
            rs = 0;
            send_e = 0;
            init_flag = 0;
            cnt_data=0;
        end
        else begin
            case(state)
                IDLE : begin
                    if(init_flag) begin //init 마지막
                        if(btn_pedge[0]) next_state = SEND;
                        else if(btn_pedge[1]) next_state = MOVE_CURSOR;
                    end
                    else begin
                        if(count_usec <= 22'd80_000) begin
                            count_usec_e = 1;
                        end
                        else begin
                            next_state = INIT;
                            count_usec_e = 0;
                        end
                    end
                end
                INIT : begin
                    if(count_usec <= 22'd1000) begin
                        send_buffer = 8'h33;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd1010) send_e = 0;
                    if(count_usec <= 22'd2010) begin
                        send_buffer = 8'h32;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd2020) send_e = 0;
                    if(count_usec <= 22'd3020) begin
                        send_buffer = 8'h28;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd3030) send_e = 0;
                    if(count_usec <= 22'd4030) begin
                        send_buffer = 8'h08;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd4040) send_e = 0;
                    if(count_usec <= 22'd5040) begin
                        send_buffer = 8'h01;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd5050) send_e = 0;
                    if(count_usec <= 22'd6050) begin
                        send_buffer = 8'h06;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if (count_usec < 22'd6060) send_e =0;
                    else begin
                        next_state = IDLE;
                        init_flag = 1;
                        count_usec_e = 0;
                    end
                end
                SEND : begin
                    if(busy) begin
                        next_state = IDLE;
                        send_e = 0;
                        cnt_data= cnt_data+1;
                    end
                    else begin
                        send_buffer = SAMPLE_DATA + cnt_data;
                        rs = 1;
                        send_e = 1;
                    end
                end
                MOVE_CURSOR: begin
                            if(busy) begin
                                next_state = IDLE;
                                send_e=0;
                            end
                            else begin
                                send_buffer = 8'hc0;
                                rs=0;
                                send_e=1;                        
                            end
                end
              
            endcase
        end
    end
endmodule

module i2c_lcd_send_byte(
    input clk, reset_p,
    input [6:0] addr,
    input [7:0] send_buffer,
    input send, rs,
    output scl, sda,
    output reg busy
);
    parameter IDLE = 6'b00_0001;
    parameter SEND_HIGH_NIBBLE_DISABLE   = 6'b00_0010;
    parameter SEND_HIGH_NIBBLE_ENABLE    = 6'b00_0100;
    parameter SEND_LOW_NIBBLE_DISABLE    = 6'b00_1000;
    parameter SEND_LOW_NIBBLE_ENABLE     = 6'b01_0000;
    parameter SEND_DISABLE               = 6'b10_0000;
    wire clk_usec;
    wire send_pedge;
    reg [21:0] count_usec;
    reg [5:0] state, next_state;
    reg [7:0] data;
    reg count_usec_e;
    reg valid;
    clock_usec usec_clk(clk,reset_p,clk_usec);
    I2C_master master(.clk(clk), .reset_p(reset_p), .rd_wr(0), .valid(valid), .addr(7'h27), .data(data), .sda(sda), .scl(scl));
    edge_detector_n ed_send(.clk(clk), .reset_p(reset_p), .cp(send), .p_edge(send_pedge));
    always @(negedge clk or posedge reset_p) begin
        if (reset_p) begin
            count_usec = 0;
        end
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if (!count_usec_e) count_usec = 0;
        end
    end
    always @(negedge clk or posedge reset_p) begin
        if (reset_p) state = IDLE;
        else state = next_state;
    end
    always @(posedge clk or posedge reset_p)begin
        if (reset_p) begin
            next_state = IDLE;
        end
        else begin
            case (state)
                IDLE:begin
                    if (send_pedge) begin
                        next_state = SEND_HIGH_NIBBLE_DISABLE;
                        busy = 1;
                    end
                end
                SEND_HIGH_NIBBLE_DISABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[7:4], 3'b100, rs};   //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_HIGH_NIBBLE_ENABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_HIGH_NIBBLE_ENABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[7:4], 3'b110, rs};   //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_LOW_NIBBLE_DISABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_LOW_NIBBLE_DISABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[3:0], 3'b100, rs};   //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_LOW_NIBBLE_ENABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_LOW_NIBBLE_ENABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[3:0], 3'b110, rs};   //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_DISABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_DISABLE:begin
                    if (count_usec <= 22'd200) begin
                        data = {send_buffer[3:0], 3'b100, rs};   //[d7 d6 d5 d4], [BT EN RW] RS      BT = backlight
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = IDLE;
                        count_usec_e = 0;
                        valid = 0;
                        busy = 0;
                    end
                end
            endcase
        end
    end
endmodule

module i2c_txtlcd_top(
    input clk, reset_p,
    input [2:0]btn,
    output scl, sda);
    parameter IDLE = 6'b00_0001;
    parameter INIT = 6'b00_0010;
    parameter SEND = 6'b00_0100;
    parameter MOVE_CURSOR = 6'b00_1000;
    parameter SAMPLE_DATA = "A";
    parameter WANT = "temperature :  humidity: " ;
    parameter SHIFT_DISPLAY= 6'b01_0000;
    
    wire [2:0] btn_pedge, btn_nedge;
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]),
        .btn_pe(btn_pedge[0]), .btn_ne(btn_nedge[0]));
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]),
        .btn_pe(btn_pedge[1]), .btn_ne(btn_nedge[1]));
    button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]),
        .btn_pe(btn_pedge[2]), .btn_ne(btn_nedge[2]));
    reg [7:0] send_buffer;
    reg send_e, rs;
    wire busy;
    reg [3:0] cnt_data;
    i2c_lcd_send_byte send_byte(.clk(clk), .reset_p(reset_p),
        .addr(7'h27), .send_buffer(send_buffer), .send(send_e), .rs(rs),
        .scl(scl), .sda(sda), .busy(busy));
    reg [21:0] count_usec;
    reg count_usec_e;
    wire clk_usec;
    clock_usec usec_clk(clk, reset_p, clk_usec);
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec = 0;
        end
        else begin
            if(clk_usec && count_usec_e)count_usec = count_usec + 1;
            else if(!count_usec_e)count_usec = 0;
        end
    end
    reg [5:0] state, next_state;
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)state = IDLE;
        else state = next_state;
    end
    reg init_flag;
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            next_state = IDLE;
            send_buffer = 0;
            rs = 0;
            send_e = 0;
            init_flag = 0;
        end
        else begin
            case(state)
                IDLE:begin
                    if(init_flag)begin
                        if(btn_pedge[0])next_state = SEND;
                        else if(btn_pedge[1])next_state = MOVE_CURSOR;
                        else if(btn_pedge[2])next_state = SHIFT_DISPLAY;
                    end
                    else begin
                        if(count_usec <= 22'd80_000)begin
                            count_usec_e = 1;
                        end
                        else begin
                            next_state = INIT;
                            count_usec_e = 0;
                        end
                    end
                end
                INIT:begin
                    if(count_usec <= 22'd1000)begin
                        send_buffer = 8'h33;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd1010)send_e = 0;
                    else if(count_usec <= 22'd2010)begin
                        send_buffer = 8'h32;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd2020)send_e = 0;
                    else if(count_usec <= 22'd3020)begin
                        send_buffer = 8'h28;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd3030)send_e = 0;
                    else if(count_usec <= 22'd4030)begin
                        send_buffer = 8'h0f;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd4040)send_e = 0;
                    else if(count_usec <= 22'd5040)begin
                        send_buffer = 8'h01;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd5050)send_e = 0;
                    else if(count_usec <= 22'd6050)begin
                        send_buffer = 8'h06;
                        send_e = 1;
                        count_usec_e = 1;
                    end
                    else if(count_usec <= 22'd6060)send_e = 0;
                    else begin
                        next_state = IDLE;
                        init_flag = 1;
                        count_usec_e = 0;
                    end
                end
                SEND:begin
                    if(busy)begin
                        next_state = IDLE;
                        send_e = 0;
                        cnt_data = cnt_data + 1;
                    end
                    else begin
                        send_buffer = SAMPLE_DATA + cnt_data;
                        rs = 1;
                        send_e = 1;
                    end
                end
                MOVE_CURSOR: begin
                        if(busy)begin
                                next_state = IDLE;
                                send_e = 0;
                        end
                        else begin
                                send_buffer = 8'hc0;
                                rs = 0;
                                send_e = 1;
                        end
                end
                SHIFT_DISPLAY: begin
                  if(busy)begin
                                next_state = IDLE;
                                send_e = 0;
                        end
                        else begin
                                send_buffer = 8'h1c;
                                rs = 0;
                                send_e = 1;
                        end
                end
            endcase
        end
    end
endmodule