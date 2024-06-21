`timescale 1ns / 1ps
//`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/26 20:14:08
// Design Name: 
// Module Name: gdma_rdata
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

module gdma_rdata(
//
    input wire clk,
    input wire rst,
    input wire [31:0] length,
    input wire op_start,
    input wire gdma_addr_done,
    output reg gdma_done = 1'b1,
//
	input wire [31:0]  gdma_speed_divider,
	input wire         gdma_package_bypass,
//
    input wire [31:0]  gdma_ddr_rdata,
    input wire         gdma_ddr_rlast,
    output wire        gdma_ddr_rready,
    input wire [1:0]   gdma_ddr_rresp,
    input wire         gdma_ddr_rvalid,
//
    output wire        gdma2gtp_tvalid,
    input wire         gdma2gtp_tready,
    output wire [31:0] gdma2gtp_tdata,
    output wire        gdma2gtp_tlast,//reg
    
    input wire         last_ctrl
);
reg [29:0] 	rdata_cnt;
reg 		rdata_done;

wire package2gtp_tvalid;
wire package2gtp_tready;
wire [31:0] package2gtp_tdata;
//rd control;
always@(posedge clk or posedge rst) begin
    if(rst)
        gdma_done <= 1'b1;
    else if(op_start)
        gdma_done <= 1'b0;
    else if(gdma_addr_done && rdata_done) 
        gdma_done <= 1'b1;
end
//read data;
always@(posedge clk) begin
    if(op_start) begin
        rdata_cnt <= length[31:2];
        rdata_done <= 1'b0;
    end
    else if(gdma_ddr_rvalid && gdma_ddr_rready) begin
        rdata_cnt <= (rdata_cnt=='h0)? rdata_cnt:rdata_cnt-1'b1;
        rdata_done <= (rdata_cnt=='h0)? 1'b1:1'b0;
    end
end

//assign gdma2gtp_tvalid = (gdma_package_bypass)? gdma_ddr_rvalid:package2gtp_tvalid;
//assign gdma2gtp_tdata  = (gdma_package_bypass)? gdma_ddr_rdata:package2gtp_tdata;
//assign gdma_ddr_rready = (gdma_package_bypass)? gdma2gtp_tready:package2gtp_tready;
assign gdma2gtp_tvalid = trans_en? gdma_ddr_rvalid : 1'b0;
assign gdma2gtp_tdata  = gdma_ddr_rdata; 
assign gdma_ddr_rready = trans_en? gdma2gtp_tready : 1'b0;
//assign gdma_ddr_rready = gdma2gtp_tready;

assign gdma2gtp_tlast  = (rdata_cnt=='h0)?gdma_ddr_rlast:1'b0; 

reg [31:0]  catch_length_cnt;
reg         catch_cnt_run;
reg [31:0]  last_cnt;

always@(posedge clk or posedge rst) begin
    if(rst) 
        catch_cnt_run <= 1'b0;
    else if(last_ctrl)
         catch_cnt_run <= 1'b0;
    else if(op_start)
        catch_cnt_run <= 1'b1;
    else if(rdata_cnt == 30'h0)
        catch_cnt_run <= 1'b0;
    else catch_cnt_run <= catch_cnt_run;
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
        catch_length_cnt <= 32'b0;
    end
    else if(last_ctrl)
        catch_length_cnt <= 32'b0;
    else if(gdma2gtp_tlast & last_cnt_run)//(last_cnt == 32'h0) & last_cnt_run
        catch_length_cnt <= 32'b0;
    else if(catch_cnt_run & gdma_ddr_rready & gdma_ddr_rvalid)
        catch_length_cnt  <= catch_length_cnt + 1'b1;
    else catch_length_cnt <= catch_length_cnt;
end

reg last_cnt_run;
always@(posedge clk or posedge rst) begin
    if(rst) begin
        last_cnt_run <= 1'b0;
    end
    else if(last_ctrl)
        last_cnt_run <= 1'b0;
    else if(catch_length_cnt == 32'd2)
        last_cnt_run <= 1'b1;
    else if(last_cnt==32'd0)
        last_cnt_run <= 1'b0;
    else last_cnt_run <= last_cnt_run;
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
        last_cnt <= 32'h0;
    end
    else if(last_ctrl)
        last_cnt <= 32'h0;
    else if(catch_length_cnt == 32'd2) begin
        last_cnt <= gdma_ddr_rdata << 1 ;
    end
    else if(last_cnt_run & gdma_ddr_rready & gdma_ddr_rvalid) begin
        last_cnt <= last_cnt - 1'b1;
    end
    else begin
        last_cnt <= last_cnt;
    end
end

//read
reg read_flag;
always@(posedge clk or posedge rst) begin
    if(rst)
        read_flag <= 1'b0;
    else if(last_ctrl)
        read_flag <= 1'b0;
    else if(gdma2gtp_tlast)
        read_flag <= 1'b0;
    else if((catch_length_cnt == 32'd1) && (gdma_ddr_rdata[31:29] == 3'b010) & gdma_ddr_rready & gdma_ddr_rvalid)
        read_flag <= 1'b1;
    else read_flag <= read_flag;
end

//always@(posedge clk or posedge rst) begin
//    if(rst)
//        gdma2gtp_tlast <= 1'b0;
//    else if(last_ctrl)
//        gdma2gtp_tlast <= 1'b0;
//    else if(gdma_ddr_rready & gdma_ddr_rvalid & gdma2gtp_tlast)
//        gdma2gtp_tlast <= 1'b0;
//    else if((last_cnt==32'd1 & gdma_ddr_rready & gdma_ddr_rvalid) | read_flag & gdma_ddr_rready & gdma_ddr_rvalid)
//        gdma2gtp_tlast <= 1'b1;
//    else gdma2gtp_tlast <= gdma2gtp_tlast;
// end 

//assign gdma2gtp_tlast  = (last_cnt_run & (last_cnt==32'd0)) ? 1'b1 : 1'b0; 

ila_rlength u_ila_rlength (
	.clk(clk), // input wire clk
	.probe0(gdma_ddr_rdata), // input wire [31:0]  probe0  
	.probe1(gdma_ddr_rlast), // input wire [0:0]  probe1 
	.probe2(gdma_ddr_rready), // input wire [0:0]  probe2 
	.probe3(gdma_ddr_rvalid), // input wire [0:0]  probe3 
	.probe4(gdma2gtp_tdata), // input wire [31:0]  probe4 
	.probe5(gdma2gtp_tlast), // input wire [0:0]  probe5 
	.probe6(catch_length_cnt), // input wire [31:0]  probe6 
	.probe7(catch_cnt_run), // input wire [0:0]  probe7 
	.probe8(last_cnt), // input wire [31:0]  probe8 
	.probe9(op_start), // input wire [0:0]  probe9 
	.probe10(rdata_cnt) // input wire [29:0]  probe10
);

wire trans_en;
reg [31:0] trans_cnt;
assign trans_en = (trans_cnt[31:0]==32'h0);

always@(posedge clk or posedge rst) begin
    if(rst) 
        trans_cnt <= 32'h0;
    else
        trans_cnt <= (trans_en)? gdma_speed_divider:trans_cnt-1'b1;
end

//always@(posedge clk or posedge rst) begin
//    if(rst)
//        trans_en <= 1'b0;
//    else if(gdma2gtp_tlast)
//        trans_en <= 1'b0;
//    else if(trans_cnt == gdma_speed_divider)
//        trans_en <= !trans_en;
//    else trans_en <= trans_en;
//end

//always@(posedge clk or posedge rst) begin
//    if(rst)
//        trans_cnt <= 32'b0;
//    else if(gdma2gtp_tlast | (trans_cnt == gdma_speed_divider))
//        trans_cnt <= 32'b0;
//    else if(gdma_ddr_rvalid)
//        trans_cnt <= trans_cnt + 1'b1;
//    else trans_cnt <= trans_cnt;
//end

ila_trans u_ila_trans (
	.clk(clk), // input wire clk
	.probe0(trans_cnt), // input wire [31:0]  probe0  
	.probe1(gdma_ddr_rvalid), // input wire [0:0]  probe1 
	.probe2(trans_en), // input wire [0:0]  probe2 
	.probe3(gdma_ddr_rready) // input wire [0:0]  probe3
);

//ila_rdata ila_rdata (
//	.clk(clk), // input wire clk


//	.probe0(rdata_cnt), // input wire [29:0]  probe0  
//	.probe1(gdma_ddr_rvalid), // input wire [0:0]  probe1 
//	.probe2(gdma_ddr_rready), // input wire [0:0]  probe2 
//	.probe3(gdma2gtp_tlast), // input wire [0:0]  probe3 
//	.probe4(gdma_ddr_rlast) // input wire [0:0]  probe4
//);

//gdma_rdata_package gdma_rdata_package(
//    .clk                (clk),
//    .rst                (rst | gdma_package_bypass),
//    .op_start           (op_start & !gdma_package_bypass),
//    .gdma_speed_divider (gdma_speed_divider),
//    .gdma_rd_tvalid     (gdma_ddr_rvalid & !gdma_package_bypass),
//    .gdma_rd_tready     (package2gtp_tready),
//    .gdma_rd_tdata      (gdma_ddr_rdata),
//    .gdma2gtp_tvalid    (package2gtp_tvalid),
//    .gdma2gtp_tready    (gdma2gtp_tready),
//    .gdma2gtp_tdata     (package2gtp_tdata)
//);

endmodule

