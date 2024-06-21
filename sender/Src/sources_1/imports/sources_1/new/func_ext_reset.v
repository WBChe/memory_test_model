`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/25 20:18:26
// Design Name: 
// Module Name: fun_ext_reset
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


module func_ext_reset(
    input           slowest_sync_clk,
    input           ui_clk_sync_rst,
    input           host_rst_flag,
    output reg      ext_reset_in
    );
    //state machine 10T ext_reset_in high
    reg [3:0] state_cnt;
    reg [1:0] cur_state, next_state;
    parameter IDLE = 2'b00, RST = 2'b01, WAIT = 2'b10;
    
    reg ri_host_rst_flag;
    always @(posedge slowest_sync_clk or posedge  ui_clk_sync_rst)begin	
	   if(ui_clk_sync_rst)begin
	   	   ri_host_rst_flag <= 1'b0;
	   end
	   else begin
	   	   ri_host_rst_flag <= host_rst_flag;
	   end
    end
    
    always @(posedge slowest_sync_clk or posedge  ui_clk_sync_rst)begin	
	   if(ui_clk_sync_rst)begin
	   	   cur_state <= IDLE;
	   end
	   else begin
	   	   cur_state <= next_state;
	   end
    end
    
    always @(*) begin						
		case(cur_state)
		  IDLE    :   next_state =   ((ri_host_rst_flag)  ?    RST    :   IDLE);
		  
		  RST     :   next_state =   ((state_cnt == 4'd9)   ?    WAIT    :   RST);
		  
		  WAIT    :   next_state =   ((ri_host_rst_flag)   ?    WAIT    :   IDLE);
		  
		  default :   next_state =   IDLE;
	   endcase
	end
    
    always @(posedge slowest_sync_clk or posedge  ui_clk_sync_rst)begin	
	    if(ui_clk_sync_rst)begin
	        ext_reset_in <= ui_clk_sync_rst;
        end
        else if(cur_state == RST) begin
            ext_reset_in <= 1'b1;
        end
        else ext_reset_in <= ui_clk_sync_rst;
    end
        
    always@(posedge slowest_sync_clk or posedge ui_clk_sync_rst) begin
        if(ui_clk_sync_rst)
            state_cnt <= 4'd0;
        else if(state_cnt == 4'd9)
            state_cnt <= 4'd0;
        else if(cur_state == RST)
            state_cnt <= state_cnt + 1'b1;
        else state_cnt <= state_cnt;
    end
    
//    reg [3:0] host_cnt;
//    reg rst_run;
//    always @(posedge slowest_sync_clk or posedge  ui_clk_sync_rst)begin	
//	    if(ui_clk_sync_rst)begin
//	        rst_run <= 1'b0;
//        end
//        else if(host_cnt >= 4'd9) begin
//            rst_run <= 1'b0;
//        end
//        else if(host_rst_flag) begin
//            rst_run <= 1'b1;
//        end
//        else rst_run <= rst_run;
//    end
    
//    always @(posedge slowest_sync_clk or posedge  ui_clk_sync_rst)begin	
//	    if(ui_clk_sync_rst)begin
//	        host_cnt <= 4'd0;
//        end
//        else if(!rst_run) begin
//            host_cnt <= 4'd0;
//        end
//        else if(host_cnt >= 4'd9) begin
//            host_cnt <= 4'd0;
//        end
//        else if(rst_run) begin
//            host_cnt <= host_cnt + 1'b1;
//        end
//        else host_cnt <= host_cnt;
//    end
    
//    always @(posedge slowest_sync_clk or posedge  ui_clk_sync_rst)begin	
//	    if(ui_clk_sync_rst)begin
//	        ext_reset_in <= ui_clk_sync_rst;
//        end
//        else if(host_cnt > 4'd0) begin
//            ext_reset_in <= 1'b1;
//        end
//        else ext_reset_in <= ui_clk_sync_rst;
//    end
    
    
endmodule
