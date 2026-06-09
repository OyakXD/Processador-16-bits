`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2026 07:57:47 PM
// Design Name: 
// Module Name: IR
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


module IR #(parameter N=16)(
    input i_Clk,
    input i_Rst,
    input i_ld,
    input [N-1:0] i_d,
    output [N-1:0] q
    );
  
    GenericRegister register (
        .i_Clk(i_Clk),
        .i_Rst(i_Rst),
        .i_ld(i_ld),
        .i_D(i_d),
        .q(q)
    );
    
endmodule
