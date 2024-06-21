`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/18 15:54:40
// Design Name: 
// Module Name: gtp_subsys
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


module gtp_subsys(
    input wire gt_refclk1,
	input wire init_clk,
	input wire gt_reset,
	input wire reset,
	
	//clock_wrapper
	output wire common_reset_i           ,
    input  wire gt0_pll0outclk_i         ,
    input  wire gt0_pll1outclk_i         ,
    input  wire gt0_pll0outrefclk_i      ,
    input  wire gt0_pll1outrefclk_i      ,
    input  wire quad1_common_lock_i      ,
    input  wire quad1_common_pll1_lock_i ,
    input  wire gt0_pll0refclklost_i     ,
	
   //lane port
   	input  wire 		   core_clk,
	input  wire 		   gtp_fifo_rst,
	
	output wire [31:0]     gt2port_tdata,
	output wire 	       gt2port_tvalid,
	input  wire 		   gt2port_tready,
	output wire            gt2port_tlast,
	
	input  wire [31:0]     core2gtp_tdata,
	input  wire 		   core2gtp_tvalid,
	output wire 	       core2gtp_tready,
	input  wire            core2gtp_tlast,
   
   //status;
	output wire channel_up,
	output wire lane_up,
	
   	input  wire rxp,
	input  wire rxn,
	output wire txp,
	output wire txn
	
    );
    //wire reg
    wire init_clk_i;
    assign init_clk_i = init_clk;
    wire sys_reset_out;
    
    wire tx_out_clk_i;
    wire tx_lock_i;
    wire user_clk_i;
    wire sync_clk_i;
    wire pll_not_locked_i;
    
    // Instantiate a clock module for clock division.
    aurora_8b10b_0_CLOCK_MODULE clock_module_i
    (
        //.INIT_CLK_P(init_clk_p),
        //.INIT_CLK_N(init_clk_n),
        //.INIT_CLK_O(init_clk_i),
        .GT_CLK(tx_out_clk_i),
        .GT_CLK_LOCKED(tx_lock_i),
        .USER_CLK(user_clk_i),
        .SYNC_CLK(sync_clk_i),
        .PLL_NOT_LOCKED(pll_not_locked_i)
    );
    
    //reset
    wire system_reset_i;
    wire gt_reset_i;
        aurora_8b10b_0_SUPPORT_RESET_LOGIC support_reset_logic_i
    (
        .RESET(reset),
        .USER_CLK(user_clk_i),
        .INIT_CLK_IN(init_clk_i),
        .GT_RESET_IN(gt_reset),
        .SYSTEM_RESET(system_reset_i),
        .GT_RESET_OUT(gt_reset_i)
    );
    
//----- Instance of _xci -----[
    wire [31:0] s_axi_tx_tdata    ;
    wire        s_axi_tx_tkeep    ;
    wire        s_axi_tx_tvalid   ;
    wire        s_axi_tx_tlast    ;
    wire        s_axi_tx_tready   ;
    
    wire [31:0] m_axi_rx_tdata     ;
    wire        m_axi_rx_tkeep     ;
    wire        m_axi_rx_tvalid    ;
    wire        m_axi_rx_tlast     ;
    
    
    
    
    aurora_8b10b_0 aurora_8b10b_0_i
     (
        // AXI TX Interface
       .s_axi_tx_tdata               (s_axi_tx_tdata),
       .s_axi_tx_tkeep               (4'b1111),
       .s_axi_tx_tvalid              (s_axi_tx_tvalid),
       .s_axi_tx_tlast               (s_axi_tx_tlast),
       .s_axi_tx_tready              (s_axi_tx_tready),

        // AXI RX Interface
       .m_axi_rx_tdata               (m_axi_rx_tdata),
       .m_axi_rx_tkeep               (m_axi_rx_tkeep),
       .m_axi_rx_tvalid              (m_axi_rx_tvalid),
       .m_axi_rx_tlast               (m_axi_rx_tlast),


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
       .user_clk                     (user_clk_i),
       .sync_clk                     (sync_clk_i),
       .reset                        (system_reset_i),
       .power_down                   (1'b0),
       .loopback                     (3'b000),
       .gt_reset                     (gt_reset_i),
       .tx_lock                      (tx_lock_i),
       .init_clk_in                  (init_clk_i),
       .pll_not_locked               (pll_not_locked_i),
       .tx_resetdone_out             (),
       .rx_resetdone_out             (),
       .link_reset_out               (),
       .drpclk_in                    (init_clk_i),
       .drpaddr_in                   ('b0),
       .drpen_in                     ('b0),
       .drpdi_in                     ('b0),
       .drprdy_out                   (),
       .drpdo_out                    (),
       .drpwe_in                     ('b0),

       //------------------{
       .gt_common_reset_out (common_reset_i),
       //____________________________COMMON PORTS_______________________________{
       .gt0_pll0refclklost_in (gt0_pll0refclklost_i ),
       .quad1_common_lock_in (quad1_common_lock_i ),
       //----------------------- Channel - Ref Clock Ports ------------------------
       .gt0_pll0outclk_in (gt0_pll0outclk_i ),
       .gt0_pll1outclk_in (gt0_pll1outclk_i ),
       .gt0_pll0outrefclk_in (gt0_pll0outrefclk_i ),
       .gt0_pll1outrefclk_in (gt0_pll1outrefclk_i ),
       //____________________________COMMON PORTS_______________________________}
       //------------------}


       .sys_reset_out                (sys_reset_out),
       .tx_out_clk                   (tx_out_clk_i)

     );
    
    //tx fifo
    gtp32_fifo gtp32_fifo_tx (
      .s_axis_aresetn(!gt_reset),  // input wire s_axis_aresetn
      .s_axis_aclk(core_clk),        // input wire s_axis_aclk
      .s_axis_tvalid(core2gtp_tvalid),    // input wire s_axis_tvalid
      .s_axis_tready(core2gtp_tready),    // output wire s_axis_tready
      .s_axis_tdata(core2gtp_tdata),      // input wire [31 : 0] s_axis_tdata
      .s_axis_tlast(core2gtp_tlast),      // input wire s_axis_tlast
      .m_axis_aclk(user_clk_i),        // input wire m_axis_aclk
      .m_axis_tvalid(s_axi_tx_tvalid),    // output wire m_axis_tvalid
      .m_axis_tready(s_axi_tx_tready),    // input wire m_axis_tready
      .m_axis_tdata(s_axi_tx_tdata),      // output wire [31 : 0] m_axis_tdata
      .m_axis_tlast(s_axi_tx_tlast)      // output wire m_axis_tlast
    );
    
    //rx fifo
    gtp32_fifo gtp32_fifo_rx (
      .s_axis_aresetn(!gt_reset),  // input wire s_axis_aresetn
      .s_axis_aclk(user_clk_i),        // input wire s_axis_aclk
      .s_axis_tvalid(m_axi_rx_tvalid),    // input wire s_axis_tvalid
      .s_axis_tready(m_axi_rx_tready),    // output wire s_axis_tready
      .s_axis_tdata(m_axi_rx_tdata),      // input wire [31 : 0] s_axis_tdata
      .s_axis_tlast(m_axi_rx_tlast),      // input wire s_axis_tlast
      .m_axis_aclk(core_clk),        // input wire m_axis_aclk
      .m_axis_tvalid(gt2port_tvalid),    // output wire m_axis_tvalid
      .m_axis_tready(gt2port_tready),    // input wire m_axis_tready
      .m_axis_tdata(gt2port_tdata),      // output wire [31 : 0] m_axis_tdata
      .m_axis_tlast(gt2port_tlast)      // output wire m_axis_tlast
    );
    
endmodule
