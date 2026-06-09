`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2026 03:53:33 PM
// Design Name: 
// Module Name: tb_processor16bit
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


module tb_processor16bit;

    parameter N = 16;

    reg clk;
    reg rst;
    reg [7:0] io_data_in;
    wire [7:0] io_data_out;
    wire io_wr;
    wire io_rd;

    processor16Bit #(.N(N)) uut (
        .clk(clk),
        .rst(rst),
        .io_data_in(io_data_in),
        .io_data_out(io_data_out),
        .io_wr(io_wr),
        .io_rd(io_rd)
    );
    
    wire [N-1:0] PC     = uut.ROM_addr;
    wire [N-1:0] IR     = uut.dbg_ir;
    wire [N-1:0] SP     = uut.SP_out;
    wire s_branch_en    = uut.control_unit.s_branch_en;
    
    wire flag_zero     = uut.datapath.zero_flag;
    wire flag_carry    = uut.datapath.carry_flag;
    
    wire [N-1:0] R1    = uut.datapath.reg_INST.registers[1];
    wire [N-1:0] R2    = uut.datapath.reg_INST.registers[2];
    wire [N-1:0] R3    = uut.datapath.reg_INST.registers[3];
    wire [N-1:0] R4    = uut.datapath.reg_INST.registers[4];
    wire [N-1:0] R5    = uut.datapath.reg_INST.registers[5];
    

    always begin
        #5 clk = ~clk;
    end
    
    always @(posedge clk) begin
            $display(
        "RAM_addr=%h RAM_dout=%h R1=%h R2=%h R3=%h",
        uut.RAM_addr,
        uut.RAM_dout,
        R1,R2,R3
            );
    end
    
    

    initial begin
        clk = 0;
        rst = 1;
        
        // Periferico
        io_data_in = 8'h55;
        
        #20;
        
        rst = 0;
        
        $display("RAM[F9]=%h", uut.ram.RAM_data['hF9]);
        $display("RAM[FA]=%h", uut.ram.RAM_data['hFA]);

        $display("RAM[FB]=%h", uut.ram.RAM_data['hFB]);
        $display("RAM[FC]=%h", uut.ram.RAM_data['hFC]);

        $display("RAM[FD]=%h", uut.ram.RAM_data['hFD]);
        $display("RAM[FE]=%h", uut.ram.RAM_data['hFE]);
        
        #1000;

        $finish;
    end

endmodule
