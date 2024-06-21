`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/01 10:33:50
// Design Name: 
// Module Name: gtx_subsys
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


module gtx_subsys64b66b(
	input wire gt_refclk1,
	input wire init_clk,
	input wire gt_reset,
	input wire reset,
	//clock_wrapper
	output wire gt0_qpllreset_out,
    input  wire  gt_qpllclk_quad1_i,   
    input  wire  gt_qpllrefclk_quad1_i,  
    input  wire  gt0_qplllock_i,
    input  wire  gt0_qpllrefclklost_i,
   //lane port
   	input wire 		   core_clk,
	input wire 		   gtp_fifo_rst,
	output wire [63:0] gt2port_tdata,
	output wire 	   gt2port_tvalid,
	input wire 		   gt2port_tready,
	input wire [63:0]  core2gtp_tdata,
	input wire 		   core2gtp_tvalid,
	output wire 	   core2gtp_tready,
	input wire         core2gtp_tlast,
   
   //status;
	output wire channel_up,
	output wire lane_up,
	
   	input wire rxp,
	input wire rxn,
	output wire txp,
	output wire txn
    );
    
    
    wire               tx_out_clk_i;
    wire               sync_clk_i;
    wire               pll_not_locked_i;
    wire               tx_lock_i;
    
    wire               init_clk_i;
    
    wire               system_reset_i;
    wire               gt_reset_i;
    wire               drpclk_i;
    wire               reset_sync_user_clk;
    wire               gt_reset_sync_init_clk;



    wire user_clk;
    wire tx_lock;
    wire sync_clk;
    wire system_reset;
    wire sys_gt_reset;
    wire pll_not_locked;
    
    //core2gt
    wire        fifo2gt_tvalid ;         
    wire        fifo2gt_tready;           
    wire [63:0] fifo2gt_tdata ;
    wire        fifo2gt_tlast;
    //gt2core
    wire        gt2fifo_tvalid ;         
    wire        gt2fifo_tready;          
    wire [63:0] gt2fifo_tdata ;  
    wire        gt2fifo_tlast;
  
    assign init_clk_i = init_clk;

    // Instantiate a clock module for clock division.

    aurora_64b66b_1_CLOCK_MODULE clock_module_i
     (
 
//         .INIT_CLK_P(init_clk_p),
//         .INIT_CLK_N(init_clk_n),
 
//         .INIT_CLK_O(INIT_CLK_i),
         .CLK(tx_out_clk_i),
         .CLK_LOCKED(tx_lock_i),
         .USER_CLK(user_clk),
         .SYNC_CLK(sync_clk_i),
         .MMCM_NOT_LOCKED(pll_not_locked_i)
     );
  //  outputs
  assign init_clk_out          =  init_clk_i;
  assign pll_not_locked_out    =  pll_not_locked_i;

    assign gt_reset_sync_init_clk = gt_reset;

    aurora_64b66b_1_SUPPORT_RESET_LOGIC support_reset_logic_i
     (
         .RESET(reset),
         .USER_CLK(user_clk),
         .INIT_CLK(init_clk_i),
         .GT_RESET_IN(gt_reset_sync_init_clk),
         .SYSTEM_RESET(system_reset_i),
         .GT_RESET_OUT(gt_reset_i)
     );
     
//----- Instance of _xci -----[

aurora_64b66b_1 aurora_64b66b_1_i
     (
        // TX AXI4-S Interface
         .s_axi_tx_tdata        (fifo2gt_tdata),
         .s_axi_tx_tlast        (fifo2gt_tlast),
         .s_axi_tx_tkeep        (8'b11111111),
         .s_axi_tx_tvalid       (fifo2gt_tvalid),
         .s_axi_tx_tready       (fifo2gt_tready),

        // RX AXI4-S Interface
         .m_axi_rx_tdata(gt2fifo_tdata),
         .m_axi_rx_tlast(gt2fifo_tlast),
         .m_axi_rx_tkeep(),
         .m_axi_rx_tvalid(gt2fifo_tvalid),
  
         // GTX Serial I/O
         .rxp(rxp),
         .rxn(rxn),
         .txp(txp),
         .txn(txn),
 
         //GTX Reference Clock Interface
         .refclk1_in(gt_refclk1),
         .hard_err(),
         .soft_err(),

         // Status
         .channel_up(channel_up),
         .lane_up(lane_up),

         // System Interface
         .mmcm_not_locked(pll_not_locked_i),
         .user_clk(user_clk),
         .sync_clk(sync_clk_i),
         .reset_pb(system_reset_i),
         
         .gt_rxcdrovrden_in(gt_rxcdrovrden_in),
         
         .power_down(1'b0),
         .loopback(3'b000),
         .pma_init(gt_reset_i),
         .gt_pll_lock(tx_lock_i),
         .drp_clk_in(init_clk_i),
//---{
       .gt_qpllclk_quad1_in       (gt_qpllclk_quad1_i          ), 
       .gt_qpllrefclk_quad1_in    (gt_qpllrefclk_quad1_i       ),    

       .gt_to_common_qpllreset_out  (gt0_qpllreset_out    ),
       .gt_qplllock_in       (gt0_qplllock_i        ), 
       .gt_qpllrefclklost_in (gt0_qpllrefclklost_i  ),       
//---}
     // ---------- AXI4-Lite input signals ---------------
         .drpaddr_in(8'h0),
         .drpdi_in(16'h0),
         .drpdo_out(), 
         .drprdy_out(), 
         .drpen_in(1'b0), 
         .drpwe_in(1'b0), 
    //---------------------- GTXE2 COMMON DRP Ports ----------------------
         .qpll_drpaddr_in('b0),
         .qpll_drpdi_in('b0),
         .qpll_drpdo_out(), 
         .qpll_drprdy_out(), 
         .qpll_drpen_in('b0), 
         .qpll_drpwe_in('b0), 
         .init_clk(init_clk),
         .link_reset_out(),
         .sys_reset_out                            (sys_reset_out),
         .tx_out_clk                               (tx_out_clk_i)
     );


    //core2gt_fifo tx
    gtx32_data_fifo core2gt_fifo (
      .s_axis_aresetn(~gt_reset),  // input wire s_axis_aresetn
      .s_axis_aclk(core_clk),        // input wire s_axis_aclk
      .s_axis_tvalid(core2gtp_tvalid),    // input wire s_axis_tvalid
      .s_axis_tready(core2gtp_tready),    // output wire s_axis_tready
      .s_axis_tdata(core2gtp_tdata),      // input wire [31 : 0] s_axis_tdata
      .s_axis_tlast(core2gtp_tlast),
      .m_axis_aclk(user_clk),        // input wire m_axis_aclk
      .m_axis_tvalid(fifo2gt_tvalid),    // output wire m_axis_tvalid
      .m_axis_tready(fifo2gt_tready),    // input wire m_axis_tready
      .m_axis_tdata(fifo2gt_tdata),     // output wire [31 : 0] m_axis_tdata
      .m_axis_tlast(fifo2gt_tlast)      // output wire m_axis_tlast
    );
    //gt2core_fifo rx
    gtx32_data_fifo gt2core_fifo (
      .s_axis_aresetn(~gt_reset),  // input wire s_axis_aresetn
      .s_axis_aclk(user_clk),        // input wire s_axis_aclk
      .s_axis_tvalid(gt2fifo_tvalid),    // input wire s_axis_tvalid
      .s_axis_tready(gt2fifo_tready),    // output wire s_axis_tready
      .s_axis_tdata(gt2fifo_tdata),      // input wire [31 : 0] s_axis_tdata
      .s_axis_tlast(gt2fifo_tlast),
      .m_axis_aclk(core_clk),        // input wire m_axis_aclk
      .m_axis_tvalid(gt2port_tvalid),    // output wire m_axis_tvalid
      .m_axis_tready(gt2port_tready),    // input wire m_axis_tready
      .m_axis_tdata(gt2port_tdata),     // output wire [31 : 0] m_axis_tdata
      .m_axis_tlast()
    );


//ila_last u_ila_last (
//	.clk(user_clk), // input wire clk
//	.probe0(core2gtp_tlast), // input wire [0:0]  probe0  
//	.probe1(fifo2gt_tlast) // input wire [0:0]  probe1
//);
////ila
//gtx_ila gtx_ila_tx (
//	.clk(user_clk), // input wire clk
//	.probe0(fifo2gt_tvalid), // input wire [0:0]  probe0  
//	.probe1(fifo2gt_tdata) // input wire [31:0]  probe1
//);

//gtx_ila gtx_ila_rx (
//	.clk(user_clk), // input wire clk
//	.probe0(gt2fifo_tvalid), // input wire [0:0]  probe0  
//	.probe1(gt2fifo_tdata) // input wire [31:0]  probe1
//);

endmodule
