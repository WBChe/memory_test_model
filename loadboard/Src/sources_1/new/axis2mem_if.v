`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/18 20:24:49
// Design Name: 
// Module Name: axis2memif
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


module axis2mem_if(
    input           core_clk,
    input           rst_n,
    
    input [31:0]    dut_data,
    input           dut_valid,
    
    output  wire [31:0] core2gtp_tdata    ,
    output  wire        core2gtp_tvalid   ,
    input   wire        core2gtp_tready   ,
    output  wire        core2gtp_tlast    ,
    
    //dut interface
    output reg ena,
    output reg wea,
    output reg [15:0] addra,
    output reg [7:0]  dina ,
    input      [7:0]  douta
    
    );
    parameter wr_mode       = 8'h02;
    parameter rd_mode       = 8'h03;
    //parameter inject_mode   = 8'h80;
    
    /*************************************************dut*************************************/
    //ena wea
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            ena <= 1'b0;
            wea <= 1'b0;
        end
        else if(dut_valid & (dut_data[31:24] == wr_mode))begin //wr mode
            ena <= 1'b1;
            wea <= 1'b1;
        end
        else if(dut_valid & (dut_data[31:24] == rd_mode))begin //rd mode
            ena <= 1'b1;
            wea <= 1'b0;
        end
        else begin
            ena <= 1'b0; 
            wea <= 1'b0; 
        end
    end
    
    //addra dina    
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            addra <= 16'b0;
            dina  <= 8'b0;
        end
        else if(dut_valid & (dut_data[31:24] == wr_mode))begin //wr mode
            addra <= dut_data[23:8];
            dina  <= dut_data[7:0];
        end
        else if(dut_valid & (dut_data[31:24] == rd_mode))begin //rd mode
            addra <= dut_data[23:8];
            dina  <= 8'b0;
        end
        else begin
            addra <= 16'b0;
            dina  <= 8'b0;
        end
    end
    
    //douta
    reg [7:0] douta_r;
    reg       dout_valid;
    reg       rd_flag;
    
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n)
            rd_flag <= 1'b0;
        else if(ena & ~wea)
            rd_flag <= 1'b1;
        else 
            rd_flag <= 1'b0;
    end
    
    //dff
    reg [15:0] addra_r;
    reg [7:0]  dina_r;
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            addra_r <= 16'b0;
            dina_r  <= 8'b0;
        end
        else begin
            addra_r <= addra;
            dina_r  <= dina;
        end
    end
    /*************************************************dut*************************************/
    
    //dut2gtp
    wire [31:0] dut2gtp_tdata;
    wire        dut2gtp_tvalid;
    assign dut2gtp_tvalid = rd_flag;
    assign dut2gtp_tdata = {8'b0, addra_r, douta};
    
    axis_douta_fifo u_axis_douta_fifo (
      .s_axis_aresetn(rst_n),  // input wire s_axis_aresetn
      .s_axis_aclk(core_clk),        // input wire s_axis_aclk
      .s_axis_tvalid(dut2gtp_tvalid),    // input wire s_axis_tvalid
      .s_axis_tready(),    // output wire s_axis_tready
      .s_axis_tdata(dut2gtp_tdata),      // input wire [31 : 0] s_axis_tdata
      
      .m_axis_tvalid(core2gtp_tvalid),    // output wire m_axis_tvalid
      .m_axis_tready(core2gtp_tready),    // input wire m_axis_tready
      .m_axis_tdata(core2gtp_tdata)      // output wire [31 : 0] m_axis_tdata
    );
    
endmodule
