// =============================================================
// controller_fsm.v  -  Controlador/Sequenciador do SAP-1
// (mesma logica do controller_sequencer.v, porem escrita no
//  formato CLASSICO de Maquina de Estados Finita - FSM)
//
// Esta versao e funcionalmente equivalente ao contador de anel
// do controller_sequencer.v, mas estruturada como uma FSM de
// Moore com 3 processos bem separados e estados nomeados, para
// fins didaticos:
//
//   (1) REGISTRADOR DE ESTADO   -> sequencial (negedge clk)
//   (2) LOGICA DE PROXIMO ESTADO -> combinacional
//   (3) LOGICA DE SAIDA          -> combinacional (palavra CON)
//
// Estados: IDLE -> T1 -> T2 -> T3 -> T4 -> T5 -> T6 -> T1 ...
//   - IDLE  : estado ocioso de partida (absorve a fase do reset)
//   - T1..T3: ciclo de BUSCA (igual para toda instrucao)
//   - T4..T6: ciclo de EXECUCAO (depende do opcode)
//
// Relacao de bordas (identica a versao original):
//   - estado avanca na borda de DESCIDA  (negedge clk)
//   - registradores do datapath carregam na borda de SUBIDA
//   Assim a palavra de controle de Tn ja esta estavel quando os
//   registradores reagem.
//
// HALT: flag REGISTRADO, travado em T4 quando opcode = HLT. O
// congelamento e feito por CLOCK-ENABLE (run), nao por gating de
// clock -> sintetizavel e sem glitch.
//
// Formato da palavra de controle (MSB -> LSB):
//   CON = { Cp, Ep, ~Lm, ~CE, ~Li, ~Ei, ~La, Ea, Su, Eu, ~Lb, ~Lo }
//   bit:  11  10   9    8    7    6    5   4   3   2   1    0
//
// Nivel ativo:
//   Cp,Ep,Ea,Su,Eu               -> ativos em ALTO  (1 = ativo)
//   ~Lm,~CE,~Li,~Ei,~La,~Lb,~Lo  -> ativos em BAIXO (0 = ativo)
//
// Para usar no lugar do controller_sequencer, basta trocar o nome
// do modulo instanciado em sap1_top.v (as portas sao identicas):
//   controller_sequencer u_ctrl (...);   ->  controller_fsm u_ctrl (...);
// =============================================================
module controller_fsm (
    input  wire       clk,
    input  wire       clr_bar,   // ~CLR (assincrono)
    input  wire [3:0] opcode,    // nibble alto do IR

    output wire       cp,
    output wire       ep,
    output wire       lm_bar,
    output wire       ce_bar,
    output wire       li_bar,
    output wire       ei_bar,
    output wire       la_bar,
    output wire       ea,
    output wire       su,
    output wire       eu,
    output wire       lb_bar,
    output wire       lo_bar,

    output wire [11:0] con,      // palavra de controle (debug)
    output wire [5:0]  ring,     // estado em one-hot T1..T6 (debug)
    output wire        hlt       // HALT (registrado)
);
    // ---- opcodes ----
    localparam LDA = 4'b0000;
    localparam ADD = 4'b0001;
    localparam SUB = 4'b0010;
    localparam OUT = 4'b1110;
    localparam HLT = 4'b1111;

    // ---- estados da FSM (codificacao binaria, nomes simbolicos) ----
    localparam S_IDLE = 3'd0;   // partida / ocioso
    localparam S_T1    = 3'd1;
    localparam S_T2    = 3'd2;
    localparam S_T3    = 3'd3;
    localparam S_T4    = 3'd4;
    localparam S_T5    = 3'd5;
    localparam S_T6    = 3'd6;

    // ---- palavra de controle ociosa (nenhum sinal ativo) ----
    localparam IDLE = 12'b0011_1110_0011;

    reg [2:0] state, next_state;

    // -------------------------------------------------------
    // HALT registrado: trava em T4 quando opcode = HLT
    // (em T4 o opcode ja foi carregado no IR em T3)
    // -------------------------------------------------------
    reg halted;
    wire run = ~halted;            // clock-enable da FSM

    always @(posedge clk or negedge clr_bar) begin
        if (!clr_bar)
            halted <= 1'b0;
        else if ((state == S_T4) && (opcode == HLT))
            halted <= 1'b1;
    end

    assign hlt = halted;

    // -------------------------------------------------------
    // (1) REGISTRADOR DE ESTADO
    //     - reset assincrono leva a IDLE (absorve a fase do reset)
    //     - avanca na borda de DESCIDA do clock
    // -------------------------------------------------------
    always @(negedge clk or negedge clr_bar) begin
        if (!clr_bar)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // -------------------------------------------------------
    // (2) LOGICA DE PROXIMO ESTADO (combinacional)
    //     Sequencia fixa T1->T2->...->T6->T1. Quando halted (!run),
    //     a FSM segura o estado atual (congelada).
    // -------------------------------------------------------
    always @(*) begin
        if (!run)
            next_state = state;        // congelado por HLT
        else begin
            case (state)
                S_IDLE: next_state = S_T1;   // 1o negedge util -> T1
                S_T1:   next_state = S_T2;
                S_T2:   next_state = S_T3;
                S_T3:   next_state = S_T4;
                S_T4:   next_state = S_T5;
                S_T5:   next_state = S_T6;
                S_T6:   next_state = S_T1;   // fecha o anel
                default: next_state = S_IDLE;
            endcase
        end
    end

    // -------------------------------------------------------
    // (3) LOGICA DE SAIDA - palavra de controle (combinacional)
    //     Maquina de MOORE estendida: a saida depende do estado e
    //     do opcode (T4..T6), exatamente como na tabela da Lista 4.
    // -------------------------------------------------------
    reg [11:0] con_r;

    always @(*) begin
        con_r = IDLE;
        case (state)
            // ----- CICLO DE BUSCA (igual p/ toda instrucao) -----
            S_T1: con_r = 12'b0101_1110_0011; // Ep, ~Lm
            S_T2: con_r = 12'b1011_1110_0011; // Cp
            S_T3: con_r = 12'b0010_0110_0011; // ~CE, ~Li

            // ----- CICLO DE EXECUCAO (depende do opcode) -----
            S_T4: case (opcode)
                    LDA, ADD, SUB: con_r = 12'b0001_1010_0011; // ~Lm, ~Ei
                    OUT:           con_r = 12'b0011_1111_0010; // Ea, ~Lo
                    default:       con_r = IDLE;               // HLT/idle
                  endcase
            S_T5: case (opcode)
                    LDA:      con_r = 12'b0010_1100_0011; // ~CE, ~La
                    ADD, SUB: con_r = 12'b0010_1110_0001; // ~CE, ~Lb
                    default:  con_r = IDLE;               // OUT/HLT/idle
                  endcase
            S_T6: case (opcode)
                    ADD: con_r = 12'b0011_1100_0111; // ~La, Eu
                    SUB: con_r = 12'b0011_1100_1111; // ~La, Eu, Su
                    default: con_r = IDLE;           // LDA/OUT/HLT/idle
                  endcase
            default: con_r = IDLE;                   // S_IDLE
        endcase
    end

    assign con = con_r;

    // ---- estado em one-hot (compatibilidade com o debug 'ring') ----
    //      T1..T6 -> bits 0..5; IDLE -> tudo zero
    assign ring = (state == S_T1) ? 6'b000001 :
                  (state == S_T2) ? 6'b000010 :
                  (state == S_T3) ? 6'b000100 :
                  (state == S_T4) ? 6'b001000 :
                  (state == S_T5) ? 6'b010000 :
                  (state == S_T6) ? 6'b100000 :
                                    6'b000000;

    // ---- divisao da palavra em sinais individuais ----
    assign cp     = con_r[11];
    assign ep     = con_r[10];
    assign lm_bar = con_r[9];
    assign ce_bar = con_r[8];
    assign li_bar = con_r[7];
    assign ei_bar = con_r[6];
    assign la_bar = con_r[5];
    assign ea     = con_r[4];
    assign su     = con_r[3];
    assign eu     = con_r[2];
    assign lb_bar = con_r[1];
    assign lo_bar = con_r[0];
endmodule
