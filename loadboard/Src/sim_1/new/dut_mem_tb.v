`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/18 19:41:59
// Design Name: 
// Module Name: dut_mem_tb
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


module dut_mem_tb(
    );
    reg  core_clk, ena, wea;
    reg  [14:0] addra;
    reg  [7:0]  dina;
    wire [7:0]  douta;
    
    dut_mem dut_memory_chip (
      .clka(core_clk),    // input wire clka
      .ena(ena),      // input wire ena
      .wea(wea),      // input wire [0 : 0] wea
      .addra(addra),  // input wire [14 : 0] addra
      .dina(dina),    // input wire [7 : 0] dina
      .douta(douta)  // output wire [7 : 0] douta
    );
    
    initial core_clk = 1;
    always #10 core_clk = ~core_clk;
    
    initial begin
        addra = 0;//��ʼ��ַ
        dina = 0;//��ʼ����
        ena = 0;//ʹ�ܶ˿�A
        wea = 0;//ʹ�ܶ˿�Aд��
        #1000
        ena = 1;
        wea = 1;
        addra =1;
        dina = 1;
        #20
        ena = 0;
        wea = 0;

        #40
        ena = 1;
        wea = 1;
        addra =2;
        dina = 2;
        #20
        ena = 0;
        wea = 0;

        #40
        ena = 1;
        wea = 1;
        addra =3;
        dina = 3;
        #20
        ena = 0;
        wea = 0;

        #40
        ena = 1;
        wea = 0;
        addra =1;
        dina = 0;
        #20
        ena = 0;
        wea = 0;

        #40
        ena = 1;
        wea = 0;
        addra =2;
        dina = 0;
        #20
        ena = 0;
        wea = 0;

        #40
        ena = 1;
        wea = 0;
        addra =3;
        dina = 0;
        #20
        ena = 0;
        wea = 0;

        #40
        ena = 1;
        wea = 0;
        addra =4;
        dina = 0;
        
        
        #5000
        ena = 1;//ʹ�ܶ˿�A
        wea = 1;//ʹ�ܶ˿�Aд��
        repeat(10)begin//ѭ��1024��
           #20;
           dina = dina + 1; //ÿ��ѭ������+1
           addra = addra + 1;//ÿ��ѭ����ַ+1
        end
        #20;
        ena = 1;
        wea = 0;
        dina = 0; //ÿ��ѭ������+1
        addra = 0;//ÿ��ѭ����ַ+1
        repeat(10)begin//ѭ��1024��
           #20;
           dina = 0; //ÿ��ѭ������+1
           addra = addra + 1;//ÿ��ѭ����ַ+1
        end
        #20
        ena = 0;//�ر�A�˿�ʹ��
        wea = 0;//�ر�A�˿�д��
        //dina = 0;
//        addra = 0;
        
        #1000
        ena = 1;//ʹ��B�˿ڽ��ж�ȡ   
        addra = 0;//��ʼ��ַ         
//        repeat(10)begin
//           #20;
//           addra = addra + 1 ;//ÿ�ε�ַ-1��ȡ����
//        end
        #20
        addra = 1;
        #20
        ena = 0;//�ر�A�˿�ʹ��   
         
        #20000;
        $stop;
    end
    
endmodule
