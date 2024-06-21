`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/28 09:23:10
// Design Name: 
// Module Name: axi_autorepair
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


module axi_autorepair(
    clk                ,        
    rst_n              ,        
    length             , 
    op_start           ,        
    autorepair_start   ,
    autorepair_done    ,        
    gtp2gdma_tvalid    ,
    gtp2gdma_tready    ,
    gtp2gdma_tdata     ,
                      
    repair2gdma_tvalid , 
    repair2gdma_tready , 
    repair2gdma_tdata 
    );
    input  wire        clk;
    input  wire        rst_n;
    input  wire        [31:0] length;
    input  wire        op_start;
    input  wire        autorepair_start;//host_en
    output reg         autorepair_done;
    input  wire        gtp2gdma_tvalid;
    output wire        gtp2gdma_tready;
    input  wire [31:0] gtp2gdma_tdata;
    
    output wire        repair2gdma_tvalid;
    input  wire        repair2gdma_tready;
    output wire [31:0] repair2gdma_tdata;
    
    
assign repair2gdma_tdata  = gtp2gdma_tdata;
assign repair2gdma_tvalid = autorepair_done?gtp2gdma_tvalid:repair_tvalid;
assign gtp2gdma_tready =    repair2gdma_tready; 
reg [30:0] wdata_cnt;
reg repair_tvalid; 
reg autorepair_start_r0 = 'h0;
reg autorepair_start_r1 = 'h0;  
wire autorepair_start_pluse;
reg op_start_r0 = 'h0;
reg op_start_r1 = 'h0;  
wire op_start_pluse;
assign autorepair_start_pluse = autorepair_start_r0&(!autorepair_start_r1);
assign op_start_pluse = op_start_r0&(!op_start_r1);
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        autorepair_start_r0 <= 'h0;
        autorepair_start_r1 <= 'h0;
    end
    else begin
        autorepair_start_r0 <= autorepair_start;
        autorepair_start_r1 <= autorepair_start_r0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        op_start_r0 <= 'h0;
        op_start_r1 <= 'h0;
    end
    else begin
        op_start_r0 <= op_start;
        op_start_r1 <= op_start_r0;
    end
end

 
//wdata_cnt    
always@(posedge clk or negedge rst_n)
if(!rst_n)
    wdata_cnt <= 'h0;
else if(op_start_pluse)
    wdata_cnt <= 'h0;
else if(repair2gdma_tvalid && repair2gdma_tready)
    wdata_cnt <= wdata_cnt + 1'b1;
    
//autorepair_done    
wire wdata_last;
assign wdata_last = (wdata_cnt[30:0]==length[31:1]+1'b1);
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        autorepair_done <= 1'b1;
    else if(autorepair_start_pluse)
        autorepair_done <= 1'b0;
    else if(repair2gdma_tvalid && repair2gdma_tready&&(autorepair_done==0)) 
        autorepair_done <= (wdata_last)? 1'b1:1'b0;
end   
 
//repair_tvalid;  
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        repair_tvalid <= 1'b0;
    else if(autorepair_done==1'b0)
        repair_tvalid <= 1'b1;
    else 
        repair_tvalid <= 1'b0;
end 

ila_0 ila_repair (
	.clk(clk), // input wire clk

	.probe0(length), // input wire [31:0]  probe0  
	.probe1(wdata_cnt), // input wire [30:0]  probe1 
	.probe2(repair2gdma_tvalid), // input wire [0:0]  probe2 
	.probe3(repair2gdma_tready), // input wire [0:0]  probe3 
	.probe4(autorepair_done), // input wire [0:0]  probe4 
	.probe5(wdata_last), // input wire [0:0]  probe5
	.probe6(autorepair_start),
	.probe7(repair_tvalid),
	.probe8(op_start)
);  
    
endmodule
