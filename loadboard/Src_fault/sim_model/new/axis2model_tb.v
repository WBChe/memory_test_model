`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/20 17:06:09
// Design Name: 
// Module Name: axis2model_tb
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


module axis2model_tb(
    );
    reg core_clk, rst_n, gtp2core_tvalid;
    reg [31:0] gtp2core_tdata;
    wire        ena_model    ;
    wire        wea_model    ;
    wire [15:0] addra_model  ;
    wire [7:0]  dina_model   ;
    wire [7:0]  douta_model  ;
    
    wire [31:0] dut_data;
    wire        dut_valid;
    wire [31:0] m_axis_tdata;
    wire m_axis_tready, m_axis_tvalid;
    
    axis_douta_fifo u_axis_douta_fifo (
      .s_axis_aresetn(rst_n),  // input wire s_axis_aresetn
      .s_axis_aclk(core_clk),        // input wire s_axis_aclk
      .s_axis_tvalid(gtp2core_tvalid),    // input wire s_axis_tvalid
      .s_axis_tready(),    // output wire s_axis_tready
      .s_axis_tdata(gtp2core_tdata),      // input wire [31 : 0] s_axis_tdata
      .m_axis_tvalid(m_axis_tvalid),    // output wire m_axis_tvalid
      .m_axis_tready(m_axis_tready),    // input wire m_axis_tready
      .m_axis_tdata(m_axis_tdata)      // output wire [31 : 0] m_axis_tdata
    );
    
 axis2model_if u_axis2model_if(
    .core_clk   (core_clk),
    .rst_n      (rst_n),
    
    //axi_stream data
    .gtp2core_tdata    (m_axis_tdata),//gtp2core_tdata
    .gtp2core_tvalid   (m_axis_tvalid),//gtp2core_tvalid
    .gtp2core_tready   (m_axis_tready),
    .gtp2core_tlast    (),
    
    //dut_model interface
    .ena_model      (ena_model  ),
    .wea_model      (wea_model  ),
    .addra_model    (addra_model),
    .dina_model     (dina_model ),
    .douta_model    (douta_model),
                    
    //dut           
    .dut_data       (dut_data),
    .dut_valid      (dut_valid)
    
    );
    
    //model
        dut_mem dut_memory_model (
            .clka (core_clk   ),    // input wire clkaodule
            .ena  (ena_model  ),      // input wire ena
            .wea  (wea_model  ),      // input wire [0 : 0] wea
            .addra(addra_model),  // input wire [14 : 0] addra
            .dina (dina_model ),    // input wire [7 : 0] dina
            .douta(douta_model)  // output wire [7 : 0] douta
        );

  initial core_clk = 1;
    always #10 core_clk = ~core_clk;
    
     initial begin
     gtp2core_tdata = 0;
     gtp2core_tvalid = 0;
     rst_n =0;
     #1000
     rst_n =1;
     #1000
     #1
     gtp2core_tdata = 32'h80000005;
     gtp2core_tvalid = 1;
     #20
     gtp2core_tvalid = 0;
     #20
     gtp2core_tdata = 32'h02000000;
     gtp2core_tvalid = 1;
     #20
     gtp2core_tvalid = 0;
     #20
     gtp2core_tdata = 32'h020000ff;
     gtp2core_tvalid = 1;
     #20
     gtp2core_tvalid = 0;
     #20
     gtp2core_tdata = 32'h03000000;
     gtp2core_tvalid = 1;
     #20
     gtp2core_tdata = 0;
     gtp2core_tvalid = 0;
     
     #100
     
     gtp2core_tdata = 32'h80000106;
     gtp2core_tvalid = 1;
     #20
     gtp2core_tvalid = 0;
     #20
     gtp2core_tdata = 32'h020001FF;
     gtp2core_tvalid = 1;
     #20
     gtp2core_tvalid = 0;
     #20
     gtp2core_tdata = 32'h02000100;
     gtp2core_tvalid = 1;
     #20
     gtp2core_tvalid = 0;
     #20
     gtp2core_tdata = 32'h03000100;
     gtp2core_tvalid = 1;
     #20
     gtp2core_tdata = 0;
     gtp2core_tvalid = 0;
     
     #1000
     gtp2core_tdata = 32'h8000000B;
     gtp2core_tvalid = 1;
     #20
     gtp2core_tvalid = 0;
     #20
     gtp2core_tdata = 32'h02000000;
     gtp2core_tvalid = 1;
     #20
     gtp2core_tvalid = 0;
     #20
     gtp2core_tdata = 32'h03000000;
     gtp2core_tvalid = 1;
     #20
     gtp2core_tvalid = 0;
     #20
     gtp2core_tdata = 32'h03000000;
     gtp2core_tvalid = 1;
     #20
     gtp2core_tdata = 0;
     gtp2core_tvalid = 0;
     
     #20000;
     $stop;
     end
     
endmodule