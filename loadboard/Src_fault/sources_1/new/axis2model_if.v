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


module axis2model_if(
    input core_clk,
    input rst_n,
    
    //axi_stream data
    input  wire [31:0] gtp2core_tdata    ,
    input  wire        gtp2core_tvalid   ,
    output reg         gtp2core_tready   ,
    input  wire        gtp2core_tlast    ,
    
    //dut_model interface
    output reg ena_model,
    output reg wea_model,
    output reg [15:0] addra_model,
    output reg [7:0]  dina_model,
    input      [7:0]  douta_model,
    
    //dut
    output  reg [31:0] dut_data,
    output  reg        dut_valid   
    
    );
    parameter wr_mode       = 8'h02;
    parameter rd_mode       = 8'h03;
    parameter inject_mode   = 8'h80;
    
    //ready ctrl
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) 
            gtp2core_tready <= 1'b1;
        else if(gtp2core_tvalid & gtp2core_tready)
            gtp2core_tready <= 1'b0;
        else if(ena_model&wea_model | no_fault_en | fault_rd_en)
             gtp2core_tready <= 1'b1;
        else gtp2core_tready <= gtp2core_tready;
    end
    //assign gtp2core_tready = 1'b1;
    
    reg [31:0] gtp2core_tdata_r, gtp2core_tdata_2r, gtp2core_tdata_3r;
    reg gtp2core_tvalid_r, gtp2core_tvalid_2r, gtp2core_tvalid_3r;
    
    //3dff
     always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            gtp2core_tdata_r    <= 32'b0;
            gtp2core_tdata_2r   <= 32'b0;
            gtp2core_tvalid_r   <= 1'b0;
            gtp2core_tvalid_2r  <= 1'b0;
            
            gtp2core_tdata_3r   <= 32'b0;
            gtp2core_tvalid_3r  <= 1'b0;
        end
        else begin
            gtp2core_tdata_r    <= gtp2core_tdata; 
            gtp2core_tdata_2r   <= gtp2core_tdata_r; 
            gtp2core_tvalid_r   <= gtp2core_tvalid; 
            gtp2core_tvalid_2r  <= gtp2core_tvalid_r; 
            
            gtp2core_tdata_3r   <= gtp2core_tdata_2r;
            gtp2core_tvalid_3r  <= gtp2core_tvalid_2r;
        end
    end
    
    /**********************************************model port*************************************/
    //ena wea
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            ena_model <= 1'b0;
            wea_model <= 1'b0;
        end
        else if(gtp2core_tready & gtp2core_tvalid & (gtp2core_tdata[31:24] == inject_mode))begin //inject mode
            ena_model <= 1'b1;
            wea_model <= 1'b1;
        end
        else if(gtp2core_tready & gtp2core_tvalid & (gtp2core_tdata[31:24] == wr_mode))begin //wr mode
            ena_model <= 1'b1;
            wea_model <= 1'b0;
        end
        else if(gtp2core_tready & gtp2core_tvalid & (gtp2core_tdata[31:24] == rd_mode))begin //rd mode
            ena_model <= 1'b1;
            wea_model <= 1'b0;
        end
        //
        else if(rd_flag)begin //rd mode
                case(douta_model) // fault type case 
                /***********************************static fault*******************************/
                //no fault
                8'h00   :   begin
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                //SF 1
                8'h01   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                //SF 0
                8'h02   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                //SAF 1
                8'h03   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                //SAF 0
                8'h04   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                //TF 0->1
                8'h05   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                8'h45   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                //TF 1->0
                8'h06   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                8'h46   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                //WDF1
                8'h07   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                8'h47   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                            
                //WDF0
                8'h08   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                8'h48   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end 
                //RDF1
                8'h09   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end 
                //RDF0 
                8'h0A   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end  
                //DRDF1
                8'h0B   :   if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                8'h4B   :   begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                //DRDF0
                8'h0C   :   if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                8'h4C   :   begin
                                ena_model <= 1'b1;  
                                wea_model <= 1'b1;  
                            end                   
                //IRF1
                8'h0D   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                //IRF0
                8'h0E   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                /***********************************dynamic fault*******************************/
                //dWDF -1
                8'h0F,8'h10   :   if(gtp2core_tdata_2r[31:24] == wr_mode) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end
                8'h4F   :   begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h50   :   begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                //dWDF -2
                8'h11,8'h12   :   if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                8'h51   :   begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h52   :   begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                //dRDF
                8'h13,8'h14,8'h17  :    if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                8'h15,8'h16,8'h18  :    if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                8'h53   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                            else begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h54   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                            else begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end            
                8'h55   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                            else begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h56   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                            else begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h57   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h58   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                                        
                8'h93   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h94   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h95   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h96   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h97   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h98   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                //dDRDF
                8'h19,8'h1A   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                8'h1B,8'h1C   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                8'h59   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                               ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                            else begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h5A   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                            else begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h5B   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                            else begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h5C   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                            else begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h99   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h9A   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h9B   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h9C   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'hD9   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'hDA   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'hDB   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'hDC   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end 
                //dIRF
                8'h1D,8'h1E,8'h21  :    if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                8'h1F,8'h20,8'h22  :    if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else begin 
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                8'h5D   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                            else begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h5E   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                            else begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end            
                8'h5F   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                            else begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h60   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                ena_model <= 1'b0;
                                wea_model <= 1'b0;
                            end
                            else begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h61   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                8'h62   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                                        
                8'h9D,8'h9E,8'h9F,8'hA0,8'hA1,8'hA2   :   begin //wr (00-FF)
                                ena_model <= 1'b1;
                                wea_model <= 1'b1;
                            end
                    
                default :   begin
                                ena_model <= 1'b0; 
                                wea_model <= 1'b0; 
                            end            
                endcase
        end
        else begin
            ena_model <= 1'b0; 
            wea_model <= 1'b0; 
        end
    end
    
    //addra dina    
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            addra_model <= 16'b0;
            dina_model  <= 8'b0;
        end
        else if(gtp2core_tready & gtp2core_tvalid & (gtp2core_tdata[31:24] == inject_mode))begin //inject mode
            addra_model <= gtp2core_tdata[23:8];
            dina_model  <= gtp2core_tdata[7:0];
        end
        else if(gtp2core_tready & gtp2core_tvalid & (gtp2core_tdata[31:24] == wr_mode))begin //wr mode
            addra_model <= gtp2core_tdata[23:8];
            dina_model  <= 8'b0;
        end
        else if(gtp2core_tready & gtp2core_tvalid & (gtp2core_tdata[31:24] == rd_mode))begin //rd mode
            addra_model <= gtp2core_tdata[23:8];
            dina_model  <= 8'b0;
        end
        
        //
        else if(rd_flag)begin //rd mode
                case(douta_model) // fault type case 
                /***********************************static fault*******************************/
                //no fault
                8'h00   :   begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                //SF 1
                8'h01   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                //SF 0
                8'h02   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                //SAF 1
                8'h03   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                //SAF 0
                8'h04   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                //TF 0->1
                8'h05   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h45   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h05;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                //TF 1->0
                8'h06   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h46   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h06;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                //WDF1
                8'h07   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h47   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h07;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h07;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                //WDF0
                8'h08   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h48   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h08;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h08;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end 
                //RDF1
                8'h09   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end 
                //RDF0
                8'h0A   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end 
                //DRDF1
                8'h0B   :   if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h4B   :   begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h0B;
                            end      
                //DRDF0
                8'h0C   :   if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h4C   :   begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h0C;
                            end
                //IRF1
                8'h0D   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                //IRF0
                8'h0E   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                /**********************************dynamic fault**********************************/   
                //dWDF -1
                8'h0F,8'h10   :   if(gtp2core_tdata_2r[31:24] == wr_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h4F   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h4F;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h0F;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h0F;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h0F;
                            end

                8'h50   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h10;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h50;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h10;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h10;
                            end
                //dWDF -2
                8'h11,8'h12   :   if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h51   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h11;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h11;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h51;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h11;
                            end

                8'h52   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h12;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h12;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h52;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h12;
                            end
                //dRDF
                8'h13,8'h14,8'h17  :    if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h15,8'h16,8'h18  :    if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h53   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h13;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h13;
                            end
                8'h54   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h54;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h14;
                            end            
                8'h55   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h55;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h15;
                            end
                8'h56   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h16;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h16;
                            end
                8'h57   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h17;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h57;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h17;
                            end
                8'h58   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h58;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h18;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h18;
                            end
                                        
                8'h93   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h13;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h93;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h13;                  
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h13;
                            end
                8'h94   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h14;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h54;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h14;                  
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h14;
                            end
                8'h95   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h55;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h15;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h15;                  
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h15;
                            end
                8'h96   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h96;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h16;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h16;                  
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h16;
                            end
                8'h97   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h17;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h57;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h17;                  
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h17;
                            end
                8'h98   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h58;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h18;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h18;                  
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h18;
                            end
                //dDRDF
                8'h19,8'h1A   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h1B,8'h1C   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h59   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h19;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h19;
                            end
                8'h5A   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h5A;//
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1A;
                            end
                8'h5B   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h5B;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1B;
                            end
                8'h5C   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1C;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1C;
                            end
                8'h99   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h99;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h19;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h19;
                            end
                8'h9A   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h5A;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1A;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1A;
                            end
                8'h9B   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1B;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h5B;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1B;
                            end
                8'h9C   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1C;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h9C;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1C;
                            end
                8'hD9   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h99;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h19;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h19;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h19;
                            end
                8'hDA   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h5A;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1A;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1A;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1A;
                            end
                8'hDB   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1B;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h5B;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1B;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1B;
                            end
                8'hDC   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1C;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h9C;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1C;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1C;
                            end
                //dIRF
                8'h1D,8'h1E,8'h21  :    if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h1F,8'h20,8'h22  :    if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin 
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                8'h5D   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1D;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1D;
                            end
                8'h5E   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h5E;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1E;
                            end            
                8'h5F   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h5F;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1F;
                            end
                8'h60   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h20;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h20;
                            end
                8'h61   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h21;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h61;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h21;
                            end
                8'h62   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h62;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h22;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= douta_model + 8'h40;
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h22;
                            end
                                        
                8'h9D   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1D;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h9D;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1D;                  
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1D;
                            end
                8'h9E   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1E;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h5E;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1E;                  
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1E;
                            end
                8'h9F   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h5F;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1F;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1F;                  
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h1F;
                            end
                8'hA0   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'hA0;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h20;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h20;                  
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h20;
                            end
                8'hA1   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h21;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h61;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'hA1;   //21               
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h21;
                            end
                8'hA2   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h62;
                            end
                            else if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h22;
                            end
                            else if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'hA2;                  
                            end
                            else begin //wr (00-FF)
                                addra_model <= gtp2core_tdata_2r[31:8];
                                dina_model  <= 8'h22;
                            end
                                 
                default :  begin
                                addra_model <= 16'b0;
                                dina_model  <= 8'b0;
                           end            
                endcase
        end
        else begin
            addra_model <= 16'b0;
            dina_model  <= 8'b0;
        end
    end
    
    //douta
    reg    rd_flag;
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n)
            rd_flag <= 1'b0;
        else if(ena_model & ~wea_model)
            rd_flag <= 1'b1;
        else 
            rd_flag <= 1'b0;
    end
    
    /********************************************model port*************************************/
    
    //fault type detect
    reg fault_en;
    reg fault_rd_en;
    reg no_fault_en;
    //reg [1:0] err_cnt [7:0];
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            fault_en <= 1'b0;
            fault_rd_en <= 1'b0;
            no_fault_en <= 1'b0;
            //err_cnt <= 'b0;
        end
        else if(rd_flag) // wr_mode/rd_mode both run this case()
            case(douta_model)// fault type case 
                //no fault
                8'h00   :   begin
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                /**********************************static fault**********************************/
                //SF 1
                8'b01   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                //SF 0
                8'h02   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                //SAF 1
                8'h03   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                //SAF 0
                8'h04   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //TF 0->1
                 8'h05   :  begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h45   :  if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //TF 1->0
                 8'h06   :  begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h46   :  if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //WDF1
                 8'h07   :  begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h47   :  if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //WDF0
                 8'h08   :  begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h48   :  if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //RDF1
                 8'h09   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //RDF0
                 8'h0A   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //DRDF1
                 8'h0B   :  begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h4B   :  if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b1;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //DRDF0
                 8'h0C   :  begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h4C   :  if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b1;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //IRF1
                 8'h0D   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //IRF0     
                 8'h0E   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 /**********************************dynamic fault**********************************/
                 //dWDF -1
                 8'h0F,8'h11   :  begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h4F,8'h51   :  if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //dWDF -2
                 8'h10,8'h12   :  begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h50,8'h52   :  if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'hFF}) begin
                                fault_en <= 1'b1;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //dRDF
                 8'h13,8'h14,8'h15,8'h16,8'h17,8'h18   :  begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h53,8'h54,8'h55,8'h56,8'h57,8'h58   :  begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h93,8'h94,8'h95,8'h96,8'h97,8'h98   :  if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b1;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //dDRDF
                 8'h19,8'h1A,8'h1B,8'h1C  :   begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h59,8'h5A,8'h5B,8'h5C  :   begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h99,8'h9A,8'h9B,8'h9C  :   begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'hD9,8'hDA,8'hDB,8'hDC  :   if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b1;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 //dIRF
                 8'h1D,8'h1E,8'h1F,8'h20,8'h21,8'h22   :  begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h5D,8'h5E,8'h5F,8'h60,8'h61,8'h62   :  begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 8'h9D,8'h9E,8'h9F,8'hA0,8'hA1,8'hA2   :  if(gtp2core_tdata_2r[31:24] == rd_mode) begin
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b1;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                fault_rd_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                 
                 default :   begin fault_en <= 1'b0; no_fault_en <= 1'b0; fault_rd_en <= 1'b0;end
            endcase
        else begin
            fault_en <= 1'b0;
            no_fault_en <= 1'b0;
            fault_rd_en <= 1'b0;
        end
    end
    
    //inject fault
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            dut_data    <= 32'b0;
            dut_valid   <= 1'b0;
        end
        else if(fault_en) begin
            dut_data    <= {gtp2core_tdata_3r[31:8], ~gtp2core_tdata_3r[7:0]};
            dut_valid   <= 1'b1;
        end
        else if(fault_rd_en) begin
            dut_data    <= {1'b1, gtp2core_tdata_3r[30:0]};
            dut_valid   <= 1'b1;
        end
        else if(no_fault_en) begin
            dut_data    <= gtp2core_tdata_3r;
            dut_valid   <= gtp2core_tvalid_3r;
        end
        else begin
            dut_data    <= 32'b0;
            dut_valid   <= 1'b0;                                 
        end
    end
    
//    axis_douta_fifo u_axis_douta_fifo (
//      .s_axis_aresetn(rst_n),  // input wire s_axis_aresetn
//      .s_axis_aclk(core_clk),        // input wire s_axis_aclk
//      .s_axis_tvalid(dut2gtp_tvalid),    // input wire s_axis_tvalid
//      .s_axis_tready(),    // output wire s_axis_tready
//      .s_axis_tdata(dut2gtp_tdata),      // input wire [31 : 0] s_axis_tdata
      
//      .m_axis_tvalid(core2gtp_tvalid),    // output wire m_axis_tvalid
//      .m_axis_tready(core2gtp_tready),    // input wire m_axis_tready
//      .m_axis_tdata(core2gtp_tdata)      // output wire [31 : 0] m_axis_tdata
//    );
    
endmodule
