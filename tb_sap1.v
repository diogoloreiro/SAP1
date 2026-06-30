// =============================================================
// tb_sap1.v  -  Testbench do nucleo SAP-1 (sap1_top)
//
// Simula o processador rodando o programa carregado em
// ram_16x8.v (calculo de 3^3 = 27). NAO usa o divisor de clock
// (sap1_fpga) para a simulacao ser rapida: aplica clock direto.
//
// O testbench:
//   - gera clock e reset
//   - mostra, a cada borda de subida, o estado T, o barramento W,
//     o acumulador (via hierarquia) e a saida
//   - captura cada novo valor escrito no registrador de saida (OUT)
//   - PARA quando hlt=1 (ou por timeout) e faz a AUTOVERIFICACAO:
//        saida final esperada = 27 (0x1B)
//
// Como rodar no ModelSim:   do run_sim.do      (script ao lado)
// Ou manualmente:           vsim -voptargs=+acc work.tb_sap1 ; run -all
// =============================================================
`timescale 1ns / 1ps

module tb_sap1;

    // ---- estimulos ----
    reg clk;
    reg clr_bar;

    // ---- saidas do DUT ----
    wire [7:0] out_port;
    wire       hlt;
    wire [7:0] bus_w;
    wire [5:0] tstate;

    // ---- resultado esperado: AJUSTE conforme o programa na RAM ----
    //   programa1 (3^3)       -> 27
    //   programa2 (expressao) -> 18
    //   programa3 (3 x 4)     -> 12   <-- carregado atualmente
    //   programa4 (12 / 4)    -> 3
    localparam [7:0] RESULTADO_ESPERADO = 8'd12;

    // -------------------------------------------------------
    // DUT  (Device Under Test) = nucleo do SAP-1
    // -------------------------------------------------------
    sap1_top dut (
        .clk      (clk),
        .clr_bar  (clr_bar),
        .out_port (out_port),
        .hlt      (hlt),
        .bus_w    (bus_w),
        .tstate   (tstate)
    );

    // -------------------------------------------------------
    // Clock: periodo de 20 ns (50 MHz). Comeca em 0.
    // -------------------------------------------------------
    initial clk = 1'b0;
    always #10 clk = ~clk;

    // -------------------------------------------------------
    // Reset: mantem ~CLR=0 por alguns ciclos e solta.
    // -------------------------------------------------------
    initial begin
        clr_bar = 1'b0;
        repeat (4) @(negedge clk);   // segura o reset
        clr_bar = 1'b1;              // libera (estado IDLE absorve a fase)
        $display("[%0t] reset liberado", $time);
    end

    // -------------------------------------------------------
    // Nome legivel do estado T (one-hot) -> string
    // -------------------------------------------------------
    function [23:0] tname(input [5:0] t);
        case (t)
            6'b000001: tname = "T1 ";
            6'b000010: tname = "T2 ";
            6'b000100: tname = "T3 ";
            6'b001000: tname = "T4 ";
            6'b010000: tname = "T5 ";
            6'b100000: tname = "T6 ";
            default:   tname = "IDL";
        endcase
    endfunction

    // -------------------------------------------------------
    // Log por ciclo: na borda de SUBIDA o datapath ja reagiu.
    // Usa a hierarquia para espiar registradores internos.
    // -------------------------------------------------------
    always @(posedge clk) begin
        if (clr_bar)
            $display("[%6t] %s | PC=%0d MAR=%0d | A=%0d B=%0d | busW=%02h | OUT=%0d (0x%02h)%s",
                     $time, tname(tstate),
                     dut.u_pc.pc_out, dut.u_mar.addr_out,
                     dut.u_acc.acc_out, dut.u_b.b_out,
                     bus_w, out_port, out_port,
                     hlt ? "  <HLT>" : "");
    end

    // -------------------------------------------------------
    // Captura cada novo valor mostrado pela instrucao OUT
    // -------------------------------------------------------
    reg [7:0] out_prev;
    initial out_prev = 8'hxx;
    always @(posedge clk) begin
        if (clr_bar && (out_port !== out_prev)) begin
            $display(">>> OUT atualizado: %0d (0x%02h)", out_port, out_port);
            out_prev = out_port;
        end
    end

    // -------------------------------------------------------
    // Controle da simulacao: espera HLT (com timeout) e verifica
    // -------------------------------------------------------
    integer ciclos;
    initial begin
        // espera o reset ser liberado
        @(posedge clr_bar);

        // roda ate hlt, com limite de seguranca
        ciclos = 0;
        while (!hlt && ciclos < 2000) begin
            @(posedge clk);
            ciclos = ciclos + 1;
        end

        // deixa alguns ciclos extras para estabilizar
        repeat (2) @(posedge clk);

        $display("\n==================== RESULTADO ====================");
        if (!hlt) begin
            $display("FALHOU: processador nao parou (HLT) em %0d ciclos.", ciclos);
        end else if (out_port === RESULTADO_ESPERADO) begin
            $display("PASSOU: saida = %0d (0x%02h) == esperado %0d. HLT em %0d ciclos.",
                     out_port, out_port, RESULTADO_ESPERADO, ciclos);
        end else begin
            $display("FALHOU: saida = %0d (0x%02h), esperado %0d (0x%02h).",
                     out_port, out_port, RESULTADO_ESPERADO, RESULTADO_ESPERADO);
        end
        $display("==================================================\n");
        $finish;
    end

    // -------------------------------------------------------
    // Dump de ondas (VCD) - opcional, alem do .wlf do ModelSim
    // -------------------------------------------------------
    initial begin
        $dumpfile("sap1.vcd");
        $dumpvars(0, tb_sap1);
    end

endmodule
