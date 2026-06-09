`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2026 10:59:31 AM
// Design Name: 
// Module Name: top
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


module top(
    input clk,
    input rst,
    
    input [3:0] sw,
    output [3:0] led
);
    
    wire [7:0] io_data_out;
    
    processor16Bit cpu (
        .clk(clk),
        .rst(rst),
        .io_data_in({4'b0000,sw}),
        .io_data_out(io_data_out)
    );
    
    assign led = io_data_out[3:0];
    
endmodule
