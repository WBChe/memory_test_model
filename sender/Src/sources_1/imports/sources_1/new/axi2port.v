`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/17 11:34:39
// Design Name: 
// Module Name: axi2port
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


module axi2port(
    input    chip_inclk,
    input    gdma_clk,
    input    chip_outclk,
    input    rst_n,
    
    input    gdma2port_tvalid,
    output   gdma2port_tready,  
    input    [31:0]gdma2port_tdata, 
    output   port_out_tvalid,
    input    port_out_tready,  
    output   [15:0]port_out_tdata,       
  
    output   port2gdma_tvalid,   
    input    port2gdma_tready,   
    output   [31:0]port2gdma_tdata, 
    input    port_in_tvalid,
    output   port_in_tready,  
    input    [15:0]port_in_tdata,
    
    input   sim_packet_flag,
    input   [4:0]sim_packet_length,
    output   reg receve_packet_done
    );
    
    
    wire gdma2fifo_tvalid;       
    wire gdma2fifo_tready;        
    wire [15 : 0] gdma2fifo_tdata;
    wire fifo2gdma_tvalid;       
    wire fifo2gdma_tready;        
    wire [15 : 0] fifo2gdma_tdata;
    wire converter2pack_tvalid;         
    wire converter2pack_tready;          
    wire [31 : 0] converter2pack_tdata;  
 
    
    wire almost_full;
    
    reg [4:0]sim_packet_length_cnt;
    
    wire port2gdma_fifo_tvalid;
    assign fifo2gdma_tvalid=sim_packet_flag?1'b0:port2gdma_fifo_tvalid;
    always@(posedge gdma_clk or negedge rst_n)
    if(!rst_n)
        sim_packet_length_cnt <= 'h0;
    else if(sim_packet_flag==1'b0)
        sim_packet_length_cnt <= 'h0;
    else if(port2gdma_fifo_tvalid)
        sim_packet_length_cnt <= sim_packet_length_cnt + 1'b1;
        
    always@(posedge gdma_clk or negedge rst_n)
    if(!rst_n)
        receve_packet_done <= 'h0;
    else if(sim_packet_length_cnt==sim_packet_length)
        receve_packet_done <= 'h1;
    else if(sim_packet_flag==1'b1)  
        receve_packet_done <= 'h0;  
    

//    ila_packet ila_packet (
//	.clk(gdma_clk), // input wire clk
//	.probe0(sim_packet_length_cnt[3:0]), // input wire [3:0]  probe0  
//	.probe1(sim_packet_length[3:0]), // input wire [3:0]  probe1 
//	.probe2(receve_packet_done), // input wire [0:0]  probe2 
//	.probe3(sim_packet_flag), // input wire [0:0]  probe3 
//	.probe4(port2gdma_fifo_tvalid) // input wire [0:0]  probe4000
//);
    
    
  axis2port_dwidth_converter axis2port_dwidth_converter (
  .aclk(gdma_clk),                    // input wire aclk
  .aresetn(rst_n),              // input wire aresetn
  .s_axis_tvalid(gdma2port_tvalid),  // input wire s_axis_tvalid
  .s_axis_tready(gdma2port_tready),  // output wire s_axis_tready
  .s_axis_tdata(gdma2port_tdata),    // input wire [31 : 0] s_axis_tdata
  .m_axis_tvalid(gdma2fifo_tvalid),  // output wire m_axis_tvalid
  .m_axis_tready(gdma2fifo_tready),  // input wire m_axis_tready
  .m_axis_tdata(gdma2fifo_tdata)    // output wire [15 : 0] m_axis_tdata
);
    
   gdma_fifo gdma2port_fifo (
  .s_axis_aresetn(rst_n),  // input wire s_axis_aresetn
  .s_axis_aclk(gdma_clk),        // input wire s_axis_aclk
  .s_axis_tvalid(gdma2fifo_tvalid),    // input wire s_axis_tvalid
  .s_axis_tready(gdma2fifo_tready),    // output wire s_axis_tready
  .s_axis_tdata(gdma2fifo_tdata),      // input wire [15 : 0] s_axis_tdata
  .m_axis_aclk(chip_inclk),        // input wire m_axis_aclk
  .m_axis_tvalid(port_out_tvalid),    // output wire m_axis_tvalid
  .m_axis_tready(port_out_tready),    // input wire m_axis_tready
  .m_axis_tdata(port_out_tdata)      // output wire [15 : 0] m_axis_tdata
); 

//ila_rst your_instance_name (
//	.clk(gdma_clk), // input wire clk


//	.probe0(almost_full) // input wire [0:0] probe0
//);

  port2gdma_fifo port2gdma_fifo (
  .s_axis_aresetn(rst_n),  // input wire s_axis_aresetn
  .s_axis_aclk(chip_outclk),        // input wire s_axis_aclk
  .s_axis_tvalid(port_in_tvalid),    // input wire s_axis_tvalid
  .s_axis_tready(port_in_tready),    // output wire s_axis_tready
  .s_axis_tdata(port_in_tdata),      // input wire [15 : 0] s_axis_tdata
  .m_axis_aclk(gdma_clk),        // input wire m_axis_aclk
  .m_axis_tvalid(port2gdma_fifo_tvalid),    // output wire m_axis_tvalid
  .m_axis_tready(fifo2gdma_tready),    // input wire m_axis_tready
  .m_axis_tdata(fifo2gdma_tdata)      // output wire [15 : 0] m_axis_tdata
);    

//ila_16 ila_in (
//	.clk(gdma_clk), // input wire clk


//	.probe0(gdma2fifo_tdata), // input wire [15:0]  probe0  
//	.probe1(gdma2fifo_tready), // input wire [0:0]  probe1 
//	.probe2(gdma2fifo_tvalid) // input wire [0:0]  probe2
//);

//ila_16 ila_16 (
//	.clk(gdma_clk), // input wire clk


//	.probe0(fifo2gdma_tdata), // input wire [15:0]  probe0  
//	.probe1(fifo2gdma_tvalid), // input wire [0:0]  probe1 
//	.probe2(fifo2gdma_tready) // input wire [0:0]  probe2
//);

 

 
 
// port2axi_dwidth_converter port2axi_dwidth_converter (
//  .aclk(gdma_clk),                    // input wire aclk
//  .aresetn(rst_n),              // input wire aresetn
//  .s_axis_tvalid(fifo2gdma_tvalid),  // input wire s_axis_tvalid
//  .s_axis_tready(fifo2gdma_tready),  // output wire s_axis_tready
//  .s_axis_tdata(fifo2gdma_tdata),    // input wire [15 : 0] s_axis_tdata
//  .m_axis_tvalid(port2gdma_tvalid),  // output wire m_axis_tvalid
//  .m_axis_tready(port2gdma_tready),  // input wire m_axis_tready
//  .m_axis_tdata(port2gdma_tdata)    // output wire [31 : 0] m_axis_tdata
//);      
   
   
 port2axi_dwidth_converter port2axi_dwidth_converter (
  .aclk(gdma_clk),                    // input wire aclk
  .aresetn(rst_n),              // input wire aresetn
  .s_axis_tvalid(fifo2gdma_tvalid),  // input wire s_axis_tvalid
  .s_axis_tready(fifo2gdma_tready),  // output wire s_axis_tready
  .s_axis_tdata(fifo2gdma_tdata),    // input wire [15 : 0] s_axis_tdata
  .m_axis_tvalid(converter2pack_tvalid),  // output wire m_axis_tvalid
  .m_axis_tready(converter2pack_tready),  // input wire m_axis_tready
  .m_axis_tdata(converter2pack_tdata)    // output wire [31 : 0] m_axis_tdata
);   
 
gdma_wdata_width_converter remove_header(
     .s_axis_tvalid  (converter2pack_tvalid),
     .s_axis_tready  (converter2pack_tready),
     .s_axis_tdata   (converter2pack_tdata[15:0]),
     .aclk           (gdma_clk),
     .aresetn        (rst_n),
     .aclken         (1'b1),                // input wire aclken
     .m_axis_tvalid  (port2gdma_tvalid),
     .m_axis_tready  (port2gdma_tready),
     .m_axis_tdata   (port2gdma_tdata)
 ); 
 
 
    
    
    
endmodule
