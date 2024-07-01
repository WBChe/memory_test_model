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


module gdma_wdata(
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
    output wire [31:0]  gdma_ddr_wdata,
    output wire         gdma_ddr_wlast,
    input wire          gdma_ddr_wready,
    output wire [3:0]   gdma_ddr_wstrb,
    output wire         gdma_ddr_wvalid,
//
    input wire         gtp2gdma_tvalid,
    output wire        gtp2gdma_tready,
    input wire [31:0]  gtp2gdma_tdata
);
reg [46:0] waddr_cnt;
reg [7:0] wdata_burst_cnt;
reg [29:0] wdata_cnt;
reg [2:0]filter_packet_cnt;
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
assign gtp2gdma_tready = gdma_ddr_wready;
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
assign gdma_ddr_wvalid = convert2gdma_tvalid && ~wdata_done;
assign convert2gdma_tready = gdma_ddr_wready && ~wdata_done;
assign gdma_ddr_wlast = (wdata_4k_last || wdata_burst_last || wdata_last) && gdma_ddr_wvalid;
assign gdma_ddr_wdata = convert2gdma_tdata;
//write address counter for 4k detection;
assign wdata_4k_last = (waddr_cnt[9:0]==10'h3FF);
assign wdata_burst_last = (wdata_burst_cnt==8'hFF);
assign wdata_last = (wdata_cnt[29:0]==length[31:2]);

//assign convert2gdma_tvalid =(filter_packet_cnt>1)?gtp2gdma_tvalid:1'b0;
assign convert2gdma_tvalid =gtp2gdma_tvalid;
assign convert2gdma_tdata = gtp2gdma_tdata;


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

//new change 24.7.1
//always@(posedge clk or posedge rst) begin
//    if(rst)
//        filter_packet_cnt <= 3'b0;
//    else if(op_start)
//        filter_packet_cnt <= 3'b0;
//    else if(gtp2gdma_tvalid && gtp2gdma_tready && (filter_packet_cnt<2)) 
//        filter_packet_cnt <= filter_packet_cnt + 1'b1;
//end

// ila_ddr_rdata ila_ddr_rdata (
//	.clk(clk), // input wire clk


//	.probe0(gdma_ddr_wdata), // input wire [31:0]  probe0  
//	.probe1(gtp2gdma_tdata), // input wire [31:0]  probe1 
//	.probe2(filter_packet_cnt), // input wire [1:0]  probe2 
//	.probe3(gdma_ddr_wlast), // input wire [0:0]  probe3 
//	.probe4(gdma_ddr_wready), // input wire [0:0]  probe4 
//	.probe5(gdma_ddr_wvalid), // input wire [0:0]  probe5 
//	.probe6(gtp2gdma_tvalid), // input wire [0:0]  probe6 
//	.probe7(gtp2gdma_tready) // input wire [0:0]  probe7
//);
//gdma_wdata_width_converter gdma_wdata_width_converter(
//    .s_axis_tvalid  (gtp2gdma_tvalid),
//    .s_axis_tready  (gtp2gdma_tready),
//    .s_axis_tdata   (gtp2gdma_tdata[15:0]),
//    .aclk           (clk),
//    .aresetn        (~rst),
//    .m_axis_tvalid  (convert2gdma_tvalid),
//    .m_axis_tready  (convert2gdma_tready),
//    .m_axis_tdata   (convert2gdma_tdata)
//);

endmodule
