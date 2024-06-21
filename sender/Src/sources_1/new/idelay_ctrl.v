`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/12 17:47:02
// Design Name: 
// Module Name: idelay_ctrl
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

module idelay_ctrl(
    input									clk		    ,//200MHZ
    input									rst 	    ,//high active

    input				            	    din		    ,//delay data
    input                                   ce          ,
    input                                   inc         ,
    input                                   ld          ,
    input                                   ldpipeen    ,
    input                                   reg_rst     ,
    input       [4 : 0]                     cntvaluein  ,

    output      [4 : 0]                     cntalueout  ,
    output                                  rdy         ,
    output  	                            dout	     //after delay
    );

    wire                                    out         ;
    assign dout = out;

    (* IODELAY_GROUP = "IDELAY_CTRL" *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL
    IDELAYE2 #(
        .CINVCTRL_SEL           ("FALSE"    ),// Enable dynamic clock inversion (FALSE, TRUE)
        .DELAY_SRC              ("IDATAIN"  ),// Delay input (IDATAIN, DATAIN)
        .HIGH_PERFORMANCE_MODE  ("FALSE"    ),// Reduced jitter ("TRUE"), Reduced power ("FALSE")
        .IDELAY_TYPE            ("VAR_LOAD"    ),// FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
        .IDELAY_VALUE           (0          ),// Input delay tap setting (0-31)
        .PIPE_SEL               ("FALSE"     ),// Select pipelined mode, FALSE, TRUE
        .REFCLK_FREQUENCY       (200.0       ),// IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
        .SIGNAL_PATTERN         ("CLOCK"     ) // DATA, CLOCK input signal
    )
    IDELAYE2_inst (
        .CNTVALUEOUT    ( cntalueout    ),// 5-bit output: Counter value output
        .DATAOUT        ( out           ),// 1-bit output: Delayed data output
        .C              ( clk           ),// 1-bit input: Clock input
        .CE             ( ce            ),// 1-bit input: Active high enable increment/decrement input
        .CINVCTRL       ( 1'b0          ),// 1-bit input: Dynamic clock inversion input
        .CNTVALUEIN     ( cntvaluein    ),// 5-bit input: Counter value input
        .DATAIN         ( 1'b0          ),// 1-bit input: Internal delay data input
        .IDATAIN        ( din           ),// 1-bit input: Data input from the I/O
        .INC            ( inc           ),// 1-bit input: Increment / Decrement tap delay input
        .LD             ( ld            ),// 1-bit input: Load IDELAY_VALUE input
        .LDPIPEEN       ( ldpipeen      ),// 1-bit input: Enable PIPELINE register to load data input
        .REGRST         ( reg_rst       ) // 1-bit input: Active-high reset tap-delay input
    );

    //IDELAYCTRL
    (* IODELAY_GROUP = "IDELAY_CTRL"  *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL
    IDELAYCTRL IDELAYCTRL_inst (
        .RDY    ( rdy   ),// 1-bit output: Ready output
        .REFCLK ( clk   ),// 1-bit input: Reference clock input
        .RST    ( rst   ) // 1-bit input: Active high reset input
    );
    
endmodule