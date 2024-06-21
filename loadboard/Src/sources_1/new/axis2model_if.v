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
    output wire        gtp2core_tready   ,
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
    
    assign gtp2core_tready = 1'b1;
    
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
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == inject_mode))begin //inject mode
            ena_model <= 1'b1;
            wea_model <= 1'b1;
        end
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == wr_mode))begin //wr mode
            ena_model <= 1'b1;
            wea_model <= 1'b0;
        end
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == rd_mode))begin //rd mode
            ena_model <= 1'b1;
            wea_model <= 1'b0;
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
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == inject_mode))begin //inject mode
            addra_model <= gtp2core_tdata[23:8];
            dina_model  <= gtp2core_tdata[7:0];
        end
        else if(gtp2core_tvalid & (gtp2core_tdata[31:24] == wr_mode))begin //wr mode
            addra_model <= gtp2core_tdata[23:8];
            dina_model  <= 8'b0;
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
    reg no_fault_en;
    always@(posedge core_clk or negedge rst_n) begin
        if(!rst_n) begin
            fault_en <= 1'b0;
            no_fault_en <= 1'b0;
        end
        else if(rd_flag)
            case(douta_model) // fault type case 
                //no fault
                8'h00   :   begin
                                fault_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                //SF 1
                8'h01   :   if({gtp2core_tdata_2r[31:24], gtp2core_tdata_2r[7:0]} == {wr_mode, 8'h00}) begin
                                fault_en <= 1'b1;
                                no_fault_en <= 1'b0;
                            end
                            else begin 
                                fault_en <= 1'b0;
                                no_fault_en <= 1'b1;
                            end
                default :   begin fault_en <= 1'b0; no_fault_en <= 1'b0; end
            endcase
        else begin
            fault_en <= 1'b0;
            no_fault_en <= 1'b0;
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
