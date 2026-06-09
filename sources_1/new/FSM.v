`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 04:01:32 PM
// Design Name: 
// Module Name: FSM
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


module FSM #(parameter N=16)(
    input clk, rst,
    input [N-1:0] IR_data,
    input z_flag, c_flag,
    output reg ROM_en,
    output reg PC_clr,
    output reg PC_inc,
    output reg IR_load,
    output reg [N-1:0] Immed,
    output reg RAM_sel,
    output reg RAM_we,
    output reg [1:0] RF_sel,
    output reg [2:0] Rd_sel,
    output reg Rd_wr,
    output reg [2:0] Rm_sel,
    output reg [2:0] Rn_sel,
    output reg [3:0] ula_op,
    output reg SP_inc, SP_dec,
    output reg s_branch_en,
    output reg flag_wr,
    output reg io_rd,  // READ
    output reg io_wr,  // WRITE
    output reg io_immed
);
    
    localparam init  =            4'd0,
               fetch         =      4'd1,
               decode        =      4'd2,
               exec_mov      =      4'd5,
               exec_nop      =      4'd3,
               exec_load     =      4'd6,
               exec_store    =      4'd7,
               exec_ula      =      4'd8,
               exec_push     =      4'd9,
               exec_pop      =      4'd10,
               exec_branch   =      4'd11,
               exec_pop_wait =      4'd12,
               exec_in       =      4'd13,
               exec_out      =      4'd14,
               exec_halt     =      4'd4;
               
               
    reg [3:0] ps, ns;
    
    
    always @(posedge clk or posedge rst) begin
        if(rst) 
            ps <= init;
        else
            ps <= ns;
    end
    
    always @(*) begin
        case(ps)
            init:   ns <= fetch;
            fetch:  ns <= decode;
            decode: begin
                if(IR_data == 16'h0000)
                    ns <= exec_nop;
                else if(IR_data == 16'hffff)
                    ns <=  exec_halt;
                else begin
                    case(IR_data[15:12])
                        4'b0000: begin
                            if(IR_data[11] == 1'b0) begin
                                case(IR_data[1:0])
                                    2'b01: ns = exec_push;
                                    2'b10: ns = exec_pop;
                                    2'b11: ns = exec_ula;
                                endcase
                            end else begin
                               case(IR_data[1:0])
                                    2'b00,
                                    2'b01, 
                                    2'b10, 
                                    2'b11: ns = exec_branch;
                                    default: ns = exec_nop;
                               endcase
                            end
                        end
                        4'b0001: ns = exec_mov;
                        4'b0010: ns = exec_store;
                        4'b0011: ns = exec_load;
                        4'b0100,
                        4'b0101,
                        4'b0110,
                        4'b0111,
                        4'b1000,
                        4'b1001,
                        4'b1010,
                        4'b1011,
                        4'b1100,
                        4'b1101,
                        4'b1110: ns = exec_ula;
                        4'b1111: begin
                            if(IR_data[1:0] == 2'b01)
                                ns = exec_in;
                            else if (IR_data[1:0] == 2'b10)
                                ns = exec_out;
                            else
                                ns = exec_nop;
                        end
                        default: ns = exec_nop;
                    endcase
                end
            end 
            
            exec_nop      : ns = fetch;
            exec_halt     : ns = init;
            exec_mov      : ns = fetch;
            exec_load     : ns = fetch;
            exec_store    : ns = fetch;
            exec_ula      : ns = fetch;
            exec_push     : ns = fetch;
            exec_pop      : ns = exec_pop_wait;
            exec_pop_wait : ns = fetch;
            exec_in       : ns = fetch;
            exec_out      : ns = fetch;
            exec_branch   : ns = fetch;
            default       : ns = init;
            endcase
     end
         
     always @(*) begin
        PC_clr      = 0;
        PC_inc      = 0;
        ROM_en      = 0;    
        IR_load     = 0;
        Immed       = 16'h0000;
        RAM_sel     = 0;
        RAM_we      = 0;
        RF_sel      = 2'b00;
        Rd_sel      = 3'b000;
        Rd_wr       = 0;
        Rm_sel      = 3'b000;
        Rn_sel      = 3'b000;
        ula_op      = 4'b1111;
        SP_inc      = 0;
        SP_dec      = 0;
        s_branch_en = 0;
        flag_wr     = 0;
        io_rd       = 0;
        io_wr       = 0;
        io_immed    = 0;
        
        case(ps)
            init: begin
                PC_clr = 1;
            end
            fetch: begin
                PC_inc  = 1;
                ROM_en  = 1;
                IR_load = 1;
            end
            exec_mov: begin
                Rd_wr  = 1'b1;
                RF_sel = {IR_data[11], 1'b0};
                Immed  = {8'h00,IR_data[7:0]};
                Rm_sel = IR_data[7:5];
                Rd_sel = IR_data[10:8];
                
            end
            exec_load: begin
                RF_sel  = 2'b01;
                Rd_wr   = 1'b1;
            end
            exec_store: begin
                RAM_we = 1;
                Rm_sel = IR_data[7:5];
                Immed  = {8'h00,IR_data[10:8],IR_data[4:0]};
                Rn_sel = IR_data[4:2];
            end
            exec_ula: begin
                Rd_wr   = !(IR_data[15:12] == 4'b0000 && IR_data[1:0] == 2'b11);
                RF_sel  = 2'b11;
                ula_op  = IR_data[15:12];
                Rd_sel  = IR_data[10:8];
                Rm_sel  = IR_data[7:5];
                Rn_sel  = IR_data[4:2];
                Immed   = {8'h00,IR_data[4:0]};
                flag_wr = (IR_data[15:12]==4'b0000 && IR_data[1:0]==2'b11);
            end
            exec_push: begin
                RAM_we  = 1;
                RAM_sel = 1;
                Rn_sel  = IR_data[4:2];
                SP_dec  = 1;
            end
            exec_pop: begin
                RAM_sel = 1;
                SP_inc  = 1;
            end
            exec_pop_wait: begin
                RAM_sel = 1;
                RF_sel  = 2'b01;
                Rd_wr   = 1;
                Rd_sel  = IR_data[10:8];
            end
            exec_in: begin
                Rd_wr = 1;
                RF_sel = 2'b10;
                Rd_sel = IR_data[10:8];
                io_rd = 1;
            end
            exec_out: begin
                io_wr = 1;
                if (IR_data[11] == 1'b1) begin
                    io_immed = 1;
                    Immed = {3'b000, IR_data[10:8], IR_data[4:0]};
                end else begin
                    Rm_sel = IR_data[7:5];
                end
            end
            exec_branch: begin
                Immed = {{7{IR_data[10]}}, IR_data[10:2]};
                case(IR_data[1:0])
                    2'b00: s_branch_en = 1;
                    2'b01: s_branch_en = (z_flag & ~c_flag);
                    2'b10: s_branch_en = (~z_flag & c_flag);
                    2'b11: s_branch_en = (~z_flag & ~c_flag);
                endcase
                PC_inc = s_branch_en;
            end
         endcase
     end 
endmodule
