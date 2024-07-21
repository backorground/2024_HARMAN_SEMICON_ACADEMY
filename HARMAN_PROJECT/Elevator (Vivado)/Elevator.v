`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/21 16:36:25
// Design Name: 
// Module Name: Elevator
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

module Elevator(
        input clk, reset_p,
        input [2:0] btn,
        output reg [3:0] motorpin,
        output reg [2:0] LED
    );
        parameter STEP_PER_REVOLUTION = 4096;
        parameter DEGREE_ONE = 500;
        parameter DEGREE_TWO = 1000;
    
        reg [2:0] step;
        reg [15:0] step_counter;
        reg [23:0] delay_counter;  // Assuming a certain clock frequency, e.g., 50MHz for 800us delay
        reg step_active = 0;
        reg direction; 
        reg [1:0] current_floor; // 0:1Ãþ, 1:2Ãþ, 2:3Ãþ
        
        wire [2:0] btn_pedge;
        reg [15:0] action_steps;
        
        button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
        button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
        button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
        
        always @(posedge clk or posedge reset_p) begin
            if (reset_p) begin
                step <= 3'd0;
                step_counter <= 0;
                delay_counter <= 0;
                step_active <= 0;
                direction <= 0;
                current_floor <= 2'd0;
                LED = 3'b000;
            end 
            else begin
            if(!step_active)begin // ½ºÅÜ¸ðÅÍ µ¿ÀÛÁßÀÏ¶§, ´Ù¸¥ ¹öÆ° µ¿ÀÛ¾ÈÇÏ·Á°í ¸¸µç Á¶°Ç
                if(btn_pedge[0] && current_floor == 2'd1) begin  // 2Ãþ¿¡¼­ 1ÃþÀ¸·Î
                        step_active <= 1;
                        direction <= 1;
                        action_steps <= (DEGREE_ONE * STEP_PER_REVOLUTION) / 360;
                        current_floor <= 2'd0;
                        LED = 3'b001;
                    end
                    else if(btn_pedge[1] && current_floor == 2'd0) begin  // 1Ãþ¿¡¼­ 2ÃþÀ¸·Î
                        step_active <= 1;
                        direction <= 0;
                        action_steps <= (DEGREE_ONE * STEP_PER_REVOLUTION) / 360;
                        current_floor <= 2'd1;
                        LED = 3'b010;
                    end
                    else if(btn_pedge[2] && current_floor == 2'd1) begin  // 2Ãþ¿¡¼­ 3ÃþÀ¸·Î
                        step_active <= 1;
                        direction <= 0;
                        action_steps <= (DEGREE_ONE * STEP_PER_REVOLUTION) / 360;
                        current_floor <= 2'd2;
                        LED = 3'b100;
                    end
                    else if(btn_pedge[1] && current_floor == 2'd2) begin  // 3Ãþ¿¡¼­ 2ÃþÀ¸·Î
                        step_active <= 1;
                        direction <= 1;
                        action_steps <= (DEGREE_ONE * STEP_PER_REVOLUTION) / 360;
                        current_floor <= 2'd1;
                        LED = 3'b010;
                    end
                    else if(btn_pedge[2] && current_floor == 2'd0) begin  // 1Ãþ¿¡¼­ 3ÃþÀ¸·Î
                        step_active <= 1;
                        direction <= 0;
                        action_steps <= (DEGREE_TWO * STEP_PER_REVOLUTION) / 360;
                        current_floor <= 2'd2;
                        LED = 3'b100;
                    end
                    else if(btn_pedge[0] && current_floor == 2'd2) begin  // 3Ãþ¿¡¼­ 1ÃþÀ¸·Î
                        step_active <= 1;
                        direction <= 1;
                        action_steps <= (DEGREE_TWO * STEP_PER_REVOLUTION) / 360;
                        current_floor <= 2'd0;
                        LED = 3'b001;
                    end
                end
                
                if(step_active)begin
                    if (delay_counter < 24'd80000)begin
                        delay_counter <= delay_counter + 1; // 800us
                    end
                    else begin
                        delay_counter <= 24'd0;
                        if(step_counter < action_steps)begin
                            if(direction == 0)begin
                                step <= (step + 1) % 8;
                            end
                            else begin
                                step <= (step - 1) % 8;
                            end
                            step_counter <= step_counter + 1;
                        end
                        else begin  
                            step_active <= 0;
                            step_counter <= 0;
                            LED = 3'b000;
                        end
                    end 
                end
            end
        end
        
        always @(posedge clk)begin
            if(reset_p) begin
                motorpin <= 4'b0000;
            end
            else begin
                case (step)
                    3'd0: motorpin <= 4'b1000;
                    3'd1: motorpin <= 4'b1100;
                    3'd2: motorpin <= 4'b0100;
                    3'd3: motorpin <= 4'b0110;
                    3'd4: motorpin <= 4'b0010;
                    3'd5: motorpin <= 4'b0011;
                    3'd6: motorpin <= 4'b0001;
                    3'd7: motorpin <= 4'b1001;
                    default: motorpin <= 4'b0000;
                endcase
            end
        end
    endmodule