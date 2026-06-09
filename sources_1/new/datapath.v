`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2026 07:17:28 PM
// Design Name: 
// Module Name: datapath
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


module datapath #(parameter N=16)(

    input clk, rst,
    
    // SINAIS DE CONTROLE FSM
    input [3:0] ula_op,
    input [2:0] rd_sel, rm_sel, rn_sel,
    input [1:0] rf_sel,
    input rd_wr,
    input [N-1:0] immed,
    input [7:0] io_data_in,
    input io_rd,
    input io_wr,
    input io_immed,
    
    // INTERFACE COM RAM E SISTEMA
    input [N-1:0] ram_dout,
    output [N-1:0] ram_din,
    output zero_flag, carry_flag,
    output [7:0] io_data_out
);    

    // FIOS DE INTERCONEXÃO
    wire [N-1:0] Rm_dout;
    wire [N-1:0] Rn_dout;
    wire [N-1:0] s_ula_Q_to_RF_source;
    wire [N-1:0] s_mux_to_rf_data;
    wire [N-1:0] Immed;
    wire [N-1:0] io_or_immed;
    
  

    register_file reg_INST (
        .clk(clk),
        .rst(rst),
        .rd_wr(rd_wr),
        .rd_sel(rd_sel),
        .rm_sel(rm_sel),
        .rn_sel(rn_sel),
        .rd_data(s_mux_to_rf_data),
        .rm(Rm_dout),
        .rn(Rn_dout)
    );

    ula ula_INST (
        .A(Rm_dout),
        .B(Rn_dout),
        .op(ula_op),
        .immed(immed),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .Q(s_ula_Q_to_RF_source)
    );

    mux_4_1 mux_INST (
        .I0(Rm_dout),
        .I1(ram_dout),
        .I2(io_or_immed),
        .I3(s_ula_Q_to_RF_source),
        .sel(rf_sel),
        .O0(s_mux_to_rf_data)
    );
    
    assign ram_din = Rn_dout;
    assign io_or_immed = io_rd ? {8'b0, io_data_in}
                               : immed;
                               
    assign io_data_out = io_immed ?
                         immed[7:0] :
                         Rm_dout[7:0];
   

endmodule
