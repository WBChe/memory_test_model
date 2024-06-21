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


module axis2memif(
    input core_clk,
    //input mem_clk,
    input rst_n,
    
    //axi_stream data
    input  wire [31:0] gtp2core_tdata    ,
    input  wire        gtp2core_tvalid   ,
    output wire        gtp2core_tready   ,
    input  wire        gtp2core_tlast    ,
                                   
    output  wire [31:0] core2gtp_tdata    ,
    output  wire        core2gtp_tvalid   ,
    input   wire        core2gtp_tready   ,
    output  wire        core2gtp_tlast    ,
    
    //dut memory interface
    output reg ena,
    output reg wea,
    output reg [15:0] addra,
    output reg [7:0]  dina ,
    input      [7:0]  douta,
    
    //dut_model
    output reg ena_model,
    output reg wea_model,
    output reg [15:0] addra_model,
    output reg [7:0]  dina_model,
    input      [7:0]  douta_model
    
    );
    parameter wr_mode       = 8'h02;
    parameter rd_mode       = 8'h03;
    parameter inject_mode   = 8'h80;
    
    assign gtp2core_tready = 1'b1;
    /*************************************************dut*************************************/
    //ena wea
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            ena <= 1'b0;
            wea <= 1'b0;
        end
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == wr_mode))begin //wr mode
            ena <= 1'b1;
            wea <= 1'b1;
        end
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == rd_mode))begin //rd mode
            ena <= 1'b1;
            wea <= 1'b0;
        end
//        else if(gtp2core_tvalid & (gtp2core_tdata[25:24] == 2'b00))begin //rd mode
//            ena <= 1'b0;
//            wea <= 1'b0;
//        end
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
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == wr_mode))begin //wr mode
            addra <= gtp2core_tdata[23:8];
            dina  <= gtp2core_tdata[7:0];
        end
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == rd_mode))begin //rd mode
            addra <= gtp2core_tdata[23:8];
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
    
//    always@(posedge core_clk or negedge rst_n) begin
//        if(!rst_n) begin
//            douta_r <= 8'b0;
//            dout_valid <= 1'b0;
//        end
//        else if(rd_flag)begin //wr mode
//            douta_r <= douta;
//            dout_valid <= 1'b1;
//        end
//        else begin
//            douta_r <= douta;
//            dout_valid <= 1'b0;
//        end
//    end
    
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
    
    /*************************************************dut_model*******************************/
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            ena_model <= 1'b0;
            wea_model <= 1'b0;
        end
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == inject_mode))begin //inject mode
            ena_model <= 1'b1;
            wea_model <= 1'b1;
        end
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == rd_mode))begin //rd mode
            ena_model <= 1'b1;
            wea_model <= 1'b0;
        end
//        else if(gtp2core_tvalid & (gtp2core_tdata[25:24] == 2'b00))begin //rd mode
//            ena <= 1'b0;
//            wea <= 1'b0;
//        end
        else begin
            ena_model <= 1'b0; 
            wea_model <= 1'b0; 
        end
    end
    
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            addra_model <= 16'b0;
            dina_model  <= 8'b0;
        end
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == inject_mode))begin //inject mode
            addra_model <= gtp2core_tdata[23:8];
            dina_model  <= gtp2core_tdata[7:0];
        end
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == rd_mode))begin //rd mode
            addra_model <= gtp2core_tdata[23:8];
            dina_model  <= 8'b0;
        end
        else begin
            addra_model <= 16'b0;
            dina_model  <= 8'b0;
        end
    end
    
    //douta
    reg [7:0] douta_model_r;
    reg       dout_model_valid;
    
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            douta_model_r <= 8'b0;
            dout_model_valid <= 1'b0;
        end
        else if(ena_model & ~wea_model)begin //wr mode //!
            douta_model_r <= douta_model;
            dout_model_valid <= 1'b1;
        end
        else begin
            douta_model_r <= douta_model;
            dout_model_valid <= 1'b0;
        end
    end
    
    //dff
    reg [15:0] addra_model_r;
    reg [7:0]  dina_model_r;
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            addra_model_r <= 16'b0;
            dina_model_r  <= 8'b0;
        end
        else begin
            addra_model_r <= addra_model;
            dina_model_r  <= dina_model;
        end
    end
    /*************************************************dut_model*******************************/
    
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
