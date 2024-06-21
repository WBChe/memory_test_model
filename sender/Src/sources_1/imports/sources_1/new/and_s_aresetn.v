`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/31 09:16:54
// Design Name: 
// Module Name: and_s_aresetn
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


module and_s_aresetn(
    input   axi_aclk            ,
    input   axi_aresetn         ,
    input   peripheral_aresetn  ,
    output  s_aresetn           
    );
    reg r_s_aresetn;
    reg ri_axi_aresetn;
    reg ri_peripheral_aresetn;
    assign s_aresetn = r_s_aresetn;
    
    always@(posedge axi_aclk or negedge axi_aresetn) begin
        if(!axi_aresetn)
            ri_axi_aresetn <= 1'b0;
        else ri_axi_aresetn <= axi_aresetn;
    end
    
    always@(posedge axi_aclk or negedge axi_aresetn) begin
        if(!axi_aresetn)
            ri_peripheral_aresetn <= 1'b0;
        else ri_peripheral_aresetn <= peripheral_aresetn;
    end
    
    always@(posedge axi_aclk or negedge axi_aresetn) begin
        if(!axi_aresetn)
            r_s_aresetn <= 1'b0;
        else r_s_aresetn <= ri_peripheral_aresetn & ri_axi_aresetn;
    end
        
endmodule
