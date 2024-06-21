`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/25 09:30:07
// Design Name: 
// Module Name: gdma_rdata_package
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


module gdma_rdata_package(
	input wire clk,
	input wire rst,
	input wire op_start,
	input wire [31:0] gdma_speed_divider,
//
	input wire gdma_rd_tvalid,
	output wire gdma_rd_tready,
	input wire [31:0] gdma_rd_tdata,
//
	output wire gdma2gtp_tvalid,
	input wire gdma2gtp_tready,
    output wire [31:0] gdma2gtp_tdata
);
//WORD_LENGTH only include data part;
//WORD_LENGTH start from 0;
localparam CHIP_POS=2'h0,WORD_LENGTH=2'h1,DATA=2'h2,DATA_LAG=2'h3;

reg [1:0] state;
reg [31:0] divider_cnt;
reg chip_pos_en;
reg skid_path;
reg rd_tready;
reg block_load;

reg [6:0] chip_column;
reg [6:0] chip_row;
reg [31:0] block_prev_length;
reg [31:0] block_post_length;

wire gdma_rdconv_tvalid;
wire gdma_rdconv_tready;
wire [31:0] gdma_rdconv_tdata;
wire block_prev_done;
wire block_post_done;

wire 		transfer_en;
wire 		gdma_rdout_tvalid;
wire 		gdma_rdout_tready;
wire [31:0] gdma_rdout_tdata;



//ila_rdata ila_rdata (
//	.clk(clk), // input wire clk


//	.probe0(gdma_rd_tdata), // input wire [31:0]  probe0  
//	.probe1(gdma_rd_tvalid), // input wire [0:0]  probe1 
//	.probe2(gdma_rd_tready) // input wire [0:0]  probe2
//);

assign gdma_rdconv_tvalid = (skid_path)? gdma_rd_tvalid:1'b0;
assign gdma_rd_tready = (skid_path)? gdma_rdconv_tready:rd_tready;
assign gdma_rdconv_tdata = gdma_rd_tdata;
always@(posedge clk or posedge rst) begin
	if(rst || op_start) begin
		state <= CHIP_POS;
		chip_pos_en <= 1'b1;
		{skid_path, rd_tready} <= 2'b01;
		block_load <= 1'b0;
	end
	else begin
		case(state)
			CHIP_POS: begin
				if(gdma_rd_tvalid && gdma_rd_tready) begin
					state <= WORD_LENGTH;
					chip_pos_en <= 1'b0;
					block_load <= 1'b1;
				end
				else begin
					state <= CHIP_POS;
					chip_pos_en <= 1'b1;
					block_load <= 1'b0;
				end
				{skid_path, rd_tready} <= 2'b01;
			end
			WORD_LENGTH: begin
				if(gdma_rd_tvalid && gdma_rd_tready) begin
					state <= DATA;
					block_load <= 1'b0;
					{skid_path, rd_tready} <= 2'b00;
				end
				else begin
					state <= WORD_LENGTH;
					block_load <= 1'b1;
					{skid_path, rd_tready} <= 2'b01;
				end
				chip_pos_en <= 1'b0;
			end
			DATA: begin
				if(gdma_rd_tvalid && gdma_rd_tready && block_prev_done) begin
					state <= DATA_LAG;
					{skid_path, rd_tready} <= 2'b00;
				end
				else begin
					state <= DATA;
					{skid_path, rd_tready} <= 2'b10;
				end
				chip_pos_en <= 1'b0;
				block_load <= 1'b0;
			end
			DATA_LAG: begin
				if(gdma2gtp_tvalid && gdma2gtp_tready && block_post_done) begin
					state <= CHIP_POS;
					chip_pos_en <= 1'b1;
					{skid_path, rd_tready} <= 2'b01;
				end
				else begin
					state <= DATA_LAG;
					chip_pos_en <= 1'b0;
					{skid_path, rd_tready} <= 2'b00;
				end
				block_load <= 1'b0;
			end
			default: begin
				state <= CHIP_POS;
				chip_pos_en <= 1'b1;
				block_load <= 1'b0;
				{skid_path, rd_tready} <= 2'b01;
			end
		endcase
	end
end

assign block_prev_done = (block_prev_length=='h0);
always@(posedge clk or posedge rst) begin
	if(rst || op_start)
		block_prev_length <= 'h0;
	else if(block_load)
		block_prev_length <= {1'b0,gdma_rd_tdata[30:0]};
	else if(gdma_rd_tvalid && gdma_rd_tready)
		block_prev_length <= (block_prev_done)? block_prev_length:block_prev_length-1'b1;
	else 
		block_prev_length <= block_prev_length;
end
//add data header;
gdma_rdata_width_converter gdma_rdata_width_converter(
    .s_axis_tvalid  (gdma_rdconv_tvalid),
    .s_axis_tready  (gdma_rdconv_tready),
    .s_axis_tdata   (gdma_rdconv_tdata),
    .aclk           (clk),
    .aresetn        (~rst),
    .m_axis_tvalid  (gdma_rdout_tvalid),
    .m_axis_tready  (gdma_rdout_tready),
    .m_axis_tdata   (gdma2gtp_tdata[15:0])
);
assign block_post_done = (block_post_length=='h0);
always@(posedge clk or posedge rst) begin
	if(rst)
		block_post_length <= 'h0;
	else if(block_load)
		block_post_length <= {gdma_rd_tdata[30:0],1'b1};  //((word_length+1)<<1)-1
	else if(gdma2gtp_tvalid && gdma2gtp_tready)
		block_post_length <= (block_post_done)? block_post_length:block_post_length-1'b1;
	else 
		block_post_length <= block_post_length;
end

assign gdma2gtp_tdata[29:16] = {chip_row,chip_column};
assign gdma2gtp_tdata[30] = 1'b1;       //download type;
assign gdma2gtp_tdata[31] = 1'b1;       //unicast identifier;
always@(posedge clk or posedge rst) begin
	if(rst) begin
		chip_column <= 'h0;
		chip_row <= 'h0;
	end
	else if(chip_pos_en) begin
		chip_column <= gdma_rd_tdata[6:0];
		chip_row <= gdma_rd_tdata[14:8];
	end
	else begin
		chip_column <= chip_column;
		chip_row <= chip_row;
	end
end

//speed divider;
assign gdma2gtp_tvalid = (transfer_en)? gdma_rdout_tvalid:1'b0;
assign gdma_rdout_tready = (transfer_en)? gdma2gtp_tready:1'b0;
assign transfer_en = (divider_cnt[31:0]==32'h0);
always@(posedge clk or posedge rst) begin
    if(rst) 
        divider_cnt <= 32'h0;
    else
        divider_cnt <= (transfer_en)? gdma_speed_divider:divider_cnt-1'b1;
end



endmodule
