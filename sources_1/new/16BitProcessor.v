`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2026 07:26:41 PM
// Design Name: 
// Module Name: 16BitProcessor
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


module processor16Bit #(parameter N=16)(
    input clk, rst,
    input [7:0] io_data_in,
    output [7:0] io_data_out,
    output io_rd,
    output io_wr
    );
    

// ---------------------------
//      WIRES - CONTROL UNIT 
// ---------------------------
wire ROM_en;
wire RAM_we;
wire RAM_sel;
wire Rd_wr;
wire [1:0] RF_sel;
wire [2:0] RD_sel;
wire [2:0] RM_sel;
wire [2:0] RN_sel;
wire [3:0] Ula_op;
wire [3:0] dbg_state;
wire [N-1:0] ROM_addr;
wire [N-1:0] immed;
wire [N-1:0] dbg_ir;
wire [N-1:0] SP_out;

// --------------------------------------
//      WIRES - DADOS ENTRE MÓDULOS
// --------------------------------------
wire [N-1:0] ROM_dout;
wire [N-1:0] RAM_dout;
wire [N-1:0] RAM_din;
wire [N-1:0] RAM_addr;
wire SP_inc;
wire SP_dec;
wire ula_zero_flag;
wire ula_carry_flag;

wire io_immed;


// ------------------------
//       INSTÂNCIAS
// ------------------------
    datapath #(.N(N)) datapath (
        .clk(clk),
        .rst(rst),
        .ula_op(Ula_op),
        .rd_sel(RD_sel),
        .rm_sel(RM_sel),
        .rn_sel(RN_sel),
        .rf_sel(RF_sel),
        .rd_wr(Rd_wr),
        .immed(immed),
        .ram_dout(RAM_dout),
        .ram_din(RAM_din),
        .zero_flag(ula_zero_flag),
        .carry_flag(ula_carry_flag),
        .io_data_in(io_data_in),
        .io_data_out(io_data_out),
        .io_rd(io_rd),
        .io_wr(io_wr),
        .io_immed(io_immed)
    );
    
    control_unit #(.N(N)) control_unit(
        .clk(clk),
        .reset(rst),
        .ROM_en(ROM_en),
        .ROM_addr(ROM_addr),
        .IR_data(ROM_dout),
        .Immed(immed),
        .RAM_sel(RAM_sel),
        .RAM_we(RAM_we),
        .RF_sel(RF_sel),
        .Rd_sel(RD_sel),
        .Rd_wr(Rd_wr),
        .Rm_sel(RM_sel),
        .Rn_sel(RN_sel),
        .Ula_Op(Ula_op),
        .dbg_ir(dbg_ir),
        .dbg_state(dbg_state),
        .SP_out(SP_out),
        .SP_inc(SP_inc),
        .SP_dec(SP_dec),
        .ula_zero_flag(ula_zero_flag),
        .ula_carry_flag(ula_carry_flag),
        .io_rd(io_rd),
        .io_wr(io_wr),
        .io_immed(io_immed)
     );
     
     RAM ram (
        .clk(~clk),
        .we(RAM_we),
        .din(RAM_din),
        .dout(RAM_dout),
        .addr(RAM_addr)
     );
     
     ROM rom (
        .addr(ROM_addr),
        .en(ROM_en),
        .clk(~clk),
        .dout(ROM_dout)
     );
     
    assign RAM_addr = RAM_sel ? (SP_inc ? (SP_out + 2) : SP_out) : immed;

endmodule
