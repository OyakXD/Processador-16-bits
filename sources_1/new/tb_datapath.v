`timescale 1ns / 1ps

module datapath_tb;

    // Parâmetros
    parameter N = 16;

    // Sinais de entrada (Regs no TB)
    reg clk;
    reg rst;
    reg [3:0] ula_op;
    reg [2:0] rd_sel, rm_sel, rn_sel;
    reg [1:0] rf_sel;
    reg rd_wr;
    reg [N-1:0] immed;
    reg [N-1:0] ram_dout;

    // Sinais de saída (Wires no TB)
    wire [N-1:0] ram_din;
    wire [N-1:0] ram_addr;

    // Instância da Unidade Sob Teste (UUT)
    datapath #(.N(N)) uut (
        .clk(clk),
        .rst(rst),
        .ula_op(ula_op),
        .rd_sel(rd_sel),
        .rm_sel(rm_sel),
        .rn_sel(rn_sel),
        .rf_sel(rf_sel),
        .rd_wr(rd_wr),
        .immed(immed),
        .ram_dout(ram_dout),
        .ram_din(ram_din),
        .ram_addr(ram_addr)
    );

    // Geração do Clock (período de 10ns)
    always #5 clk = ~clk;

    initial begin
        // --- Inicialização ---
        clk = 0;
        rst = 1;
        ula_op = 0;
        rd_sel = 0;
        rm_sel = 0;
        rn_sel = 0;
        rf_sel = 0;
        rd_wr = 0;
        immed = 0;
        ram_dout = 0;

        #20 rst = 0; // Solta o reset
        #10;

        // --- TESTE 1: MOV R1, #42 --
        rd_sel = 3'd1;     
        immed = 16'd42;    
        rf_sel = 2'b10;    
        rd_wr = 1; 
        #10;        
        
        rd_wr = 0;
        #5 rst = 1;
        #5 rst = 0;

        // --- TESTE 2: LDR R2, [R1] ---
        // Aqui o Rm_sel deve ser R1 para que ram_addr receba o valor de R1
        rm_sel = 3'd1;     
        ram_dout = 16'hAAAA;
        rd_sel = 3'd2;     
        rf_sel = 2'b01;    
        rd_wr = 1;

        rd_wr = 0;
        
        #5 rst = 1;
        #5 rst = 0;
        

        // --- TESTE 3: ADD R3, R1, R2 ---
        rm_sel = 3'd1;     
        rn_sel = 3'd2;     
        ula_op = 4'b0100;  
        rf_sel = 2'b11;    
        rd_sel = 3'd3;     
        rd_wr = 1;

        rd_wr = 0;

        #50;
        $finish;
    end

endmodule