`timescale 1ns / 1ps

module control_unit #(parameter N = 16) (
    input clk,
    input reset,
    input  [N-1:0] IR_data,
    input ula_zero_flag,
    input ula_carry_flag,
    output ROM_en,
    output [N-1:0] ROM_addr,
    output [N-1:0] Immed,
    output RAM_sel,
    output RAM_we,
    output [1:0] RF_sel,
    output [2:0] Rd_sel,
    output Rd_wr,
    output [2:0] Rm_sel,
    output [2:0] Rn_sel,
    output [3:0] Ula_Op,
    output [N-1:0] dbg_ir,
    output [3:0] dbg_state,
    output [N-1:0] SP_out,
    output SP_dec, SP_inc,
    output io_rd,
    output io_wr,
    output io_immed
);

    wire s_pc_clr;
    wire [N-1:0] s_pc_din;
    wire [N-1:0] s_pc_dout;
    wire s_branch_en;
    wire s_pc_inc;
    wire s_ir_ld;
    wire [N-1:0] s_ir_dout;
    wire s_flag_wr;
    
    reg  [N-1:0] SP;
    reg z_flag, c_flag;
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            SP <= 16'h00FE;      
        else if (SP_dec)
            SP <= SP - 2;        
        else if (SP_inc)
            SP <= SP + 2;
    end
    
    always @(posedge clk or posedge reset) begin
        if(reset)
            {z_flag, c_flag} <= 2'b00;
        else if(s_flag_wr)
            {z_flag, c_flag} <= {ula_zero_flag, ula_carry_flag};
    end

    FSM #(.N(N)) controlador (
        .clk(clk),
        .rst(reset),
        .PC_clr(s_pc_clr),
        .PC_inc(s_pc_inc),
        .ROM_en(ROM_en),
        .IR_load(s_ir_ld),
        .IR_data(s_ir_dout),
        .Immed(Immed),
        .RAM_sel(RAM_sel),
        .RAM_we(RAM_we),
        .RF_sel(RF_sel),
        .Rd_sel(Rd_sel),
        .Rd_wr(Rd_wr),
        .Rm_sel(Rm_sel),
        .Rn_sel(Rn_sel),
        .ula_op(Ula_Op),
        .SP_inc(SP_inc),
        .SP_dec(SP_dec),
        .s_branch_en(s_branch_en),
        .z_flag(z_flag),
        .c_flag(c_flag),
        .flag_wr(s_flag_wr),
        .io_rd(io_rd),
        .io_wr(io_wr),
        .io_immed(io_immed)
    );

    IR #(.N(N)) ir_inst (
        .i_Clk(clk),
        .i_Rst(reset),
        .i_ld(s_ir_ld),
        .i_d(IR_data),
        .q(s_ir_dout)
    );

    Pc #(.N(N)) pc_inst (
        .i_Clk(clk),
        .i_Rst(s_pc_clr),
        .i_ld(s_pc_inc),
        .i_d(s_pc_din),
        .q(s_pc_dout)
    );
  
    assign s_pc_din = (s_branch_en) ? (s_pc_dout + Immed) : s_pc_dout + 2;
    assign ROM_addr = s_pc_dout;
    assign dbg_ir = s_ir_dout;
    assign dbg_state = controlador.ps;
    assign SP_out = SP;

endmodule