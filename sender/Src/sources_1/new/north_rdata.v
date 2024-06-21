`timescale 1ns / 1ps
//`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/26 20:14:08
// Design Name: 
// Module Name: gdma_rdata
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
//`default_nettype none

module north_rdata(
//
    input wire clk,
    input wire rst,
    input wire [31:0] length,
    input wire op_start,
    input wire gdma_addr_done,
    output reg gdma_done = 1'b1,
//
	input wire [31:0]  gdma_speed_divider,
	input wire         gdma_package_bypass,
//
    input wire [31:0]  gdma_ddr_rdata,
    input wire         gdma_ddr_rlast,
    output wire        gdma_ddr_rready,
    input wire [1:0]   gdma_ddr_rresp,
    input wire         gdma_ddr_rvalid,
//
    output wire        gdma2gtp_tvalid,
    input wire         gdma2gtp_tready,
    output wire [31:0] gdma2gtp_tdata,
    
     input wire         extern_spike
);
reg [29:0] 	rdata_cnt;
reg 		rdata_done;

wire package2gtp_tvalid;
wire package2gtp_tready;
wire [31:0] package2gtp_tdata;
//rd control;
always@(posedge clk or posedge rst) begin
    if(rst)
        gdma_done <= 1'b1;
    else if(op_start)
        gdma_done <= 1'b0;
    else if(gdma_addr_done && rdata_done) 
        gdma_done <= 1'b1;
end
//read data;
always@(posedge clk) begin
    if(op_start) begin
        rdata_cnt <= length[31:2];
        rdata_done <= 1'b0;
    end
    else if(gdma_ddr_rvalid && gdma_ddr_rready) begin
        rdata_cnt <= (rdata_cnt=='h0)? rdata_cnt:rdata_cnt-1'b1;
        rdata_done <= (rdata_cnt=='h0)? 1'b1:1'b0;
    end
end

assign gdma2gtp_tvalid = (gdma_package_bypass|extern_spike)? gdma_ddr_rvalid:package2gtp_tvalid;
assign gdma2gtp_tdata  = (gdma_package_bypass|extern_spike)? gdma_ddr_rdata:package2gtp_tdata;
assign gdma_ddr_rready = (gdma_package_bypass|extern_spike)? gdma2gtp_tready:package2gtp_tready;
gdma_rdata_package gdma_rdata_package(
    .clk                (clk), 
    .rst                (rst | gdma_package_bypass),
    .op_start           (op_start & !gdma_package_bypass),
    .gdma_speed_divider (gdma_speed_divider),
    .gdma_rd_tvalid     (gdma_ddr_rvalid & !gdma_package_bypass),
    .gdma_rd_tready     (package2gtp_tready),
    .gdma_rd_tdata      (gdma_ddr_rdata),
    .gdma2gtp_tvalid    (package2gtp_tvalid),
    .gdma2gtp_tready    (gdma2gtp_tready),
    .gdma2gtp_tdata     (package2gtp_tdata)
);

endmodule

