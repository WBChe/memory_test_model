`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/29 17:09:29
// Design Name: 
// Module Name: host2gdma_rst
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


module host2gdma_rst(
    input           gdma_clk        ,
    input           gdma_rst        ,
    input           host_rst_flag   ,
    
    output   reg    h2gdma_rst
    );
    
    reg         flag_d0, flag_d1;
    reg  [3:0]  rst_cnt;
    reg         cnt_run;
    wire        flag;
    
    assign flag = flag_d0 & ~flag_d1;
    always@(posedge gdma_clk or posedge gdma_rst) begin
        if(gdma_rst) begin
            flag_d0 <= 1'b0;
            flag_d1 <= 1'b0;
        end
        else begin
            flag_d0 <= host_rst_flag;
            flag_d1 <= flag_d0;
        end
    end
    
    always@(posedge gdma_clk or posedge gdma_rst) begin
        if(gdma_rst) begin
            cnt_run <= 1'b0;
        end
        else if(flag) begin
            cnt_run <= 1'b1;
        end
        else if(rst_cnt == 4'd9)
            cnt_run <= 1'b0;
        else cnt_run <= cnt_run;
    end
    
    always@(posedge gdma_clk or posedge gdma_rst) begin
        if(gdma_rst) begin
            rst_cnt <= 4'd0;
        end
        else if(rst_cnt == 4'd9) begin
            rst_cnt <= 4'd0;
        end
        else if(cnt_run) begin
            rst_cnt <= rst_cnt +1'b1;
        end
        else rst_cnt <= rst_cnt;
    end    
    
    always@(posedge gdma_clk or posedge gdma_rst) begin
        if(gdma_rst) begin
            h2gdma_rst <= 1'b0;
        end
        else if(rst_cnt > 4'd0) begin
            h2gdma_rst <= 1'b1;
        end
        else h2gdma_rst <= 1'b0;
    end    
    
    
endmodule
