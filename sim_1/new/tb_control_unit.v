`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2026 08:33:01 PM
// Design Name: 
// Module Name: tb_control_unit
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


module tb_control_unit;

     parameter N = 16;
     reg clk;
     reg rst;
     reg [N-1:0] IR_data;
     
     wire ROM_en;
     wire [N-1:0] ROM_addr;
     wire [N-1:0] instruction_bus;
   
     wire [N-1:0] Immed;
     wire RAM_sel;
     wire RAM_we;
     wire [1:0] RF_sel;
     wire [2:0] Rd_sel;
     wire Rd_wr;
     wire [2:0] Rm_sel;
     wire [2:0] Rn_sel;
     wire [3:0] Ula_Op;
     wire [N-1:0] dbg_ir;
     wire [3:0] dbg_state;

     wire [N-1:0] Rm_dout;
     wire [N-1:0] Rn_dout;
     wire [N-1:0] write_data;
     wire [N-1:0] s_out_ula;
     
     assign write_data =
        (RF_sel == 2'b00) ? Rm_dout :
        (RF_sel == 2'b11) ? s_out_ula :
        (RF_sel == 2'b01) ? 16'h0000 :
        (RF_sel == 2'b10) ? Immed :
        16'h0000;
    
     ROM ROM_unit(
        .addr(ROM_addr),
        .en(ROM_en),
        .clk(clk),
        .dout(instruction_bus)
     );
     
     control_unit #(.N(N)) Control_unit(
        .clk(clk),
        .reset(rst),
        .ROM_en(ROM_en),
        .ROM_addr(ROM_addr),
        .IR_data(instruction_bus),
        .Immed(Immed),
        .RAM_sel(RAM_sel),
        .RAM_we(RAM_we),
        .RF_sel(RF_sel),
        .Rd_sel(Rd_sel),
        .Rd_wr(Rd_wr),
        .Rm_sel(Rm_sel),
        .Rn_sel(Rn_sel),
        .Ula_Op(Ula_Op),
        .dbg_ir(dbg_ir),
        .dbg_state(dbg_state)
     );
     
     register_file reg_file(
        .clk(clk),
        .rst(rst),
        .rd_wr(Rd_wr),                
        .rd_sel(Rd_sel),         
        .rm_sel(Rm_sel),
        .rn_sel(Rn_sel), 
        .rd_data(write_data),      
        .rm(Rm_dout),
        .rn(Rn_dout) 
     );
     
     ula ula_inst(
     .A(Rm_dout),
     .B(Rn_dout),
     .op(Ula_Op),
     .Q(s_out_ula)
     );
      
     always #5 clk = ~clk;
     
     initial begin
        clk = 0;      
        rst = 1;
        
        #20 rst = 0;
        
        #200;
        
        $finish;                    
     end
     
    
    
endmodule
