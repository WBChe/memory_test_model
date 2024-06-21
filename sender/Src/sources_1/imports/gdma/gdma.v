`timescale 1ns / 1ps
//`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2020 11:29:33 AM
// Design Name: 
// Module Name: gdma
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

module gdma(
    input wire gdma_clk,
    input wire gdma_rst,
//
    input wire [48:0]   start_rd_addr,
    input wire [31:0]   rd_length,
    input wire          gdma_rd_start,
    output wire         gdma_rd_done,
    input wire [48:0]   start_wr_addr,
    input wire [31:0]   wr_length,
    input wire          gdma_wr_start,
    output wire         gdma_wr_done,
    output wire         op_rd_start,
    output wire         op_wr_start,
//
    input wire [31:0]   gdma_speed_divider,
    input wire          gdma_package_bypass,
//
    output wire         gdma2gtp_tvalid,
    input wire          gdma2gtp_tready,
    output wire [31:0]  gdma2gtp_tdata,
    output wire         gdma2gtp_tlast,
    input wire          gtp2gdma_tvalid,
    output wire         gtp2gdma_tready,
    input wire [31:0]   gtp2gdma_tdata,
//
    output wire [49-1:0] gdma_ddr_araddr,
    output wire [2-1:0]  gdma_ddr_arburst,
    output wire [4-1:0]  gdma_ddr_arcache,
    output wire [8-1:0]  gdma_ddr_arlen,
    output wire [1-1:0]  gdma_ddr_arlock,
    output wire [3-1:0]  gdma_ddr_arprot,
    output wire [4-1:0]  gdma_ddr_arqos,
    input wire [1-1:0]   gdma_ddr_arready,
    output wire [4-1:0]  gdma_ddr_arregion,
    output wire [3-1:0]  gdma_ddr_arsize,
    output wire [1-1:0]  gdma_ddr_arvalid,
    output wire [49-1:0] gdma_ddr_awaddr,
    output wire [2-1:0]  gdma_ddr_awburst,
    output wire [4-1:0]  gdma_ddr_awcache,
    output wire [8-1:0]  gdma_ddr_awlen,
    output wire [1-1:0]  gdma_ddr_awlock,
    output wire [3-1:0]  gdma_ddr_awprot,
    output wire [4-1:0]  gdma_ddr_awqos,
    input wire [1-1:0]   gdma_ddr_awready,
    output wire [4-1:0]  gdma_ddr_awregion,
    output wire [3-1:0]  gdma_ddr_awsize,
    output wire [1-1:0]  gdma_ddr_awvalid,
    output wire [1-1:0]  gdma_ddr_bready,
    input wire [2-1:0]   gdma_ddr_bresp,
    input wire [1-1:0]   gdma_ddr_bvalid,
    input wire [32-1:0]  gdma_ddr_rdata,
    input wire [1-1:0]   gdma_ddr_rlast,
    output wire [1-1:0]  gdma_ddr_rready,
    input wire [2-1:0]   gdma_ddr_rresp,
    input wire [1-1:0]   gdma_ddr_rvalid,
    output wire [32-1:0] gdma_ddr_wdata,
    output wire [1-1:0]  gdma_ddr_wlast,
    input wire [1-1:0]   gdma_ddr_wready,
    output wire [4-1:0]  gdma_ddr_wstrb,
    output wire [1-1:0]  gdma_ddr_wvalid,
    
    input wire last_ctrl
);
wire gdma_araddr_done;
wire gdma_awaddr_done;

gdma_awraddr gdma_araddr(
	.clk                (gdma_clk),
	.rst                (gdma_rst),
	.start_addr         (start_rd_addr),
	.length             (rd_length),
	.gdma_start         (gdma_rd_start),
	.op_start           (op_rd_start),
	.gdma_addr_done     (gdma_araddr_done),
	.gdma_ddr_awraddr   (gdma_ddr_araddr),
	.gdma_ddr_awrburst  (gdma_ddr_arburst),
	.gdma_ddr_awrcache  (gdma_ddr_arcache),
	.gdma_ddr_awrlen    (gdma_ddr_arlen),
	.gdma_ddr_awrlock   (gdma_ddr_arlock),
	.gdma_ddr_awrprot   (gdma_ddr_arprot),
	.gdma_ddr_awrqos    (gdma_ddr_arqos),
	.gdma_ddr_awrready  (gdma_ddr_arready),
	.gdma_ddr_awrregion (gdma_ddr_arregion),
	.gdma_ddr_awrsize   (gdma_ddr_arsize),
	.gdma_ddr_awrvalid  (gdma_ddr_arvalid)
);



gdma_rdata gdma_rdata(
	.clk                   (gdma_clk),
	.rst                   (gdma_rst),
	.length                (rd_length),
	.op_start              (op_rd_start),
	.gdma_speed_divider    (gdma_speed_divider),
	.gdma_package_bypass   (gdma_package_bypass),
	.gdma_addr_done        (gdma_araddr_done),
	.gdma_done             (gdma_rd_done),
	.gdma_ddr_rdata        (gdma_ddr_rdata),
	.gdma_ddr_rlast        (gdma_ddr_rlast),
	.gdma_ddr_rready       (gdma_ddr_rready),
	.gdma_ddr_rresp        (gdma_ddr_rresp),
	.gdma_ddr_rvalid       (gdma_ddr_rvalid),
	.gdma2gtp_tvalid       (gdma2gtp_tvalid),
	.gdma2gtp_tready       (gdma2gtp_tready),//gdma2gtp_tready
	.gdma2gtp_tdata        (gdma2gtp_tdata),
	.gdma2gtp_tlast        (gdma2gtp_tlast),
	
	.last_ctrl             (last_ctrl)
);

// ila_ddr_rdata ila_ddr_rdata (
//	.clk(gdma_clk), // input wire clk


//	.probe0(gdma_ddr_rdata), // input wire [31:0]  probe0  
//	.probe1(gdma2gtp_tdata), // input wire [31:0]  probe1 
//	.probe2(gdma_ddr_rresp), // input wire [1:0]  probe2 
//	.probe3(gdma_ddr_rlast), // input wire [0:0]  probe3 
//	.probe4(gdma_ddr_rready), // input wire [0:0]  probe4 
//	.probe5(gdma_ddr_rvalid), // input wire [0:0]  probe5 
//	.probe6(gdma2gtp_tvalid), // input wire [0:0]  probe6 
//	.probe7(gdma2gtp_tready) // input wire [0:0]  probe7
//);
// ila_ddr_rdata ila_ddr_rdata (
//	.clk(gdma_clk), // input wire clk


//	.probe0(gdma_ddr_wdata), // input wire [31:0]  probe0  
//	.probe1(gtp2gdma_tdata), // input wire [31:0]  probe1 
//	.probe2(gdma_ddr_wresp), // input wire [1:0]  probe2 
//	.probe3(gdma_ddr_wlast), // input wire [0:0]  probe3 
//	.probe4(gdma_ddr_wready), // input wire [0:0]  probe4 
//	.probe5(gdma_ddr_wvalid), // input wire [0:0]  probe5 
//	.probe6(gtp2gdma_tvalid), // input wire [0:0]  probe6 
//	.probe7(gtp2gdma_tready) // input wire [0:0]  probe7
//);
    
gdma_awraddr gdma_awaddr(
	.clk                (gdma_clk),
	.rst                (gdma_rst),
	.start_addr         (start_wr_addr),
	.length             (wr_length),
	.gdma_start         (gdma_wr_start),
	.op_start           (op_wr_start),
	.gdma_addr_done     (gdma_awaddr_done),
	.gdma_ddr_awraddr   (gdma_ddr_awaddr),
	.gdma_ddr_awrburst  (gdma_ddr_awburst),
	.gdma_ddr_awrcache  (gdma_ddr_awcache),
	.gdma_ddr_awrlen    (gdma_ddr_awlen),
	.gdma_ddr_awrlock   (gdma_ddr_awlock),
	.gdma_ddr_awrprot   (gdma_ddr_awprot),
	.gdma_ddr_awrqos    (gdma_ddr_awqos),
	.gdma_ddr_awrready  (gdma_ddr_awready),
	.gdma_ddr_awrregion (gdma_ddr_awregion),
	.gdma_ddr_awrsize   (gdma_ddr_awsize),
	.gdma_ddr_awrvalid  (gdma_ddr_awvalid)
);

//ila_ar ila_aw (
//	.clk(gdma_clk), // input wire clk


//	.probe0(start_wr_addr), // input wire [31:0]  probe0  
//	.probe1(wr_length), // input wire [31:0]  probe1 
//	.probe2(gdma_ddr_awaddr), // input wire [31:0]  probe2 
//	.probe3(gdma_ddr_awlen), // input wire [7:0]  probe3 
//	.probe4(gdma_ddr_awburst), // input wire [1:0]  probe4 
//	.probe5(gdma_wr_start), // input wire [0:0]  probe5 
//	.probe6(gdma_awaddr_done), // input wire [0:0]  probe6 
//	.probe7(gdma_ddr_awready), // input wire [0:0]  probe7 
//	.probe8(op_wd_start), // input wire [0:0]  probe8 
//	.probe9(gdma_ddr_awvalid) // input wire [0:0]  probe9
//);

//ila_ar ila_ar (
//	.clk(gdma_clk), // input wire clk


//	.probe0(start_rd_addr), // input wire [31:0]  probe0  
//	.probe1(rd_length), // input wire [31:0]  probe1 
//	.probe2(gdma_ddr_araddr), // input wire [31:0]  probe2 
//	.probe3(gdma_ddr_arlen), // input wire [7:0]  probe3 
//	.probe4(gdma_ddr_arburst), // input wire [1:0]  probe4 
//	.probe5(gdma_rd_start), // input wire [0:0]  probe5 
//	.probe6(gdma_araddr_done), // input wire [0:0]  probe6 
//	.probe7(gdma_ddr_arready), // input wire [0:0]  probe7 
//	.probe8(op_rd_start), // input wire [0:0]  probe8 
//	.probe9(gdma_ddr_arvalid) // input wire [0:0]  probe9
//);


gdma_wdata gdma_wdata(
	.clk             (gdma_clk),
	.rst             (gdma_rst),
	.start_addr      (start_wr_addr),
	.length          (wr_length),
	.op_start        (op_wr_start),
	.gdma_addr_done  (gdma_awaddr_done),
	.gdma_done       (gdma_wr_done),
	.gdma_ddr_bready (gdma_ddr_bready),
	.gdma_ddr_bresp  (gdma_ddr_bresp),
	.gdma_ddr_bvalid (gdma_ddr_bvalid),
	.gdma_ddr_wdata  (gdma_ddr_wdata),
	.gdma_ddr_wlast  (gdma_ddr_wlast),
	.gdma_ddr_wready (gdma_ddr_wready),
	.gdma_ddr_wstrb  (gdma_ddr_wstrb),
	.gdma_ddr_wvalid (gdma_ddr_wvalid),
	.gtp2gdma_tvalid (gtp2gdma_tvalid),
	.gtp2gdma_tready (gtp2gdma_tready),
	.gtp2gdma_tdata  (gtp2gdma_tdata)
);






//gdma_awraddr_ila gdma_awraddr_ila(
//    .clk    (gdma_clk),
//    .probe0 (gdma_ddr_araddr),
//    .probe1 (gdma_ddr_arlen),
//    .probe2 (gdma_ddr_arvalid),
//    .probe3 (gdma_ddr_arready),
//    .probe4 (gdma_ddr_awaddr),
//    .probe5 (gdma_ddr_awlen),
//    .probe6 (gdma_ddr_awvalid),
//    .probe7 (gdma_ddr_awready)
//);

//gdma_rwdata_ila gdma_rwdata_ila(
//    .clk    (gdma_clk),
//    .probe0 (gdma_ddr_rdata),
//    .probe1 (gdma_ddr_rready),
//    .probe2 (gdma_ddr_rvalid),
//    .probe3 (gdma_ddr_wdata),
//    .probe4 (gdma_ddr_wready),
//    .probe5 (gdma_ddr_wvalid)
//);

endmodule
