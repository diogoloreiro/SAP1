// =============================================================
// controller_sequencer.v  -  Controlador/Sequenciador do SAP-1
// (versao revisada: estado ocioso de partida + HLT registrado +
//  clock-enable em vez de gating de clock)
//
// Contem:
//  (1) Contador de anel de 6 estados T1..T6, acionado na BORDA DE
//      DESCIDA, com um estado OCIOSO de partida (6'b000000) que
//      absorve a fase do reset (remove a dependencia de soltar o
//      reset com o clock baixo).
//  (2) Logica combinacional que gera a palavra de controle de
//      12 bits (CON) em funcao do estado e do opcode.
//  (3) Flag de HALT REGISTRADO, travado em T4 quando opcode = HLT.
//      O congelamento e' feito por CLOCK-ENABLE (run), nao por
//      gating do clock -> sintetizavel e sem glitch.
//
// Relacao de bordas:
//   - ring counter avanca na borda de DESCIDA (negedge)
//   - registradores carregam na borda de SUBIDA (posedge)
//   Assim a palavra de controle de Tn ja esta estavel quando os
//   registradores reagem.
//
// Formato da palavra de controle (MSB -> LSB):
//   CON = { Cp, Ep, ~Lm, ~CE, ~Li, ~Ei, ~La, Ea, Su, Eu, ~Lb, ~Lo }
//   bit:  11  10   9    8    7    6    5   4   3   2   1    0
//
// Nivel ativo:
//   Cp,Ep,Ea,Su,Eu               -> ativos em ALTO  (1 = ativo)
//   ~Lm,~CE,~Li,~Ei,~La,~Lb,~Lo  -> ativos em BAIXO (0 = ativo)
// =============================================================
module controller_sequencer (
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
    output wire [5:0]  ring,     // estado one-hot (debug)
    output wire        hlt       // HALT (registrado)
);
    // ---- opcodes ----
    localparam LDA = 4'b0000;
    localparam ADD = 4'b0001;
    localparam SUB = 4'b0010;
    localparam OUT = 4'b1110;
    localparam HLT = 4'b1111;

    // ---- estados (one-hot) ----
    localparam IDLE_ST = 6'b000000; // partida: nenhum T ativo
    localparam T1 = 6'b000001;
    localparam T2 = 6'b000010;
    localparam T3 = 6'b000100;
    localparam T4 = 6'b001000;
    localparam T5 = 6'b010000;
    localparam T6 = 6'b100000;

    // ---- palavra de controle ociosa (nenhum sinal ativo) ----
    localparam IDLE = 12'b0011_1110_0011;

    // -------------------------------------------------------
    // (3) HALT registrado: trava em T4 quando opcode = HLT
    //     (em T4 o opcode ja foi carregado no IR em T3)
    // -------------------------------------------------------
    reg halted;
    wire run = ~halted;            // clock-enable do contador de anel

    always @(posedge clk or negedge clr_bar) begin
        if (!clr_bar)
            halted <= 1'b0;
        else if ((ring == T4) && (opcode == HLT))
            halted <= 1'b1;
    end

    assign hlt = halted;

    // -------------------------------------------------------
    // (1) Contador de anel com estado ocioso de partida
    //     e congelamento por clock-enable (run)
    // -------------------------------------------------------
    reg [5:0] ring_r;

    always @(negedge clk or negedge clr_bar) begin
        if (!clr_bar)
            ring_r <= IDLE_ST;             // absorve a fase do reset
        else if (!run)
            ring_r <= ring_r;              // congelado (HLT)
        else if (ring_r == IDLE_ST)
            ring_r <= T1;                  // 1o negedge util -> T1
        else
            ring_r <= {ring_r[4:0], ring_r[5]}; // T1->T2->...->T6->T1
    end

    assign ring = ring_r;

    // -------------------------------------------------------
    // (2) Palavra de controle (combinacional)
    //     Os valores binarios sao copiados 1:1 da tabela da
    //     Lista 4 (slide 23) para verificacao direta; o comentario
    //     ao lado lista os sinais ativos de cada palavra.
    // -------------------------------------------------------
    reg [11:0] con_r;

    always @(*) begin
        con_r = IDLE;
        case (ring_r)
            // ----- CICLO DE BUSCA (igual p/ toda instrucao) -----
            T1: con_r = 12'b0101_1110_0011; // Ep, ~Lm
            T2: con_r = 12'b1011_1110_0011; // Cp
            T3: con_r = 12'b0010_0110_0011; // ~CE, ~Li

            // ----- CICLO DE EXECUCAO (depende do opcode) -----
            T4: case (opcode)
                    LDA, ADD, SUB: con_r = 12'b0001_1010_0011; // ~Lm, ~Ei
                    OUT:           con_r = 12'b0011_1111_0010; // Ea, ~Lo
                    default:       con_r = IDLE;               // HLT/idle
                endcase
            T5: case (opcode)
                    LDA:      con_r = 12'b0010_1100_0011; // ~CE, ~La
                    ADD, SUB: con_r = 12'b0010_1110_0001; // ~CE, ~Lb
                    default:  con_r = IDLE;               // OUT/HLT/idle
                endcase
            T6: case (opcode)
                    ADD: con_r = 12'b0011_1100_0111; // ~La, Eu
                    SUB: con_r = 12'b0011_1100_1111; // ~La, Eu, Su
                    default: con_r = IDLE;           // LDA/OUT/HLT/idle
                endcase
            default: con_r = IDLE;                   // IDLE_ST de partida
        endcase
    end

    assign con = con_r;

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
