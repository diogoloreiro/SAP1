// =============================================================
// tb_sap1.v  -  Testbench self-checking do SAP-1
//
// Executa o programa carregado na RAM:
//   LDA 13 ; ADD 14 ; SUB 15 ; OUT ; HLT
//   mem[13]=16, mem[14]=14, mem[15]=4
//   Resultado esperado no visor: 16 + 14 - 4 = 26 = 0x1A = 8'b0001_1010
//
// O testbench:
//   - gera o clock
//   - aplica o reset (liberando-o com o clock em nivel baixo)
//   - monitora estados, barramento e registradores
//   - verifica o valor final da saida (PASS/FAIL)
//   - gera arquivo de ondas (tb_sap1.vcd) para ModelSim/GTKWave
// =============================================================
`timescale 1ns/1ps
module tb_sap1;

    reg        clk;
    reg        clr_bar;
    wire [7:0] out_port;
    wire       hlt;

    // valor esperado na saida
    localparam [7:0] ESPERADO = 8'd26;

    // -------- DUT --------
    sap1_top dut (
        .clk     (clk),
        .clr_bar (clr_bar),
        .out_port(out_port),
        .hlt     (hlt)
    );

    // -------- clock: periodo de 20 ns (50 MHz) --------
    initial clk = 1'b0;
    always #10 clk = ~clk;

    // -------- decodificacao do estado one-hot para exibicao --------
    function [7:0] t_state;
        input [5:0] r;
        begin
            case (r)
                6'b000001: t_state = "1";
                6'b000010: t_state = "2";
                6'b000100: t_state = "3";
                6'b001000: t_state = "4";
                6'b010000: t_state = "5";
                6'b100000: t_state = "6";
                default:   t_state = "?";
            endcase
        end
    endfunction

    // -------- monitor: imprime a cada borda de subida --------
    always @(posedge clk) begin
        if (clr_bar) begin
            $display("t=%0t | T%0s | PC=%h MAR=%h | IR=%h_%h | BUS=%h | A=%h B=%h ALU=%h | OUT=%h | CON=%b%s",
                $time,
                t_state(dut.ring),
                dut.pc_out, dut.mar_addr,
                dut.ir_opcode, dut.ir_operand,
                dut.w_bus,
                dut.acc_out, dut.b_out, dut.alu_out,
                out_port,
                dut.con,
                hlt ? " [HLT]" : "");
        end
    end

    // -------- estimulo --------
    initial begin
        $dumpfile("tb_sap1.vcd");
        $dumpvars(0, tb_sap1);

        // reset assincrono; liberado com o clock em nivel baixo,
        // garantindo que a 1a borda apos o reset seja de SUBIDA (acao de T1)
        clr_bar = 1'b0;
        #25;                 // segura o reset por ~1 ciclo
        @(negedge clk);      // alinha a liberacao com o clock baixo
        clr_bar = 1'b1;
        $display("==== reset liberado, iniciando execucao ====");

        // aguarda o HLT (com timeout de seguranca)
        fork : espera
            begin
                wait (hlt == 1'b1);
                // deixa alguns ciclos para estabilizar
                repeat (4) @(posedge clk);
                disable espera;
            end
            begin
                #5000;   // timeout
                $display("ERRO: timeout - o processador nao parou (HLT nao chegou).");
                disable espera;
            end
        join

        // -------- verificacao --------
        $display("==== execucao encerrada ====");
        $display("Saida obtida  = %0d (0x%h = %b)", out_port, out_port, out_port);
        $display("Saida esperada= %0d (0x%h = %b)", ESPERADO, ESPERADO, ESPERADO);

        if (out_port === ESPERADO)
            $display(">>> RESULTADO: PASS  (16 + 14 - 4 = 26) <<<");
        else
            $display(">>> RESULTADO: FAIL <<<");

        #20 $finish;
    end

endmodule
