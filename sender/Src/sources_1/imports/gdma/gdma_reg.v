`timescale 1ns / 1ps
//`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/26 10:03:31
// Design Name: 
// Module Name: gdma_reg
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
//`default_nettype none

module gdma_reg(
    input wire          zynq2gdma_reg_clk,
    input wire          zynq2gdma_reg_rst,
    input wire [12:0]   zynq2gdma_reg_addr,
    input wire [31:0]   zynq2gdma_reg_wrdata,
    output reg [31:0]   zynq2gdma_reg_rddata,
    input wire          zynq2gdma_reg_en,
    input wire [3:0]    zynq2gdma_reg_we,
//
    //0
    output wire [48:0] gdma0_start_rd_addr,
    output wire [31:0] gdma0_rd_length,
    output wire [48:0] gdma0_start_wr_addr,
    output wire [31:0] gdma0_wr_length,
    //1
    output wire [48:0] gdma1_start_rd_addr,
    output wire [31:0] gdma1_rd_length,
    output wire [48:0] gdma1_start_wr_addr,
    output wire [31:0] gdma1_wr_length,
    //2
    output wire [48:0] gdma2_start_rd_addr,
    output wire [31:0] gdma2_rd_length,
    output wire [48:0] gdma2_start_wr_addr,
    output wire [31:0] gdma2_wr_length,
    //3
    output wire [48:0] gdma3_start_rd_addr,
    output wire [31:0] gdma3_rd_length,
    output wire [48:0] gdma3_start_wr_addr,
    output wire [31:0] gdma3_wr_length,
    //
    output wire        gdma0_rd_start,
    output wire        gdma0_wr_start,
    output wire        gdma1_rd_start,
    output wire        gdma1_wr_start,
    output wire        gdma2_rd_start,
    output wire        gdma2_wr_start,
    output wire        gdma3_rd_start,
    output wire        gdma3_wr_start,
    output wire [31:0] gdma_speed_divider,
    output wire        gdma_package_bypass
);
reg [31:0] mem [0:25];
//gdma regs;
//reg0
assign gdma0_start_rd_addr[31:0]  = mem[0][31:0];
assign gdma0_start_rd_addr[48:32] = mem[1][16:0];
assign gdma0_rd_length[31:0]      = mem[2][31:0];
assign gdma0_start_wr_addr[31:0]  = mem[3][31:0];
assign gdma0_start_wr_addr[48:32] = mem[4][16:0];
assign gdma0_wr_length[31:0]      = mem[5][31:0];
//reg1
assign gdma1_start_rd_addr[31:0]  = mem[6][31:0];
assign gdma1_start_rd_addr[48:32] = mem[7][16:0];
assign gdma1_rd_length[31:0]      = mem[8][31:0];
assign gdma1_start_wr_addr[31:0]  = mem[9][31:0];
assign gdma1_start_wr_addr[48:32] = mem[10][16:0];
assign gdma1_wr_length[31:0]      = mem[11][31:0];
//reg2
assign gdma2_start_rd_addr[31:0]  = mem[12][31:0];
assign gdma2_start_rd_addr[48:32] = mem[13][16:0];
assign gdma2_rd_length[31:0]      = mem[14][31:0];
assign gdma2_start_wr_addr[31:0]  = mem[15][31:0];
assign gdma2_start_wr_addr[48:32] = mem[16][16:0];
assign gdma2_wr_length[31:0]      = mem[17][31:0];
//reg3
assign gdma3_start_rd_addr[31:0]  = mem[18][31:0];
assign gdma3_start_rd_addr[48:32] = mem[19][16:0];
assign gdma3_rd_length[31:0]      = mem[20][31:0];
assign gdma3_start_wr_addr[31:0]  = mem[21][31:0];
assign gdma3_start_wr_addr[48:32] = mem[22][16:0];
assign gdma3_wr_length[31:0]      = mem[23][31:0];
//
assign gdma0_rd_start             = mem[24][0];
assign gdma0_wr_start             = mem[24][1];
assign gdma1_rd_start             = mem[24][2];
assign gdma1_wr_start             = mem[24][3];
assign gdma2_rd_start             = mem[24][4];
assign gdma2_wr_start             = mem[24][5];
assign gdma3_rd_start             = mem[24][6];
assign gdma3_wr_start             = mem[24][7];
assign gdma_package_bypass        = mem[24][8];
assign gdma_speed_divider         = mem[25][31:0];

//data input;
genvar i;
generate
    for(i=0;i<26;i=i+1) begin: mem_rw
        always@(posedge zynq2gdma_reg_clk or posedge zynq2gdma_reg_rst) begin
            if(zynq2gdma_reg_rst)
                mem[i][31:0] <= 32'h0;
            else if(zynq2gdma_reg_en && (zynq2gdma_reg_addr[11:2]==i)) begin
                mem[i][7:0]   <= (zynq2gdma_reg_we[0])? zynq2gdma_reg_wrdata[7:0]  :mem[i][7:0];
                mem[i][15:8]  <= (zynq2gdma_reg_we[1])? zynq2gdma_reg_wrdata[15:8] :mem[i][15:8];
                mem[i][23:16] <= (zynq2gdma_reg_we[2])? zynq2gdma_reg_wrdata[23:16]:mem[i][23:16];
                mem[i][31:24] <= (zynq2gdma_reg_we[3])? zynq2gdma_reg_wrdata[31:24]:mem[i][31:24];
            end
            else 
                mem[i][31:0] <= mem[i][31:0];
        end
    end
endgenerate
//data output;
always@(posedge zynq2gdma_reg_clk or posedge zynq2gdma_reg_rst) begin
    if(zynq2gdma_reg_rst)
        zynq2gdma_reg_rddata <= 32'h0;
    else if(zynq2gdma_reg_en) begin
        case(zynq2gdma_reg_addr[11:2])
            10'h0:  zynq2gdma_reg_rddata <= mem[0][31:0];
            10'h1:  zynq2gdma_reg_rddata <= mem[1][31:0];
            10'h2:  zynq2gdma_reg_rddata <= mem[2][31:0];
            10'h3:  zynq2gdma_reg_rddata <= mem[3][31:0];
            10'h4:  zynq2gdma_reg_rddata <= mem[4][31:0];
            10'h5:  zynq2gdma_reg_rddata <= mem[5][31:0];
            10'h6:  zynq2gdma_reg_rddata <= mem[6][31:0];
            10'h7:  zynq2gdma_reg_rddata <= mem[7][31:0];
            10'h8:  zynq2gdma_reg_rddata <= mem[8][31:0];
            10'h9:  zynq2gdma_reg_rddata <= mem[9][31:0];
            10'hA:  zynq2gdma_reg_rddata <= mem[10][31:0];
            10'hB:  zynq2gdma_reg_rddata <= mem[11][31:0];
            10'hC:  zynq2gdma_reg_rddata <= mem[12][31:0];
            10'hD:  zynq2gdma_reg_rddata <= mem[13][31:0];
            10'hE:  zynq2gdma_reg_rddata <= mem[14][31:0];
            10'hF:  zynq2gdma_reg_rddata <= mem[15][31:0];
            10'h10: zynq2gdma_reg_rddata <= mem[16][31:0];
            10'h11: zynq2gdma_reg_rddata <= mem[17][31:0];
            10'h12: zynq2gdma_reg_rddata <= mem[18][31:0];
            10'h13: zynq2gdma_reg_rddata <= mem[19][31:0];
            10'h14: zynq2gdma_reg_rddata <= mem[20][31:0];
            10'h15: zynq2gdma_reg_rddata <= mem[21][31:0];
            10'h16: zynq2gdma_reg_rddata <= mem[22][31:0];
            10'h17: zynq2gdma_reg_rddata <= mem[23][31:0];
            10'h18: zynq2gdma_reg_rddata <= mem[24][31:0];
            10'h19: zynq2gdma_reg_rddata <= mem[25][31:0];
            default: zynq2gdma_reg_rddata <= 32'h0;
        endcase
    end
end

endmodule
