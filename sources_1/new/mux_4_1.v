`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2026 06:08:59 PM
// Design Name: 
// Module Name: mux_4_1
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


module mux_4_1 #(parameter N=16)(
    input [N-1:0] I0, I1, I2, I3,
    input [1:0] sel,
    output reg [N-1:0] O0
    );

    always @(*)begin
        case(sel)
            2'b00: O0=I0;
            2'b01: O0=I1;
            2'b10: O0=I2;
            2'b11: O0=I3;
            default: O0 <= {N{1'b0}};
        endcase
    end
endmodule
