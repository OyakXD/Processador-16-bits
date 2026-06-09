`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2026 03:18:23 PM
// Design Name: 
// Module Name: tb_cpu
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


module tb_cpu;

    reg clk, rst;

    processor16Bit #(.N(16)) dut (
        .clk(clk),
        .rst(rst)
    );

    // ── Acesso interno (white-box) ──────────────
    wire [15:0] RF [0:7];
    genvar gi;
    generate
        for (gi = 0; gi < 8; gi = gi + 1) begin : rf_tap
            assign RF[gi] = dut.datapath.reg_INST.registers[gi];
        end
    endgenerate

    // Forçando/Visualizando fios internos de controle
    wire [15:0] SP    = dut.control_unit.SP;
    wire [3:0]  STATE = dut.control_unit.dbg_state;
    wire [15:0] IR    = dut.control_unit.dbg_ir;

    // ── Contadores ──────────────────────────────
    integer pass_count = 0;
    integer fail_count = 0;

    // ── Clock 10 ns ─────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Tarefas ─────────────────────────────────
    task check;
        input [255:0] name;
        input [15:0]  got;
        input [15:0]  expected;
        begin
            if (got === expected) begin
                $display("  [PASS] %-32s  got=0x%04X", name, got);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] %-32s  got=0x%04X  expected=0x%04X",
                          name, got, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task wait_state;
        input [3:0] target;
        integer timeout;
        begin
            timeout = 0;
            while (STATE !== target && timeout < 300) begin
                @(posedge clk); #1;
                timeout = timeout + 1;
            end
            if (timeout >= 300)
                $display("  [TIMEOUT] Esperando estado %0d", target);
        end
    endtask

    // ── Sequência principal ──────────────────────
    initial begin
        $display("========================================");
        $display("  TESTBENCH - Processor16Bit (Mapeado para RAM de 256 posições) ");
        $display("========================================");

        // Sistema em Reset
        rst = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;
        
        // CORREÇÃO CRÍTICA: Força o SP a iniciar dentro do limite físico real da sua RAM (256 posições)
        // Iniciando em 0x00FD (253) para dar espaço para os bytes da escrita síncrona [addr+1]
        force dut.control_unit.SP = 16'h00FD; 
        @(posedge clk); #1;   // Aguarda FSM alinhar
        release dut.control_unit.SP; // Libera o controle para o hardware assumir o incremento/decremento

        // ── T1: Reset ────────────────────────────
        $display("\n── Teste 1: Reset & Inicializacao ──────");
        check("SP inicializado na RAM real", SP,     16'h00FD);
        check("R0 apos reset",      RF[0],  16'h0000);
        check("R1 apos reset",      RF[1],  16'h0000);
        check("R2 apos reset",      RF[2],  16'h0000);
        check("R3 apos reset",      RF[3],  16'h0000);

        // ── T2: MOV R1, #7 ───────────────────────
        $display("\n── Teste 2: MOV R1, #7 (IR=0x1907) ────");
        wait_state(4'd5);      // exec_mov
        @(posedge clk); #1;   // escreve no RF
        check("R1 = 7",            RF[1],  16'h0007);

        // ── T3: MOV R2, #5 ───────────────────────
        $display("\n── Teste 3: MOV R2, #5 (IR=0x1A05) ────");
        wait_state(4'd5);
        @(posedge clk); #1;
        check("R2 = 5",            RF[2],  16'h0005);
        check("R1 inalterado",     RF[1],  16'h0007);

        // ── T4: ADD R3 = R1 + R2 ─────────────────
        $display("\n── Teste 4: ADD R3 = R1 + R2 ──────────");
        wait_state(4'd8);      // exec_ula
        @(posedge clk); #1;
        check("R3 = 12 (0x000C)", RF[3],  16'h000C);
        check("R1 inalterado",    RF[1],  16'h0007);
        check("R2 inalterado",    RF[2],  16'h0005);

        // ── T5: OUT R0 (→ exec_nop) ──────────────
        $display("\n── Teste 5: OUT R0 (→ exec_nop) ───────");
        wait_state(4'd3);      // exec_nop
        #1;
        check("R3 inalterado",    RF[3],  16'h000C);
        check("SP inalterado",    SP,     16'h00FD);

        // ── T6: PUSH R1 (SP: 00FD→00FC) ──────────
        $display("\n── Teste 6: PUSH R1 ────────────────────");
        wait_state(4'd9);      // exec_push
        @(posedge clk); #1;
        check("SP apos PUSH R1",  SP,     16'h00FC);

        // ── T7: PUSH R2 (SP: 00FC→00FB) ──────────
        $display("\n── Teste 7: PUSH R2 ────────────────────");
        wait_state(4'd9);
        @(posedge clk); #1;
        check("SP apos PUSH R2",  SP,     16'h00FB);

        // ── T8: PUSH R3 (SP: 00FB→00FA) ──────────
        $display("\n── Teste 8: PUSH R3 ────────────────────");
        wait_state(4'd9);
        @(posedge clk); #1;
        check("SP apos PUSH R3",  SP,     16'h00FA);

        // ── T9: IN R4 (→ exec_nop) ───────────────
        $display("\n── Teste 9: IN R4 (→ exec_nop) ────────");
        wait_state(4'd3);
        #1;
        check("R4 inalterado",    RF[4],  16'h0000);
        check("SP inalterado",    SP,     16'h00FA);

        // ── T10: CMP R1, R2 ──────────────────────
        $display("\n── Teste 10: CMP R1, R2 ────────────────");
        wait_state(4'd8);      // exec_ula
        @(posedge clk); #1;
        check("RF nao alterado",  RF[1],  16'h0007);
        check("Volta a fetch",    STATE,  4'd1);

        // ── T11: POP R1 (SP: 00FA→00FB) ──────────
        $display("\n── Teste 11: POP R1 ────────────────────");
        wait_state(4'd10);     // exec_pop
        @(posedge clk); #1;
        check("SP apos POP R1",   SP,     16'h00FB);

        // ── T12: POP R2 (SP: 00FB→00FC) ──────────
        $display("\n── Teste 12: POP R2 ────────────────────");
        wait_state(4'd10);
        @(posedge clk); #1;
        check("SP apos POP R2",   SP,     16'h00FC);

        // ── T13: POP R3 (SP: 00FC→00FD) ──────────
        $display("\n── Teste 13: POP R3 ────────────────────");
        wait_state(4'd10);
        @(posedge clk); #1;
        check("SP apos POP R3",   SP,     16'h00FD);
        check("SP voltou ao inicio real", SP, 16'h00FD);

        // ── T14: NOP (ROM=0x0000) ─────────────────
        $display("\n── Teste 14: NOP (ROM zerada) ──────────");
        wait_state(4'd3);      // exec_nop
        #1;
        check("R1 inalterado",    RF[1],  16'h0007);
        check("R2 inalterado",    RF[2],  16'h0005);
        check("R3 inalterado",    RF[3],  16'h000C);
        check("SP inalterado",    SP,     16'h00FD);

        // ── Relatório Final ─────────────────────────
        $display("\n========================================");
        $display("  RESULTADO FINAL");
        $display("  PASS : %0d", pass_count);
        $display("  FAIL : %0d", fail_count);
        if (fail_count == 0)
            $display("  STATUS: ** TODOS OS TESTES PASSARAM **");
        else
            $display("  STATUS: ** %0d TESTE(S) FALHARAM **", fail_count);
        $display("========================================");
        $finish;
    end

    // ── Monitor de estados explicativo ───────────
    reg [3:0] prev_state = 4'hF;
    always @(posedge clk) begin
        #1;
        if (STATE !== prev_state) begin
            case (STATE)
                4'd0:  $display("[t=%0t]  ESTADO: init",        $time);
                4'd1:  $display("[t=%0t]  ESTADO: fetch",       $time);
                4'd2:  $display("[t=%0t]  ESTADO: decode  IR=0x%04X", $time, IR);
                4'd3:  $display("[t=%0t]  ESTADO: exec_nop",    $time);
                4'd4:  $display("[t=%0t]  ESTADO: exec_halt",   $time);
                4'd5:  $display("[t=%0t]  ESTADO: exec_mov",    $time);
                4'd6:  $display("[t=%0t]  ESTADO: exec_load",   $time);
                4'd7:  $display("[t=%0t]  ESTADO: exec_store",  $time);
                4'd8:  $display("[t=%0t]  ESTADO: exec_ula",    $time);
                4'd9:  $display("[t=%0t]  ESTADO: exec_push  SP=0x%04X", $time, SP);
                4'd10: $display("[t=%0t]  ESTADO: exec_pop   SP=0x%04X", $time, SP);
                4'd11: $display("[t=%0t]  ESTADO: exec_branch", $time);
                default:$display("[t=%0t]  ESTADO: ???(%0d)",   $time, STATE);
            endcase
            prev_state = STATE;
        end
    end

    // Watchdog
    initial begin
        #200000;
        $display("[WATCHDOG] Abortando simulacao por estagnar.");
        $finish;
    end
endmodule
