`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/26 20:24:54
// Design Name: 
// Module Name: gdma_wdata
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

module north_wdata(
    input wire clk,
    input wire rst,
//
    input wire [48:0] start_addr,
    input wire [31:0] length,
    input wire op_start,
    input wire gdma_addr_done,
    output reg gdma_done = 1'b1,
//
    output wire         gdma_ddr_bready,
    input wire [1:0]    gdma_ddr_bresp,
    input wire          gdma_ddr_bvalid,
    output reg [31:0]  gdma_ddr_wdata,
    output wire         gdma_ddr_wlast,
    input wire          gdma_ddr_wready,
    output wire [3:0]   gdma_ddr_wstrb,
    output reg         gdma_ddr_wvalid,
//
    input wire         gtp2gdma_tvalid,
    output wire        gtp2gdma_tready,
    input wire [31:0]  gtp2gdma_tdata,
    
    input wire         stop_pkg
);
reg [46:0] waddr_cnt;
reg [7:0] wdata_burst_cnt;
reg [29:0] wdata_cnt;
reg wdata_done = 1'b1;

wire wdata_4k_last;
wire wdata_burst_last;
wire wdata_last;

wire convert2gdma_tvalid;
wire convert2gdma_tready;
wire [31:0] convert2gdma_tdata;

//
assign gdma_ddr_bready = 1'b1;
assign gdma_ddr_wstrb = 4'b1111;
//
always@(posedge clk or posedge rst) begin
    if(rst) 
        gdma_done <= 'h1;
    else if(op_start) 
        gdma_done <= 'h0;
    else if(gdma_addr_done && wdata_done)
        gdma_done <= 1'b1;
end
//data;
//assign gdma_ddr_wvalid = convert2gdma_tvalid && ~wdata_done;
//assign gdma_ddr_wdata = convert2gdma_tdata;
always@(*) begin 
    if (stop_pkg) begin
        gdma_ddr_wvalid = gtp2gdma_tvalid && ~wdata_done;
        gdma_ddr_wdata  = gtp2gdma_tdata;
    end
    else begin
        gdma_ddr_wvalid = convert2gdma_tvalid && ~wdata_done;
        gdma_ddr_wdata  = convert2gdma_tdata;
    end
end
assign convert2gdma_tready = gdma_ddr_wready && ~wdata_done;
assign gdma_ddr_wlast = (wdata_4k_last || wdata_burst_last || wdata_last) && gdma_ddr_wvalid;

//write address counter for 4k detection;
assign wdata_4k_last = (waddr_cnt[9:0]==10'h3FF);
assign wdata_burst_last = (wdata_burst_cnt==8'hFF);
assign wdata_last = (wdata_cnt[29:0]==length[31:2]);
always@(posedge clk) begin
    if(op_start) begin
        waddr_cnt <= start_addr[48:2];
        wdata_burst_cnt <= 'h0;
        wdata_cnt <= 'h0;
    end
    else if(gdma_ddr_wvalid && gdma_ddr_wready) begin
        waddr_cnt <= waddr_cnt + 1'b1;
        wdata_burst_cnt <= (wdata_4k_last || wdata_burst_last)? 'h0:wdata_burst_cnt+1'b1;
        wdata_cnt <= wdata_cnt + 1'b1;
    end
end
always@(posedge clk or posedge rst) begin
    if(rst)
        wdata_done <= 1'b1;
    else if(op_start)
        wdata_done <= 1'b0;
    else if(gdma_ddr_wvalid && gdma_ddr_wready) 
        wdata_done <= (wdata_last)? 1'b1:1'b0;
end

gdma_wdata_width_converter gdma_wdata_width_converter(
    .s_axis_tvalid  (gtp2gdma_tvalid),
    .s_axis_tready  (gtp2gdma_tready),
    .s_axis_tdata   (gtp2gdma_tdata[15:0]),
    .aclk           (clk),
    .aresetn        (~rst | ~stop_pkg),
    .aclken         (~stop_pkg),                // input wire aclken
    .m_axis_tvalid  (convert2gdma_tvalid),
    .m_axis_tready  (convert2gdma_tready),
    .m_axis_tdata   (convert2gdma_tdata)
);

endmodule
