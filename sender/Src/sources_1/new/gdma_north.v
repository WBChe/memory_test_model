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

module gdma_north(
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
    
    input wire         extern_spike,
    input wire         stop_pkg
    
);
wire gdma_araddr_done;
wire gdma_awaddr_done;

north_awraddr gdma_araddr(
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



north_rdata gdma_rdata(
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
    .extern_spike          (extern_spike)
);

north_awraddr gdma_awaddr(
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

north_wdata gdma_wdata(
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
	.gtp2gdma_tdata  (gtp2gdma_tdata),
	.stop_pkg        (stop_pkg)
);

endmodule
