`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/20 11:00:24
// Design Name: 
// Module Name: test_mem
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


module mem_model_top(
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
    output  wire        core2gtp_tlast    
   
   
    );
    //wire reg
    //dut_model
    wire ena_model           ;
    wire wea_model           ;
    wire [15:0] addra_model  ;
    wire [7:0]  dina_model   ;
    wire [7:0]  douta_model ;
    
    //dut memory interface
    wire ena;
    wire wea;
    wire [15:0] addra;
    wire [7:0]  dina ;
    wire [7:0]  douta;
    
    //model2dut
    wire [31:0] dut_data;
    wire        dut_valid;
    
    
    /**************************************model*****************************/
    //axi2model
    axis2model_if u_axis2model_if (
        .core_clk           (core_clk),
        .rst_n              (rst_n),
                            
        //axi_stream data   
        .gtp2core_tdata     (gtp2core_tdata ),
        .gtp2core_tvalid    (gtp2core_tvalid),
        .gtp2core_tready    (gtp2core_tready),
        .gtp2core_tlast     (gtp2core_tlast ),
        
        //dut_model interface
        .ena_model          (ena_model  ),
        .wea_model          (wea_model  ),
        .addra_model        (addra_model),
        .dina_model         (dina_model ),
        .douta_model        (douta_model),
        
        //model2dut
        .dut_data           (dut_data),
        .dut_valid          (dut_valid)
    );
    
    //dut_model
    dut_mem dut_memory_model (
        .clka (core_clk     ),    // input wire clka
        .ena  (ena_model    ),      // input wire ena
        .wea  (wea_model    ),      // input wire [0 : 0] wea
        .addra(addra_model  ),  // input wire [14 : 0] addra
        .dina (dina_model   ),    // input wire [7 : 0] dina
        .douta(douta_model  )  // output wire [7 : 0] douta
    );
    
    /**************************************model*****************************/
    
    /**************************************dut*****************************/
    axis2mem_if u_axis2mem_if(
    .core_clk           (core_clk),
    .rst_n              (rst_n),
                       
    .dut_data           (dut_data),
    .dut_valid          (dut_valid),
                        
    .core2gtp_tdata     (core2gtp_tdata ),
    .core2gtp_tvalid    (core2gtp_tvalid),
    .core2gtp_tready    (core2gtp_tready),
    .core2gtp_tlast     (core2gtp_tlast ),
                        
    //dut interface     
    .ena                (ena  ),
    .wea                (wea  ),
    .addra              (addra),
    .dina               (dina ),
    .douta              (douta)
    
    );

    //dut memory
    dut_mem dut_memory_chip (
        .clka(core_clk),    // input wire clka
        .ena(ena),      // input wire ena
        .wea(wea),      // input wire [0 : 0] wea
        .addra(addra),  // input wire [14 : 0] addra
        .dina(dina),    // input wire [7 : 0] dina
        .douta(douta)  // output wire [7 : 0] douta
    );
    
    /**************************************dut*****************************/
    
    //ila
    ila_mem u_ila_mem (
    	.clk(core_clk), // input wire clk
    	.probe0(ena), // input wire [0:0]  probe0  
    	.probe1(wea), // input wire [0:0]  probe1 
    	.probe2(addra[14:0]), // input wire [14:0]  probe2 
    	.probe3(dina), // input wire [7:0]  probe3 
    	.probe4(douta) // input wire [7:0]  probe4
    );
    
    ila_mem u_ila_mem_model (
    	.clk(core_clk), // input wire clk
    	.probe0(ena_model), // input wire [0:0]  probe0  
    	.probe1(wea_model), // input wire [0:0]  probe1 
    	.probe2(addra_model[14:0]), // input wire [14:0]  probe2 
    	.probe3(dina_model), // input wire [7:0]  probe3 
    	.probe4(douta_model) // input wire [7:0]  probe4
    );
endmodule
