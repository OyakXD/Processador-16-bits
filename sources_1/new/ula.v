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


module ula #(parameter N=16)(
    input [N-1:0] A,
    input [N-1:0] B,
    input [3:0] op,
    input [N-1:0] immed,
    output reg [N-1:0] Q,
    output reg zero_flag,
    output reg carry_flag
    );

    always @(*)begin
          Q          = 0; 
          zero_flag  = 0; 
          carry_flag = 0;
        case(op)
            4'b0000: begin                   // CMP
            zero_flag  = (A == B);
            carry_flag = (A < B);
            end
            4'b0100: Q = (A + B);            // ADD
            4'b0101: Q = (A - B);            // SUB
            4'b0110: Q = (A * B);            // MUL
            4'b0111: Q = (A & B);            // AND
            4'b1000: Q = (A | B);            // OR
            4'b1001: Q = (~A);               // NOT
            4'b1010: Q = (A ^ B);            // XOR
            4'b1011: Q = A >> immed[4:0];    // SHR             
            4'b1100: Q = A << immed[4:0];    // SHL            
            4'b1101: Q = {A[0], A[N-1:1]};   // ROR            
            4'b1110: Q = {A[N-2:0], A[N-1]}; // ROL
            default: begin 
                Q = 0; 
            end
        endcase
    end 
endmodule
