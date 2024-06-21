`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/26 18:40:25
// Design Name: 
// Module Name: gdma_awraddr
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


module gdma_awraddr(
    input wire clk,
    input wire rst,
//
    input wire [48:0] start_addr,
    input wire [31:0] length,
    input wire gdma_start,
    output wire op_start,
    output reg gdma_addr_done,
//
    output wire [48:0]  gdma_ddr_awraddr,
    output wire [1:0]   gdma_ddr_awrburst,
    output wire [3:0]   gdma_ddr_awrcache,
    output wire [7:0]   gdma_ddr_awrlen,
    output wire         gdma_ddr_awrlock,
    output wire [2:0]   gdma_ddr_awrprot,
    output wire [3:0]   gdma_ddr_awrqos,
    input wire          gdma_ddr_awrready,
    output wire [3:0]   gdma_ddr_awrregion,
    output wire [2:0]   gdma_ddr_awrsize,
    output reg          gdma_ddr_awrvalid = 1'b0
);
reg gdma_start_r0 = 'h0;
reg gdma_start_r1 = 'h0;
reg [30:0] word_cnt = 'h0;  //unit: 32bit=4byte;
reg [30:0] word_length = 'h0;
reg [46:0] awraddr_cnt = 'h0;
reg [7:0] awrlen_curr;
reg [7:0] awrlen_next;

wire [8:0] awraddr_incr;
wire [48:0] awraddr_cnt_next;
wire [30:0] word_remain;
wire word_cnt_done;
wire [10:0] awrdist_to_4k;

//outputs;
assign gdma_ddr_awraddr = {awraddr_cnt[46:0],2'b00};
assign gdma_ddr_awrburst = 2'b01;       //increment burst type
assign gdma_ddr_awrcache = 4'b0011;     //none-modifiable transfer
assign gdma_ddr_awrlen = awrlen_curr;
assign gdma_ddr_awrlock = 1'b0;         //not exclusive access
assign gdma_ddr_awrprot = 3'h0;         //non privileged/secure/data access
assign gdma_ddr_awrqos = 4'b0000;       //the highest quality of service
assign gdma_ddr_awrregion = 4'h0;
assign gdma_ddr_awrsize = 3'b010;       //4 bytes data width;         

//pulse formation;
assign op_start = gdma_start_r0 ^ gdma_start_r1;
always@(posedge clk or negedge gdma_start) begin
    if(!gdma_start) begin
        gdma_start_r0 <= 'h0;
        gdma_start_r1 <= 'h0;
    end
    else begin
        gdma_start_r0 <= gdma_start;
        gdma_start_r1 <= gdma_start_r0;
    end
end
//address counter;
assign awraddr_incr = awrlen_curr + 1'b1;
assign awraddr_cnt_next = awraddr_cnt + awraddr_incr;
always@(posedge clk) begin
    if(op_start)
        awraddr_cnt <= start_addr[48:2];
    else if(gdma_ddr_awrvalid && gdma_ddr_awrready)
        awraddr_cnt <= awraddr_cnt_next;
end
//word length counter;
assign word_cnt_done = ((word_cnt+awrlen_curr+1'b1) == word_length);
assign word_remain = (op_start)? (length[31:2]+1'b1):(word_length - (word_cnt+awrlen_curr+1'b1));
always@(posedge clk) begin
    if(op_start) begin
        word_cnt <= 'h0;
        word_length <= length[31:2]+1'b1;
    end
    else if(gdma_ddr_awrvalid && gdma_ddr_awrready)
        word_cnt <= word_cnt + awrlen_curr + 1'b1;
end
//burst length;
//4k judgement;
assign awrdist_to_4k = (((op_start)?{start_addr[48:12],10'h3FF}:{awraddr_cnt_next[46:10],10'h3FF}) - ((op_start)? start_addr[48:2]:awraddr_cnt_next))+1'b1;
always@(*) begin
    if({20'h0,awrdist_to_4k} <= word_remain) begin
        if(awrdist_to_4k >= 'd256)
            awrlen_next = 8'd255;
        else
            awrlen_next = awrdist_to_4k[8:0]-1'b1;
    end
    else begin
        if(word_remain >= 'd256)
            awrlen_next = 8'd255;
        else 
            awrlen_next = word_remain[8:0]-1'b1;
    end
end
always@(posedge clk or posedge rst) begin
    if(rst)
        awrlen_curr <= 'h0;
    else if(op_start)
        awrlen_curr <= awrlen_next;
    else if(gdma_ddr_awrvalid && gdma_ddr_awrready) 
        awrlen_curr <= awrlen_next;
end
//valid;
always@(posedge clk or posedge rst) begin
    if(rst) begin
        gdma_ddr_awrvalid <= 1'b0;
        gdma_addr_done <= 1'b1;
    end
    else if(op_start) begin
        gdma_ddr_awrvalid <= 1'b1;
        gdma_addr_done <= 1'b0;
    end
    else if(gdma_ddr_awrvalid && gdma_ddr_awrready && word_cnt_done) begin
        gdma_ddr_awrvalid <= 1'b0;
        gdma_addr_done <= 1'b1;
    end
end


endmodule
