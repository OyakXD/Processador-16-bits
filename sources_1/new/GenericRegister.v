`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2026 07:45:50 PM
// Design Name: 
// Module Name: GenericRegister
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


module GenericRegister #(parameter N=16)(
    input i_Clk,
    input i_Rst,
    input i_ld,
    input [N-1:0] i_D,
    output reg [N-1:0] q
    );
    
    always@(posedge i_Clk) begin
        if(i_Rst) begin
            q <= 16'h00;
        end else if(i_ld == 1) begin
            q <= i_D;
        end
    end
endmodule
