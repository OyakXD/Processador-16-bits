`timescale 1ns / 1ps

module tb_processor16Bit;

    // Sinais do Testbench
    reg clk;
    reg rst;
    
    // Contadores para o relatório final
    integer testes_passaram = 0;
    integer testes_falharam = 0;

    // Instanciação do Processador Top-Level
    processor16Bit #(.N(16)) uut (
        .clk(clk),
        .rst(rst)
    );

    // Atalhos hierárquicos para monitoramento interno (facilitam os testes)
    wire [3:0]  STATE    = uut.dbg_state;
    wire [15:0] IR       = uut.dbg_ir;
    wire [15:0] SP       = uut.SP_out;
    
    // Acesso direto aos registradores do Banco de Registradores para validação
    wire [15:0] R0 = uut.datapath.reg_INST.registers[0];
    wire [15:0] R1 = uut.datapath.reg_INST.registers[1];
    wire [15:0] R2 = uut.datapath.reg_INST.registers[2];
    wire [15:0] R3 = uut.datapath.reg_INST.registers[3];
    wire [15:0] R4 = uut.datapath.reg_INST.registers[4];

    // Geração do Clock (Período de 10ns -> 100MHz)
    always #5 clk = ~clk;

    // Tarefa auxiliar para exibir mensagens de erro/sucesso de forma limpa
    task check(input [127:0] nome_teste, input [15:0] obtido, input [15:0] esperado);
        begin
            if (obtido === esperado) begin
                $display("  [PASS] %30s  got=0x%04x", nome_teste, obtido);
                testes_passaram = testes_passaram + 1;
            end else begin
                $display("  [FAIL] %30s  got=0x%04x  expected=0x%04x", nome_teste, obtido, esperado);
                testes_falharam = testes_falharam + 1;
            end
        end
    endtask

    // Tarefa para esperar a FSM atingir um estado específico
    task wait_state(input [3:0] target_state);
        begin
            while (STATE !== target_state) begin
                @(posedge clk);
            end
        end
    endtask

    // Bloco Principal de Estímulos
    initial begin
        // Inicialização de sinais
        clk = 0;
        rst = 1;
        
        $display("========================================");
        $display("  TESTBENCH - Processor16Bit (Corrigido) ");
        $display("========================================");
        
        // Pulso de Reset inicial
        #15 rst = 0;
        
        // Aguarda sair do estado 'init' e mostra o estado da máquina
        wait_state(4'd0); // init
        $display("[t=%0t]  ESTADO: init", $time);
        #1;
        
        // ── Teste 1: Reset & Inicializacao ──────
        $display("\n── Teste 1: Reset & Inicializacao ──────");
        check("SP inicializado na RAM real", SP, 16'h00fd);
        check("R0 apos reset", R0, 16'h0000);
        check("R1 apos reset", R1, 16'h0000);
        check("R2 apos reset", R2, 16'h0000);
        check("R3 apos reset", R3, 16'h0000);

        // ── Teste 2: MOV R1, #7 ─────────────────
        $display("\n── Teste 2: MOV R1, #7 (IR=0x1907) ────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd5); $display("[t=%0t]  ESTADO: exec_mov", $time);
        @(posedge clk); #1; // Aguarda a borda de escrita do registrador
        check("R1 = 7", R1, 16'h0007);

        // ── Teste 3: MOV R2, #5 ─────────────────
        $display("\n── Teste 3: MOV R2, #5 (IR=0x1A05) ────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd5); $display("[t=%0t]  ESTADO: exec_mov", $time);
        @(posedge clk); #1;
        check("R2 = 5", R2, 16'h0005);
        check("R1 inalterado", R1, 16'h0007);

        // ── Teste 4: ADD R3 = R1 + R2 ───────────
        $display("\n── Teste 4: ADD R3 = R1 + R2 ──────────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd8); $display("[t=%0t]  ESTADO: exec_ula", $time);
        @(posedge clk); #1;
        check("R3 = 12 (0x000C)", R3, 16'h000c);
        check("R1 inalterado", R1, 16'h0007);
        check("R2 inalterado", R2, 16'h0005);

        // ── Teste 5: OUT R0 (→ exec_nop) ────────
        $display("\n── Teste 5: OUT R0 (→ exec_nop) ───────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd3); $display("[t=%0t]  ESTADO: exec_nop", $time);
        @(posedge clk); #1;
        check("R3 inalterado", R3, 16'h000c);
        check("SP inalterado", SP, 16'h00fd);

        // ── Teste 6: PUSH R1 ────────────────────
        $display("\n── Teste 6: PUSH R1 ────────────────────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd9); $display("[t=%0t]  ESTADO: exec_push  SP=0x%04x", $time, SP);
        @(posedge clk); #1;
        check("SP apos PUSH R1 (-2)", SP, 16'h00fb);

        // ── Teste 7: PUSH R2 ────────────────────
        $display("\n── Teste 7: PUSH R2 ────────────────────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd9); $display("[t=%0t]  ESTADO: exec_push  SP=0x%04x", $time, SP);
        @(posedge clk); #1;
        check("SP apos PUSH R2 (-2)", SP, 16'h00f9);

        // ── Teste 8: PUSH R3 ────────────────────
        $display("\n── Teste 8: PUSH R3 ────────────────────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd9); $display("[t=%0t]  ESTADO: exec_push  SP=0x%04x", $time, SP);
        @(posedge clk); #1;
        check("SP apos PUSH R3 (-2)", SP, 16'h00f7);

        // ── Teste 9: IN R4 (→ exec_nop) ─────────
        $display("\n── Teste 9: IN R4 (→ exec_nop) ────────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd3); $display("[t=%0t]  ESTADO: exec_nop", $time);
        @(posedge clk); #1;
        check("R4 inalterado", R4, 16'h0000);
        check("SP inalterado", SP, 16'h00f7);

        // ── Teste 10: CMP R1, R2 ────────────────
        $display("\n── Teste 10: CMP R1, R2 ────────────────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd8); $display("[t=%0t]  ESTADO: exec_ula", $time);
        @(posedge clk); #1;
        check("R1 nao alterado no CMP", R1, 16'h0007);
        check("Volta a fetch", STATE, 4'd1);

        // ── Teste 11: POP R1 ────────────────────
        $display("\n── Teste 11: POP R1 ────────────────────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd10); $display("[t=%0t]  ESTADO: exec_pop   SP=0x%04x", $time, SP);
        @(posedge clk); #1;
        check("SP apos POP R1 (+2)", SP, 16'h00f9);

        // ── Teste 12: POP R2 ────────────────────
        $display("\n── Teste 12: POP R2 ────────────────────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd10); $display("[t=%0t]  ESTADO: exec_pop   SP=0x%04x", $time, SP);
        @(posedge clk); #1;
        check("SP apos POP R2 (+2)", SP, 16'h00fb);

        // ── Teste 13: POP R3 ────────────────────
        $display("\n── Teste 13: POP R3 ────────────────────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd10); $display("[t=%0t]  ESTADO: exec_pop   SP=0x%04x", $time, SP);
        @(posedge clk); #1;
        check("SP apos POP R3 (+2)", SP, 16'h00fd);
        check("SP voltou ao inicio real", SP, 16'h00fd);

        // ── Teste 14: NOP (Verificacao Final de Retencao) ──
        $display("\n── Teste 14: NOP (ROM zerada) ──────────");
        wait_state(4'd1); $display("[t=%0t]  ESTADO: fetch", $time);
        wait_state(4'd2); $display("[t=%0t]  ESTADO: decode  IR=0x%04x", $time, IR);
        wait_state(4'd3); $display("[t=%0t]  ESTADO: exec_nop", $time);
        @(posedge clk); #1;
        // VALIDAÇÃO CRÍTICA: Verifica se os dados originais foram mantidos pós-POP
        check("R1 intacto apos POP", R1, 16'h0007);
        check("R2 intacto apos POP", R2, 16'h0005);
        check("R3 intacto apos POP", R3, 16'h000c);
        check("SP inalterado no final", SP, 16'h00fd);

        // -------------------------------------
        //       RELATÓRIO FINAL DE SIMULAÇÃO
        // -------------------------------------
        $display("\n========================================");
        $display("  RESULTADO FINAL");
        $display("  PASS : %0d", testes_passaram);
        $display("  FAIL : %0d", testes_falharam);
        if (testes_falharam == 0) begin
            $display("  STATUS: ** PROJETO CONCLUÍDO COM 100%% DE SUCESSO! **");
        end else begin
            $display("  STATUS: ** %0d TESTE(S) FALHARAM **", testes_falharam);
        end
        $display("========================================");
        
        $finish;
    end

endmodule