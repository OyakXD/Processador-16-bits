`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2026 06:08:59 PM
// Design Name: 
// Module Name: register_file
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
module register_file #(parameter N=16)(
    input clk,
    input rst,
    input rd_wr,                
    input [2:0] rd_sel,         
    input [2:0] rm_sel, rn_sel, 
    input [N-1:0] rd_data,      
    output [N-1:0] rm, rn       
    );
    
    reg [N-1:0] registers [0:7];
    integer i;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                registers[i] <= 0;
        end else if (rd_wr) begin
            registers[rd_sel] <= rd_data;
        end
    end
     
    assign rm = registers[rm_sel];
    assign rn = registers[rn_sel];
    
endmodule
