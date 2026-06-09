`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 09:25:18 PM
// Design Name: 
// Module Name: tb_fsm
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


module tb_fsm;

    parameter N = 16;

    reg i_clk,i_rst;
    reg [N-1:0] i_IR_data;
    
    wire o_ROM_en;
    wire o_PC_clr;
    wire o_PC_inc;
    wire o_IR_load;
    wire [N-1:0] o_Immed;
    wire o_RAM_sel;
    wire o_RAM_we;
    wire [1:0] o_RF_sel;
    wire [2:0] o_Rd_sel;
    wire o_Rd_wr;
    wire [2:0] o_Rm_sel;
    wire [2:0] o_Rn_sel;
    wire [3:0] o_ula_op;
    wire [N-1:0] w_rm, w_rn;
    
    wire [N-1:0] w_mux_to_reg;
    assign w_mux_to_reg = (o_RF_sel[1]) ? o_Immed : w_rm;
    
    reg [N-1:0] o_ula_result;
    
    FSM  #(.N(N)) fsm_unit (
        .clk(i_clk),
        .rst(i_rst),
        .IR_data(i_IR_data),
        .ROM_en(o_ROM_en),      
        .PC_clr(o_PC_clr),      
        .PC_inc(o_PC_inc),      
        .IR_load(o_IR_load),     
        .Immed(o_Immed),
        .RAM_sel(o_RAM_sel),     
        .RAM_we(o_RAM_we),      
        .RF_sel(o_RF_sel),
        .Rd_sel(o_Rd_sel),
        .Rd_wr(o_Rd_wr),       
        .Rm_sel(o_Rm_sel),
        .Rn_sel(o_Rn_sel),
        .ula_op(o_ula_op) 
      );
      
      register_file #(.N(N)) reg_files (
        .clk(i_clk),                  
        .rst(i_rst),                  
        .rd_wr(o_Rd_wr),            
        .rd_sel(o_Rd_sel),         
        .rm_sel(o_Rm_sel), 
        .rn_sel(o_Rn_sel), 
        .rd_data(w_mux_to_reg),      
        .rm(w_rm), 
        .rn(w_rn)       
      );
      
      
      ula ula_inst (
        .A(o_Rm_sel),
        .B(o_Rn_sel),
        .op(o_ula_op),
        .Q(o_ula_result)
      );
      
    
    
    // SELF CHECKING
    task check_internal_reg(input [2:0] reg_idx, input [N-1:0] exp_val, input [8*20:1] msg);
    begin
        #1;
        if (reg_files.registers[reg_idx] !== exp_val) begin 
            $display("ERRO [%0s]: R%0d = %h | Esperado = %h", msg, reg_idx, reg_files.registers[reg_idx], exp_val);
        end else begin
            $display("PASS [%0s]: R%0d conferido com %h", msg, reg_idx, exp_val);
        end
    end
endtask
        
          
    always #5 i_clk = ~i_clk;
 
   
    initial begin  
        i_clk = 0;
        i_IR_data = 16'h00;
        i_rst = 1;
        #22 i_rst = 0;
        
        // MOV R2, #4
        i_IR_data = 16'b00011_010_00000100;
        
        #50;
       
        // MOV R3, R2
        i_IR_data = 16'b00010_011_01000000;
        
        #50;
        
        // ADD R4, R3, R2
        i_IR_data = 16'b0100010001101000;
        
        #50;
        
        check_internal_reg(3'b010, 16'h0004, "TESTE MOV IMMEDIATO 1");
        check_internal_reg(3'b011, 16'h0004, "TESTE MOV REGISTRADOR");
        check_internal_reg(3'b100, 16'h0008, "TESTE ADD ULA");
        
        
        $finish;                                                                                                                                                                     
        end     
        
        
endmodule
