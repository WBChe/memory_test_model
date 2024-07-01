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


module gtx_subsys(
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
	output wire [31:0] gt2port_tdata,
	output wire 	   gt2port_tvalid,
	input wire 		   gt2port_tready,
	input wire [31:0]  core2gtp_tdata,
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
    wire [31:0] fifo2gt_tdata ;
    wire        fifo2gt_tlast;
    //gt2core
    wire        gt2fifo_tvalid ;         
    wire        gt2fifo_tready;          
    wire [31:0] gt2fifo_tdata ;  
    wire        gt2fifo_tlast;
  
    assign init_clk_i = init_clk;

    // Instantiate a clock module for clock division.
    aurora_8b10b_0_CLOCK_MODULE clock_module_i
    (
//        .INIT_CLK_P(init_clk_p),
//        .INIT_CLK_N(init_clk_n),
//        .INIT_CLK_O(init_clk_i),
        .GT_CLK(tx_out_clk_i),
        .GT_CLK_LOCKED(tx_lock_i),
        .USER_CLK(user_clk),
        .SYNC_CLK(sync_clk_i),
        .PLL_NOT_LOCKED(pll_not_locked_i)
    );

  //  outputs
  assign init_clk_out          =  init_clk_i;
  assign pll_not_locked_out    =  pll_not_locked_i;

    assign gt_reset_sync_init_clk = gt_reset;
    aurora_8b10b_0_SUPPORT_RESET_LOGIC support_reset_logic_i
    (
        .RESET(reset),
        .USER_CLK(user_clk),
        .INIT_CLK_IN(init_clk_i),
        .GT_RESET_IN(gt_reset_sync_init_clk),
        .SYSTEM_RESET(system_reset_i),
        .GT_RESET_OUT(gt_reset_i)
    );
    
//----- Instance of _xci -----[
aurora_8b10b_0 aurora_8b10b_0_i
     (
        // AXI TX Interface
       .s_axi_tx_tdata               (fifo2gt_tdata),
       .s_axi_tx_tkeep               (4'b1111),
       .s_axi_tx_tvalid              (fifo2gt_tvalid),
       .s_axi_tx_tlast               (fifo2gt_tlast),
       .s_axi_tx_tready              (fifo2gt_tready),

        // AXI RX Interface
       .m_axi_rx_tdata               (gt2fifo_tdata),
       .m_axi_rx_tkeep               (),
       .m_axi_rx_tvalid              (gt2fifo_tvalid),
       .m_axi_rx_tlast               (gt2fifo_tlast),


        // GT Serial I/O
       .rxp                          (rxp),
       .rxn                          (rxn),
       .txp                          (txp),
       .txn                          (txn),

        // GT Reference Clock Interface
       .gt_refclk1                   (gt_refclk1),
        // Error Detection Interface
       .frame_err                    (),

        // Error Detection Interface
       .hard_err                     (),
       .soft_err                     (),

        // Status
       .channel_up                   (channel_up),
       .lane_up                      (lane_up),




        // System Interface
       .user_clk                     (user_clk),
       .sync_clk                     (sync_clk_i),
       .reset                        (system_reset_i),
       .power_down                   (1'b0),
       .loopback                     (3'b000),
       .gt_reset                     (gt_reset_i),
       .tx_lock                      (tx_lock_i),
       .init_clk_in                  (init_clk_i),
       .pll_not_locked               (pll_not_locked_i),
       .tx_resetdone_out             (tx_resetdone_i),
       .rx_resetdone_out             (rx_resetdone_i),
       .link_reset_out               (),
       .drpclk_in                    (init_clk_i),
       .drpaddr_in                   (9'h0),
       .drpen_in                     (1'b0),
       .drpdi_in                     (16'h0),
       .drprdy_out                   (),
       .drpdo_out                    (),
       .drpwe_in                     (1'b0),

//------------------{
//_________________COMMON PORTS _______________________________{
//    ------------------------- Common Block - QPLL Ports ------------------------
.gt0_qplllock_in        (gt0_qplllock_i),
.gt0_qpllrefclklost_in  (gt0_qpllrefclklost_i),
.gt0_qpllreset_out      (gt0_qpllreset_out),
.gt_qpllclk_quad1_in (gt_qpllclk_quad1_i ),
.gt_qpllrefclk_quad1_in (gt_qpllrefclk_quad1_i ),
//____________________________COMMON PORTS ,_______________________________}
//------------------}


       .sys_reset_out                (sys_reset_out),
       .tx_out_clk                   (tx_out_clk_i)

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

////ila

ila_subsys subsys_rx (
	.clk(user_clk), // input wire clk
	.probe0(gt2fifo_tready), // input wire [0:0]  probe0  
	.probe1(gt2fifo_tvalid), // input wire [0:0]  probe1 
	.probe2(gt2fifo_tdata) // input wire [31:0]  probe2
);

endmodule
