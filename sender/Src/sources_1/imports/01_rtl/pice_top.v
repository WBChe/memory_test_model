`timescale 1ns / 1ps

/*******************************CWB-UESTC*******************************
*Author : Wenbin Che from UESTC
*Create Date: 2024/6/13
*File Name: pcie_top.v
*Description: 
*Declaration:
*********************************************************************/

 module pcie_top
(
  output [14:0]DDR3_addr,
  output [2:0]DDR3_ba,
  output DDR3_cas_n,
  output [0:0]DDR3_ck_n,
  output [0:0]DDR3_ck_p,
  output [0:0]DDR3_cke,
  output [0:0]DDR3_cs_n,
  output [7:0]DDR3_dm,
  inout [63:0]DDR3_dq,
  inout [7:0]DDR3_dqs_n,
  inout [7:0]DDR3_dqs_p,
  output [0:0]DDR3_odt,
  output DDR3_ras_n,
  output DDR3_reset_n,
  output DDR3_we_n,
  input  sysclk,//100mhz
  
  input  [7 :0]pcie_mgt_rxn,
  input  [7 :0]pcie_mgt_rxp,
  output [7 :0]pcie_mgt_txn,
  output [7 :0]pcie_mgt_txp,
  input  [0 :0]pcie_ref_clk_n,
  input  [0 :0]pcie_ref_clk_p,
  input pcie_rst_n,
  
  //gtx sys
  input  wire       gt_refclk1_p,
  input  wire       gt_refclk1_n,
  
  input wire            [1:0]   rxp,
  input wire            [1:0]   rxn,
  output wire           [1:0]   txp,
  output wire           [1:0]   txn,
  
  output wire sfpa_tx_dis,
  output wire sfpa_rs0,
  output wire sfpa_rs1,
  output wire sfpb_tx_dis,
  output wire sfpb_rs0,
  output wire sfpb_rs1,
  output wire sfpc_tx_dis,
  output wire sfpc_rs0,
  output wire sfpc_rs1,
  output wire sfpd_tx_dis,
  output wire sfpd_rs0,
  output wire sfpd_rs1
  
    );
    //clock
    wire locked;
    wire init_clk; //78.125
    wire ddr_sys_clk; //200
    //wire die0_clk;
    
      clk_wiz_0 gt_pll(
    .clk_out1(init_clk),     // output clk_out1 78.125
    .resetn(axi_areset_n),  // input resetn
    .clk_in1(axi_aclk)      // input clk_in1 250
    );      

      clk_wiz_1 pin_in_clk_pll (
    .clk_out1(die0_clk),     // output clk_out1 200
    .resetn(axi_areset_n), // input resetn
    .clk_in1(axi_aclk)  // input clk_in1 250
    );      
    
      clk_wiz_2 ddr_pll(
    .clk_out1(ddr_sys_clk),     // output clk_out1 200mhz
    .resetn(axi_areset_n), // input reset
    .locked(locked),
    .clk_in1(sysclk)// input clk_in1 100mhz
    ); 
    
    //gtx
    assign sfpa_tx_dis = 1'b0;
    assign sfpa_rs0    = 1'b1;
    assign sfpa_rs1    = 1'b1;
    assign sfpb_tx_dis = 1'b0;
    assign sfpb_rs0    = 1'b1;
    assign sfpb_rs1    = 1'b1;
    assign sfpc_tx_dis = 1'b0;
    assign sfpc_rs0    = 1'b1;
    assign sfpc_rs1    = 1'b1;
    assign sfpd_tx_dis = 1'b0;
    assign sfpd_rs0    = 1'b1;
    assign sfpd_rs1    = 1'b1;
    
    //pcie
    wire axi_aclk;
    wire [12:0]pcie2gdma_reg_addr;
    wire pcie2gdma_reg_clk;
    wire [31:0]pcie2gdma_reg_wrdata;
    wire [31:0]pcie2gdma_reg_rddata;
    wire pcie2gdma_reg_en;
    wire pcie2gdma_reg_rst;
    wire [3:0]pcie2gdma_reg_we;
    wire [31:0]func_out;
    wire [31:0]func_in;
    wire axi_areset_n;
    
    //gdma_pattern
    wire [32-1:0] gdma_pattern_araddr;
    wire [2-1:0]  gdma_pattern_arburst;
    wire [4-1:0]  gdma_pattern_arcache;
    wire [8-1:0]  gdma_pattern_arlen;
    wire [1-1:0]  gdma_pattern_arlock;
    wire [3-1:0]  gdma_pattern_arprot;
    wire [4-1:0]  gdma_pattern_arqos;
    wire [1-1:0]  gdma_pattern_arready;
    wire [4-1:0]  gdma_pattern_arregion;
    wire [3-1:0]  gdma_pattern_arsize;
    wire [1-1:0]  gdma_pattern_arvalid;
    wire [32-1:0] gdma_pattern_awaddr;
    wire [2-1:0]  gdma_pattern_awburst;
    wire [4-1:0]  gdma_pattern_awcache;
    wire [8-1:0]  gdma_pattern_awlen;
    wire [1-1:0]  gdma_pattern_awlock;
    wire [3-1:0]  gdma_pattern_awprot;
    wire [4-1:0]  gdma_pattern_awqos;
    wire [1-1:0]  gdma_pattern_awready;
    wire [4-1:0]  gdma_pattern_awregion;
    wire [3-1:0]  gdma_pattern_awsize;
    wire [1-1:0]  gdma_pattern_awvalid;
    wire [1-1:0]  gdma_pattern_bready;
    wire [2-1:0]  gdma_pattern_bresp;
    wire [1-1:0]  gdma_pattern_bvalid;
    wire [32-1:0] gdma_pattern_rdata;//128
    wire [1-1:0]  gdma_pattern_rlast;
    wire [1-1:0]  gdma_pattern_rready;
    wire [2-1:0]  gdma_pattern_rresp;
    wire [1-1:0]  gdma_pattern_rvalid;
    wire [32-1:0] gdma_pattern_wdata;//128
    wire [1-1:0]  gdma_pattern_wlast;
    wire [1-1:0]  gdma_pattern_wready;
    wire [4-1:0]  gdma_pattern_wstrb;
    wire [1-1:0]  gdma_pattern_wvalid;
   
    //regs
    wire [48:0] gdma0_start_rd_addr;
    wire [48:0] gdma0_start_wr_addr;
    wire [31:0] gdma0_rd_length;
    wire [31:0] gdma0_wr_length;
    wire [48:0] gdma1_start_rd_addr;
    wire [48:0] gdma1_start_wr_addr;
    wire [31:0] gdma1_rd_length;
    wire [31:0] gdma1_wr_length;
    wire [48:0] gdma2_start_rd_addr;
    wire [48:0] gdma2_start_wr_addr;
    wire [31:0] gdma2_rd_length;
    wire [31:0] gdma2_wr_length;
    wire [48:0] gdma3_start_rd_addr;
    wire [48:0] gdma3_start_wr_addr;
    wire [31:0] gdma3_rd_length;
    wire [31:0] gdma3_wr_length;
    wire [31:0] gdma_start;
    wire [31:0] tile_valid_length;
    wire [31:0] host_rst;
    //wire [31:0] direction_sel;
    wire [31:0] last_ctrl;
    wire [31:0]gdma_speed_divider; 
    
    
    wire gdma0_wr_done;
    wire gdma0_rd_done;
    wire gdma1_wr_done;
    wire gdma1_rd_done;
    
    wire gdma_clk;
    wire gdma_rst;
    
    assign gdma_clk = axi_aclk;
    assign gdma_rst = !axi_areset_n;
    
    //func_in
    wire [6-1:0]receve_packet_done;
    wire receve_pkg_done;
    assign receve_pkg_done=&receve_packet_done;
    assign func_in = {receve_pkg_done,gdma0_wr_done,gdma0_rd_done};
    
    //test pin
    //assign LED =0;
    
    //gdma soft rst
    wire h2gdma_rst;
    host2gdma_rst(
        .gdma_clk       (gdma_clk) ,
        .gdma_rst       (gdma_rst) ,
        .host_rst_flag  (host_rst[0]) ,
                        
        .h2gdma_rst     (h2gdma_rst)
        );
    
    
    
    pcie_system pcie_system_i(
        .DDR3_addr(DDR3_addr),
        .DDR3_ba(DDR3_ba),
        .DDR3_cas_n(DDR3_cas_n),
        .DDR3_ck_n(DDR3_ck_n),
        .DDR3_ck_p(DDR3_ck_p),
        .DDR3_cke(DDR3_cke),
        .DDR3_cs_n(DDR3_cs_n),
        .DDR3_dm(DDR3_dm),
        .DDR3_dq(DDR3_dq),
        .DDR3_dqs_n(DDR3_dqs_n),
        .DDR3_dqs_p(DDR3_dqs_p),
        .DDR3_odt(DDR3_odt),
        .DDR3_ras_n(DDR3_ras_n),
        .DDR3_reset_n(DDR3_reset_n),
        .DDR3_we_n(DDR3_we_n),
        .host_rst(host_rst[0]),   
        .pcie_mgt_rxn(pcie_mgt_rxn),
        .pcie_mgt_rxp(pcie_mgt_rxp),
        .pcie_mgt_txn(pcie_mgt_txn),
        .pcie_mgt_txp(pcie_mgt_txp),
        .pcie_ref_clk_n(pcie_ref_clk_n),
        .pcie_ref_clk_p(pcie_ref_clk_p),
        .pcie_rst_n(pcie_rst_n),
        .axi_aclk(axi_aclk),
        .axi_areset_n(axi_areset_n),
        .sys_clk(ddr_sys_clk),
        .gdma_pattern_araddr           (gdma_pattern_araddr),  
        .gdma_pattern_arburst          (gdma_pattern_arburst),    
        .gdma_pattern_arcache          (gdma_pattern_arcache),    
        .gdma_pattern_arid             ('h0),                  
        .gdma_pattern_arlen            (gdma_pattern_arlen),      
        .gdma_pattern_arlock           (gdma_pattern_arlock),     
        .gdma_pattern_arprot           (gdma_pattern_arprot),     
        .gdma_pattern_arqos            (gdma_pattern_arqos),      
        //.gdma_west_arregion         ('h0),                  
        .gdma_pattern_arready          (gdma_pattern_arready),    
        .gdma_pattern_arsize           (gdma_pattern_arsize),     
        .gdma_pattern_arvalid          (gdma_pattern_arvalid),    
        .gdma_pattern_awaddr           (gdma_pattern_awaddr),     
        .gdma_pattern_awburst          (gdma_pattern_awburst),    
        .gdma_pattern_awcache          (gdma_pattern_awcache),    
        .gdma_pattern_awid             ('h0),                  
        .gdma_pattern_awlen            (gdma_pattern_awlen),      
        .gdma_pattern_awlock           (gdma_pattern_awlock),     
        .gdma_pattern_awprot           (gdma_pattern_awprot),     
        .gdma_pattern_awqos            (gdma_pattern_awqos),      
        //.gdma_west_awregion         ('h0),                  
        .gdma_pattern_awready          (gdma_pattern_awready),    
        .gdma_pattern_awsize           (gdma_pattern_awsize),     
        .gdma_pattern_awvalid          (gdma_pattern_awvalid),    
        .gdma_pattern_bid              (),                     
        .gdma_pattern_bready           (gdma_pattern_bready),     
        .gdma_pattern_bresp            (gdma_pattern_bresp),      
        .gdma_pattern_bvalid           (gdma_pattern_bvalid),     
        .gdma_pattern_rdata            (gdma_pattern_rdata),      
        .gdma_pattern_rid              (),                     
        .gdma_pattern_rlast            (gdma_pattern_rlast),      
        .gdma_pattern_rready           (gdma_pattern_rready),     
        .gdma_pattern_rresp            (gdma_pattern_rresp),      
        .gdma_pattern_rvalid           (gdma_pattern_rvalid),     
        .gdma_pattern_wdata            (gdma_pattern_wdata),      
        .gdma_pattern_wlast            (gdma_pattern_wlast),      
        .gdma_pattern_wready           (gdma_pattern_wready),     
        .gdma_pattern_wstrb            (16'hffff), //gdma_west_wstrb     
        .gdma_pattern_wvalid           (gdma_pattern_wvalid),    
                             
        .pcie2gdma_reg_addr         (pcie2gdma_reg_addr),
        .pcie2gdma_reg_clk          (pcie2gdma_reg_clk),
        .pcie2gdma_reg_din          (pcie2gdma_reg_wrdata),
        .pcie2gdma_reg_dout         (pcie2gdma_reg_rddata),
        .pcie2gdma_reg_en           (pcie2gdma_reg_en),
        .pcie2gdma_reg_rst          (pcie2gdma_reg_rst),
        .pcie2gdma_reg_we           (pcie2gdma_reg_we)
    );
        

   
// ila_func ila_func (
//	.clk(gdma_clk), // input wire clk

//	.probe0(func_in), // input wire [31:0]  probe0  
//	.probe1(func_out) // input wire [31:0]  probe1
//);  

//ila_reg ila_reg (
//	.clk(gdma_clk), // input wire clk


//	.probe0(gdma_start[0]), // input wire [0:0]  probe0  
//	.probe1(gdma_start[1]), // input wire [0:0]  probe1 
//	.probe2(pcie2gdma_reg_we) // input wire [0:0]  probe2
//);


    wire        gdma2gtp_tvalid;
    wire        gdma2gtp_tready;
    wire [31:0] gdma2gtp_tdata ;
    wire        gdma2gtp_tlast ;
    
    wire        gtp2gdma_tvalid;
    wire        gtp2gdma_tready;
    wire [31:0] gtp2gdma_tdata ;
    wire        gdma_package_bypass;

    gdma gdma(
    	.gdma_clk          (gdma_clk),
    	.gdma_rst          (gdma_rst|h2gdma_rst),
    	.start_rd_addr     (gdma0_start_rd_addr),
    	.rd_length         (gdma0_rd_length),
    	.gdma_rd_start     (gdma_start[0]),
    	.gdma_rd_done      (gdma0_rd_done),
    	.start_wr_addr     (gdma0_start_wr_addr),
    	.wr_length         (gdma0_wr_length),
    	.gdma_wr_start     (gdma_start[1]),
    	.gdma_wr_done      (gdma0_wr_done),
    	.op_rd_start       (),
    	.op_wr_start       (),
    	.gdma_speed_divider(gdma_speed_divider),
    	.gdma_package_bypass (gdma_package_bypass),
    	.gdma2gtp_tvalid   (gdma2gtp_tvalid),
    	.gdma2gtp_tready   (gdma2gtp_tready),//
    	.gdma2gtp_tdata    (gdma2gtp_tdata),
    	.gdma2gtp_tlast    (gdma2gtp_tlast),
    	.gtp2gdma_tvalid   (gtp2gdma_tvalid),
    	.gtp2gdma_tready   (gtp2gdma_tready),
    	.gtp2gdma_tdata    (gtp2gdma_tdata),
    	//.tile_valid_length    (tile_valid_length),
    	.gdma_ddr_araddr   (gdma_pattern_araddr),
    	.gdma_ddr_arburst  (gdma_pattern_arburst),
    	.gdma_ddr_arcache  (gdma_pattern_arcache),
    	.gdma_ddr_arlen    (gdma_pattern_arlen),
    	.gdma_ddr_arlock   (gdma_pattern_arlock),
    	.gdma_ddr_arprot   (gdma_pattern_arprot),
    	.gdma_ddr_arqos    (gdma_pattern_arqos),
    	.gdma_ddr_arready  (gdma_pattern_arready),
    	.gdma_ddr_arregion (gdma_pattern_arregion),
    	.gdma_ddr_arsize   (gdma_pattern_arsize),
    	.gdma_ddr_arvalid  (gdma_pattern_arvalid),
    	.gdma_ddr_awaddr   (gdma_pattern_awaddr),
    	.gdma_ddr_awburst  (gdma_pattern_awburst),
    	.gdma_ddr_awcache  (gdma_pattern_awcache),
    	.gdma_ddr_awlen    (gdma_pattern_awlen),
    	.gdma_ddr_awlock   (gdma_pattern_awlock),
    	.gdma_ddr_awprot   (gdma_pattern_awprot),
    	.gdma_ddr_awqos    (gdma_pattern_awqos),
    	.gdma_ddr_awready  (gdma_pattern_awready),
    	.gdma_ddr_awregion (gdma_pattern_awregion),
    	.gdma_ddr_awsize   (gdma_pattern_awsize),
    	.gdma_ddr_awvalid  (gdma_pattern_awvalid),
    	.gdma_ddr_bready   (gdma_pattern_bready),
    	.gdma_ddr_bresp    (gdma_pattern_bresp),
    	.gdma_ddr_bvalid   (gdma_pattern_bvalid),
    	.gdma_ddr_rdata    (gdma_pattern_rdata),
    	.gdma_ddr_rlast    (gdma_pattern_rlast),
    	.gdma_ddr_rready   (gdma_pattern_rready),
    	.gdma_ddr_rresp    (gdma_pattern_rresp),
    	.gdma_ddr_rvalid   (gdma_pattern_rvalid),
    	.gdma_ddr_wdata    (gdma_pattern_wdata),
    	.gdma_ddr_wlast    (gdma_pattern_wlast),
    	.gdma_ddr_wready   (gdma_pattern_wready),
    	.gdma_ddr_wstrb    (gdma_pattern_wstrb),
    	.gdma_ddr_wvalid   (gdma_pattern_wvalid),
    	//new for spike packet
    	.last_ctrl         (last_ctrl[0])
    );

    gdma_reg gdma_reg(
    	.zynq2gdma_reg_clk    		(pcie2gdma_reg_clk),
    	.zynq2gdma_reg_rst    		(pcie2gdma_reg_rst),
    	.zynq2gdma_reg_addr   		(pcie2gdma_reg_addr),
    	.zynq2gdma_reg_wrdata 		(pcie2gdma_reg_wrdata),
    	.zynq2gdma_reg_rddata 		(pcie2gdma_reg_rddata),
    	.zynq2gdma_reg_en     		(pcie2gdma_reg_en),
    	.zynq2gdma_reg_we     		(pcie2gdma_reg_we),
    	.gdma0_start_rd_addr  		(gdma0_start_rd_addr),
    	.gdma0_rd_length      		(gdma0_rd_length),
    	.gdma0_start_wr_addr  		(gdma0_start_wr_addr),
    	.gdma0_wr_length      		(gdma0_wr_length),
    	.gdma1_start_rd_addr  		(gdma1_start_rd_addr),
    	.gdma1_rd_length      		(gdma1_rd_length),
    	.gdma1_start_wr_addr  		(gdma1_start_wr_addr),
    	.gdma1_wr_length      		(gdma1_wr_length),
    	.gdma2_start_rd_addr  		(gdma2_start_rd_addr),
    	.gdma2_rd_length      		(gdma2_rd_length),
    	.gdma2_start_wr_addr  		(gdma2_start_wr_addr),
    	.gdma2_wr_length      		(gdma2_wr_length),
    	.gdma3_start_rd_addr  		(gdma3_start_rd_addr),
    	.gdma3_rd_length      		(gdma3_rd_length),
    	.gdma3_start_wr_addr  		(gdma3_start_wr_addr),
    	.gdma3_wr_length      		(gdma3_wr_length),
    	.gdma0_rd_start       		(gdma_start[0]),
    	.gdma0_wr_start       		(gdma_start[1]),
    	.gdma1_rd_start       		(gdma_start[2]),
    	.gdma1_wr_start       		(gdma_start[3]),
    	.gdma2_rd_start       		(gdma_start[4]),
    	.gdma2_wr_start       		(gdma_start[5]),
    	.gdma3_rd_start       		(gdma_start[6]),
    	.gdma3_wr_start       		(gdma_start[7]),
    	.gdma_speed_divider         (gdma_speed_divider),
    	.gdma_package_bypass        (gdma_package_bypass),
    	.func_in                    (func_in),  
    	.func_out                   (func_out),
    	.power_ctr                  (power),
    	.tile_valid_length          (tile_valid_length),
    	.host_rst                   (host_rst),
    	//.direction_sel              (direction_sel)
    	.last_ctrl                  (last_ctrl)
    );

    
//    wire core2gtx_tlast = (last_ctrl[0] & gdma2gtp_tvalid_64)    ?    1'b1:   gdma2gtp_tlast_64[0];
    
    //aurora 32b
    wire [3:0] gtp_up;
    
    gtx_sys gtx_8b10b(
    	 .gt_refclk1_p      (gt_refclk1_p),
    	 .gt_refclk1_n      (gt_refclk1_n),
    	 .init_clk          (init_clk),
         .gtp_reset         (~axi_areset_n),
  
         .core_clk          (gdma_clk),
    	 .gtp_fifo_rst      (~axi_areset_n), 
         .gtx2core_tdata    (gtp2gdma_tdata ), //32b
    	 .gtx2core_tvalid   (gtp2gdma_tvalid),
    	 .gtx2core_tready   (gtp2gdma_tready),  
    	 .core2gtx_tdata    (gdma2gtp_tdata ),
         .core2gtx_tvalid   (gdma2gtp_tvalid), 
    	 .core2gtx_tready   (gdma2gtp_tready),
    	 .core2gtx_tlast    (gdma2gtp_tlast ),//gdma2gtp_tlast_64
    	 .gtp_up            (gtp_up),
    	 //gtx ports;
    	 .rxp               (rxp),
    	 .rxn               (rxn),
    	 .txp               (txp),
    	 .txn               (txn)
    );
    
    ila_gt_tx u_ila_gt_tx (
    	.clk(gdma_clk), // input wire clk
    	.probe0(gdma2gtp_tlast), // input wire [0:0]  probe0  
    	.probe1(gdma2gtp_tready), // input wire [0:0]  probe1 
    	.probe2(gdma2gtp_tvalid), // input wire [0:0]  probe2 
    	.probe3(gdma2gtp_tdata) // input wire [31:0]  probe3
    );
    
    ila_gt_rx u_ila_gt_rx (
    	.clk(gdma_clk), // input wire clk
    	.probe0(gtp2gdma_tready), // input wire [0:0]  probe0  
    	.probe1(gtp2gdma_tvalid), // input wire [0:0]  probe1 
    	.probe2(gtp2gdma_tdata) // input wire [31:0]  probe2
    );

    vio_gt u_vio_gt (
        .clk(gdma_clk),              // input wire clk
        .probe_in0(gtp_up)  // input wire [3 : 0] probe_in0
    );

   
    
endmodule
