`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/01 10:27:04
// Design Name: 
// Module Name: gtx_sys
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

module gtx_sys_64b66b(
	input wire             gt_refclk1_p,
	input wire             gt_refclk1_n,
	input wire             init_clk,
    input wire             gtp_reset,
	
	//gtx data lanes (0:N,1:E,2:S,3:W);
	input  wire            core_clk,
	input  wire [3:0]      gtp_fifo_rst,
	
	output wire [64*4-1:0] gtx2core_tdata,
	output wire [3:0]      gtx2core_tvalid,
	input  wire [3:0]      gtx2core_tready,
	
	input  wire [64*4-1:0] core2gtx_tdata,
	input  wire [3:0]      core2gtx_tvalid,
	output wire [3:0]      core2gtx_tready,
	input  wire [3:0]      core2gtx_tlast,
	
	output wire [3:0]      gtp_up,
	
	//gtx ports;
	input  wire [3:0]      rxp,
	input  wire [3:0]      rxn,
	output wire [3:0]      txp,
	output wire [3:0]      txn
    );
    
    reg gt_rst;
    reg [11:0] rst_cnt;
    
    wire gt_refclk1;
    wire [3:0] channel_up;
    wire [3:0] lane_up;   
        
    wire [3:0] gt0_qpllreset_out;   
    wire gt_qpllclk_quad1_i;
    wire gt_qpllrefclk_quad1_i;
    wire gt0_qplllock_i;
    wire gt0_qpllrefclklost_i;
  
    
    //--- Instance of GT differential buffer ---------//
     IBUFDS_GTE2 IBUFDS_GTE2_CLK1
     (
     .I(gt_refclk1_p),
     .IB(gt_refclk1_n),
     .CEB(1'b0),
     .O(gt_refclk1),
     .ODIV2()
     );    
      
    aurora_64b66b_1_gt_common_wrapper gt_common_support
    (
        .gt_qpllclk_quad1_out    (gt_qpllclk_quad1_i      ),
        .gt_qpllrefclk_quad1_out (gt_qpllrefclk_quad1_i   ),
        .GT0_GTREFCLK0_COMMON_IN             (gt_refclk1), 
        //----------------------- Common Block - QPLL Ports ------------------------
    
        .GT0_QPLLLOCK_OUT (gt0_qplllock_i),
        .GT0_QPLLRESET_IN ( |gt0_qpllreset_out ),
    
        .GT0_QPLLLOCKDETCLK_IN (init_clk),
    
        .GT0_QPLLREFCLKLOST_OUT (gt0_qpllrefclklost_i),
    
    
        //---------------------- Common DRP Ports ----------------------
             .qpll_drpaddr_in ('b0),//
             .qpll_drpdi_in   ('b0),//
             .qpll_drpclk_in  (init_clk),
             .qpll_drpdo_out (), 
             .qpll_drprdy_out(), 
             .qpll_drpen_in  ('b0), //
             .qpll_drpwe_in  ('b0)//
    );


    always@(posedge init_clk or posedge gtp_reset) begin
        if(gtp_reset==1'b1) begin
            gt_rst <= 1'b1;
            rst_cnt <= 8'h0;
        end
        else if(rst_cnt == 10'd1000) begin
            gt_rst <= 1'b0;
            rst_cnt <= rst_cnt;
        end
        else begin
            gt_rst <= 1'b1;
            rst_cnt <= rst_cnt + 1'b1;
        end
    end

genvar i;
generate
	for(i=0;i<2;i=i+1) begin: gtx_array
    assign gtp_up[i] = channel_up[i] & lane_up[i];
	gtx_subsys64b66b gtx_subsys64b66b(
		.gt_refclk1               (gt_refclk1),
		.init_clk                 (init_clk),
		.gt_reset                 (gt_rst),
		.reset                    (gt_rst),
		.gt0_qpllreset_out        (gt0_qpllreset_out[i]),
        .gt_qpllclk_quad1_i       (gt_qpllclk_quad1_i),  
        .gt_qpllrefclk_quad1_i    (gt_qpllrefclk_quad1_i),
        .gt0_qplllock_i           (gt0_qplllock_i),       
        .gt0_qpllrefclklost_i     (gt0_qpllrefclklost_i), 
		.rxp                      (rxp[i]),
		.rxn                      (rxn[i]),
		.txp                      (txp[i]),
		.txn                      (txn[i]),
		.core_clk                 (core_clk),
		.gtp_fifo_rst		      (gtp_fifo_rst[i]),
		.gt2port_tdata            (gtx2core_tdata[64*(i+1)-1:64*i]),      
		.gt2port_tvalid           (gtx2core_tvalid[i]),     
        .gt2port_tready           (gtx2core_tready[i]),    
		.core2gtp_tdata           (core2gtx_tdata[64*(i+1)-1:64*i]),
		.core2gtp_tvalid          (core2gtx_tvalid[i]),
		.core2gtp_tready          (core2gtx_tready[i]),
		.core2gtp_tlast           (core2gtx_tlast),
		.channel_up               (channel_up[i]),
		.lane_up                  (lane_up[i])
	);
	end
endgenerate

    vio_0 u_vio_0 (
      .clk(init_clk),              // input wire clk
      .probe_in0(gtp_up)  // input wire [3 : 0] probe_in0
    );
    
    //vio_0 vio_0 (
    //  .clk(init_clk),                // input wire clk
    //  .probe_in0(channel_up),    // input wire [3 : 0] probe_in0
    //  .probe_in1(lane_up),    // input wire [3 : 0] probe_in1
    //  .probe_out0(probe_out0)  // output wire [0 : 0] probe_out0
    //);
endmodule
