`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/18 15:54:11
// Design Name: 
// Module Name: gtp_sys
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


module gtp_sys(
    input wire             gt_refclk1_p,
	input wire             gt_refclk1_n,
	input wire             init_clk,
    input wire             gtp_reset,
	
	//gtp data axi-stream 
	input  wire            core_clk,
	input  wire            gtp_fifo_rst,
	
	output wire [31:0]     gtp2core_tdata,
	output wire            gtp2core_tvalid,
	input  wire            gtp2core_tready,
	output wire            gtp2core_tlast,
	
	input  wire [31:0]     core2gtp_tdata,
	input  wire            core2gtp_tvalid,
	output wire            core2gtp_tready,
	input  wire            core2gtp_tlast,
	
	output wire            gtp_up,
	
	//gtp ports
	input  wire            rxp,
	input  wire            rxn,
	output wire            txp,
	output wire            txn
    );
    
    reg gt_rst;
    reg [11:0] rst_cnt;
    
    wire gt_refclk1;
    wire  channel_up;
    wire  lane_up;   
        
    //new a7 
    wire quad1_common_lock_i     ;
    wire quad1_common_pll1_lock_i;
    wire gt0_pll0refclklost_i;
    wire gt0_pll0outclk_i    ;
    wire gt0_pll1outclk_i    ;
    wire gt0_pll0outrefclk_i ;
    wire gt0_pll1outrefclk_i ;
    wire common_reset_i;
    
    //--- Instance of GT differential buffer ---------//
     IBUFDS_GTE2 IBUFDS_GTE2_CLK1
     (
     .I(gt_refclk1_p),
     .IB(gt_refclk1_n),
     .CEB(1'b0),
     .O(gt_refclk1),
     .ODIV2()
     );    

    aurora_8b10b_0_gt_common_wrapper gt_common_support
    (
        //____________________________COMMON PORTS_______________________________{
    .gt0_gtrefclk0_in       (gt_refclk1             ),
    .gt0_pll0lock_out       (quad1_common_lock_i       ),
    .gt0_pll1lock_out       (quad1_common_pll1_lock_i       ),
    .gt0_pll0lockdetclk_in  (init_clk             ),
    .gt0_pll0refclklost_out (gt0_pll0refclklost_i ),
    .gt0_pll0outclk_i       ( gt0_pll0outclk_i    ),
    .gt0_pll1outclk_i       ( gt0_pll1outclk_i    ),
    .gt0_pll0outrefclk_i    ( gt0_pll0outrefclk_i ),
    .gt0_pll1outrefclk_i    ( gt0_pll1outrefclk_i ),
    .gt0_pll0reset_in       ( common_reset_i    )//|common_reset_i
        //____________________________COMMON PORTS_______________________________}
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

//    genvar i;
//    generate
//    	for(i=0;i<1;i=i+1) begin: gtp_array
        assign gtp_up = channel_up & lane_up;
    	gtp_subsys gtp_subsys(
    		.gt_refclk1               (gt_refclk1),
    		.init_clk                 (init_clk),
    		.gt_reset                 (gt_rst),
    		.reset                    (gt_rst),
    		
    		//aurora_8b10b_0_gt_common_wrapper
            .common_reset_i           (common_reset_i),
            .gt0_pll0outclk_i         (gt0_pll0outclk_i   ),
            .gt0_pll1outclk_i         (gt0_pll1outclk_i   ),
            .gt0_pll0outrefclk_i      (gt0_pll0outrefclk_i),
            .gt0_pll1outrefclk_i      (gt0_pll1outrefclk_i),
            .quad1_common_lock_i      (quad1_common_lock_i),
            .quad1_common_pll1_lock_i (quad1_common_pll1_lock_i),
            .gt0_pll0refclklost_i     (gt0_pll0refclklost_i),
            
    		.rxp                      (rxp),
    		.rxn                      (rxn),
    		.txp                      (txp),
    		.txn                      (txn),
    		.core_clk                 (core_clk),
    		.gtp_fifo_rst		      (gtp_fifo_rst),
    		.gt2port_tdata            (gtp2core_tdata[31:0]),      
    		.gt2port_tvalid           (gtp2core_tvalid),     
            .gt2port_tready           (gtp2core_tready),
            .gt2port_tlast            (gtp2core_tlast),
                
    		.core2gtp_tdata           (core2gtp_tdata[31:0]),
    		.core2gtp_tvalid          (core2gtp_tvalid),
    		.core2gtp_tready          (core2gtp_tready),
    		.core2gtp_tlast           (core2gtp_tlast),
    		.channel_up               (channel_up),
    		.lane_up                  (lane_up)
    	);
//    	end
//    endgenerate
    
    
    
endmodule
