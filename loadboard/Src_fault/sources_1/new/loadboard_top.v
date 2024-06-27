`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/12 17:17:07
// Design Name: 
// Module Name: loadboard_top
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


module loadboard_top(
    //sys
    input  sys_clk,
    //input  sys_rst_n,
    
    //gt sys
    input  wire       gt_refclk1_p,
    input  wire       gt_refclk1_n,
    
    input  wire       rxp,
    input  wire       rxn,
    output wire       txp,
    output wire       txn,
    
    output wire sfpa_tx_dis,
    output wire sfpb_tx_dis
    
    //dut i/o pin
    //default dut 23k256 sram, you can change the memory you want
//    output sck,
//    output cs_n,
//    output si,
//    output hold_n,
//    input  so
    
    );
    
    //clk control module
    wire clk_100m;
    wire clk_50m;
    wire clk_20m;
    wire clk_10m;
    wire init_clk; //for gt
    wire core_clk; //for core 
    assign init_clk = clk_50m;
    assign core_clk = clk_100m;
    
    clk_wiz_0 u_clk_wiz_0(
        .clk_out1(clk_100m),     // output clk_out1  100mhz
        .clk_out2(clk_50m),     // output clk_out2  50mhz
        .clk_out3(clk_20m),     // output clk_out3  20mhz
        .clk_out4(clk_10m),     // output clk_out4  10mhz
        
        
        //.resetn(sys_rst_n),     // input resetn
        .locked(sys_rst_n),
        .clk_in1(sys_clk)       // input clk_sys     50mhz
    );
    
    
    
    wire [31:0] gtp2core_tdata;
    wire        gtp2core_tvalid;
    wire        gtp2core_tready;
    wire        gtp2core_tlast;
    
    wire [31:0] core2gtp_tdata;
    wire        core2gtp_tvalid;
    wire        core2gtp_tready;
    wire        core2gtp_tlast ;
    wire        gtp_up;
    
    //gt
    assign sfpa_tx_dis = 1'b0;
    assign sfpb_tx_dis = 1'b0;
    
    gtp_sys gtp_8b10b(
    	 .gt_refclk1_p      (gt_refclk1_p),
    	 .gt_refclk1_n      (gt_refclk1_n),
    	 .init_clk          (init_clk),
         .gtp_reset         (~sys_rst_n),
  
         .core_clk          (core_clk),
    	 .gtp_fifo_rst      (~sys_rst_n), 
    	 
         .gtp2core_tdata    (gtp2core_tdata ), //32b
    	 .gtp2core_tvalid   (gtp2core_tvalid),
    	 .gtp2core_tready   (gtp2core_tready),  
    	 .gtp2core_tlast    (gtp2core_tlast ),
    	 
    	 .core2gtp_tdata    (core2gtp_tdata ), //32b
         .core2gtp_tvalid   (core2gtp_tvalid), 
    	 .core2gtp_tready   (core2gtp_tready),
    	 .core2gtp_tlast    (core2gtp_tlast ),
    	 
    	 .gtp_up            (gtp_up),
    	 //gtx ports;
    	 .rxp               (rxp),
    	 .rxn               (rxn),
    	 .txp               (txp),
    	 .txn               (txn)
    );
    
    //32bit data -> 8 instruction+ 16 addr + 8 data
    wire ena;
    wire wea;
    wire [15:0] addra;
    wire [7:0]  dina;
    wire [7:0]  douta;
    
    wire ena_model;
    wire wea_model;
    wire [15:0] addra_model;
    wire [7:0]  dina_model;
    wire [7:0]  douta_model; 

    
    //dut interface module ,you need to code your new interface module in axis2mem_if.v
    mem_model_top u_mem_model_top(
        .core_clk               (core_clk),
        //input mem_clk,
        .rst_n                  (sys_rst_n),
        
        //axi_stream data 2 dut_model
        .gtp2core_tdata          (gtp2core_tdata ),
        .gtp2core_tvalid         (gtp2core_tvalid),
        .gtp2core_tready         (gtp2core_tready),
        .gtp2core_tlast          (gtp2core_tlast ),
        
        //dut 2 axi_stream data                         
        .core2gtp_tdata         (core2gtp_tdata ),
        .core2gtp_tvalid        (core2gtp_tvalid),
        .core2gtp_tready        (core2gtp_tready),
        .core2gtp_tlast         (core2gtp_tlast )
   
   
    );
    
    //ila
    ila_gtp u_ila_gtp_tx (
    	.clk(core_clk), // input wire clk
    	.probe0(core2gtp_tlast ), // input wire [0:0]  probe0  
    	.probe1(core2gtp_tready), // input wire [0:0]  probe1 
    	.probe2(core2gtp_tvalid), // input wire [0:0]  probe2 
    	.probe3(core2gtp_tdata ) // input wire [31:0]  probe3
    );
    
    ila_gtp u_ila_gtp_rx (
    	.clk(core_clk), // input wire clk
    	.probe0(gtp2core_tlast ), // input wire [0:0]  probe0  
    	.probe1(gtp2core_tready), // input wire [0:0]  probe1 
    	.probe2(gtp2core_tvalid), // input wire [0:0]  probe2 
    	.probe3(gtp2core_tdata ) // input wire [31:0]  probe3
    );
    
    //vio
    vio_gtp_up u_vio_gtp_up (
      .clk(core_clk),              // input wire clk
      .probe_in0(gtp_up)  // input wire [0 : 0] probe_in0
    );
endmodule
