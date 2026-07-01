// =============================================================
// sap1_fpga.v  -  Top-level de placa para o SAP-1 (Terasic DE10-Lite)
//                 FPGA: Intel MAX 10  10M50DAF484C7G
//
// Junta o nucleo (sap1_top) com:
//   - divisor de clock (50 MHz -> 1 Hz)
//   - clock manual passo-a-passo (botao com debounce)
//   - seletor auto/manual de clock
//   - sincronizador de reset (assincrono no assert, sincrono no
//     desassert -> evita recovery/removal violado)
//   - mapeamento da saida nos LEDs e nos displays de 7 segmentos
//
// CONTROLES NA PLACA (DE10-Lite):
//   MAX10_CLK1_50  clock de 50 MHz da placa
//   KEY[0]         RESET (pressionado = reset; ativo baixo)
//   KEY[1]         STEP  (passo manual de clock, quando SW[0]=1)
//   SW[0]          modo de clock: 0 = automatico (1 Hz), 1 = manual
//   LEDR[7:0]      registrador de saida (resultado do programa)
//   LEDR[9]        HLT aceso quando o processador para
//   HEX5           estado T atual (1..6 ; 0 = idle/reset)
//   HEX4           instrucao atual em letra: L=LDA A=ADD 5=SUB o=OUT H=HLT
//   HEX3, HEX2     acumulador A em hexadecimal (registrador real)
//   HEX1, HEX0     resultado (registrador de saida) em hexadecimal
//                  HEXn[7] = ponto decimal (apagado)
//
//   SW[1]=1 (debug): HEX3,HEX2 mostram o registrador B e HEX1,HEX0
//   mostram o barramento W (valor que circula a cada estado).
//
//   Resultado esperado do programa de exemplo (3^3 = 27):
//   LEDR[7:0] = 0001 1011,  HEX1 HEX0 = "1B" (= 27 decimal).
//
//   OBS.: a DE10-Lite tem apenas KEY[1:0] (2 botoes). Defina SW[0]
//   ANTES de soltar o reset e nao troque o modo durante a execucao.
// =============================================================
module sap1_fpga #(
    parameter integer DIV = 25_000_000   // 50 MHz / (2*DIV) = 1 Hz
)(
    input  wire        MAX10_CLK1_50,
    input  wire [1:0]  KEY,
    input  wire [1:0]  SW,        // SW[0]=clock auto/manual ; SW[1]=display normal/debug
    output wire [9:0]  LEDR,
    output wire [7:0]  HEX0,      // resultado - nibble baixo
    output wire [7:0]  HEX1,      // resultado - nibble alto
    output wire [7:0]  HEX2,      // apagado
    output wire [7:0]  HEX3,      // apagado
    output wire [7:0]  HEX4,      // instrucao atual (letra)
    output wire [7:0]  HEX5       // estado T (1..6)
);
    wire clk50 = MAX10_CLK1_50;

    // -------------------------------------------------------
    // Sincronizador de reset (assert assincrono, desassert sincrono)
    // KEY[0] = 0 quando pressionado -> reset_n = 0
    // -------------------------------------------------------
    wire ext_rst_n = KEY[0];
    reg  rs0, rs1;
    always @(posedge clk50 or negedge ext_rst_n) begin
        if (!ext_rst_n) begin
            rs0 <= 1'b0;
            rs1 <= 1'b0;
        end else begin
            rs0 <= 1'b1;
            rs1 <= rs0;
        end
    end
    wire rst_n = rs1;   // ~CLR sincronizado

    // -------------------------------------------------------
    // Fontes de clock
    // -------------------------------------------------------
    wire slow_clk;
    clock_divider #(.DIV(DIV)) u_div (
        .clk_in  (clk50),
        .rst_n   (rst_n),
        .clk_out (slow_clk)
    );

    // clock manual com debounce (KEY[1], ativo baixo -> invertido)
    wire step_clk;
    debouncer #(.N(500_000)) u_db (
        .clk   (clk50),
        .rst_n (rst_n),
        .noisy (~KEY[1]),     // 1 enquanto pressionado
        .clean (step_clk)
    );

    // seletor: SW[0]=0 automatico, SW[0]=1 manual
    wire cpu_clk = SW[0] ? step_clk : slow_clk;

    // -------------------------------------------------------
    // Nucleo SAP-1
    // -------------------------------------------------------
    wire [7:0] out_value;
    wire       hlt;
    wire [7:0] bus_w;       // barramento W (observacao)
    wire [5:0] tstate;      // estado do contador de anel (T1..T6)
    wire [3:0] opcode;      // opcode atual no IR
    wire [7:0] acc_a;       // acumulador A (registrador real)
    wire [7:0] reg_b;       // registrador B (registrador real)

    sap1_top u_cpu (
        .clk      (cpu_clk),
        .clr_bar  (rst_n),
        .out_port (out_value),
        .hlt      (hlt),
        .bus_w    (bus_w),
        .tstate   (tstate),
        .opcode   (opcode),
        .acc      (acc_a),
        .breg     (reg_b)
    );

    // -------------------------------------------------------
    // Saidas visuais  (HEX5 ... HEX0, da esquerda p/ a direita)
    //   HEX5      = estado T atual (1..6 ; 0 = idle)
    //   HEX4      = instrucao atual em letra (L/A/5/o/H)
    //   HEX3,HEX2 = ACUMULADOR A (registrador real, em hex)
    //   HEX1,HEX0 = RESULTADO (registrador de saida, em hex)
    //
    //   SW[1] (debug): HEX3,HEX2 -> registrador B ; HEX1,HEX0 -> barramento W ;
    //   LEDs -> estado T.
    // -------------------------------------------------------
    wire debug = SW[1];

    // ---- LEDs ----
    //   normal: LEDR[7:0] = resultado em binario
    //   debug : LEDR[5:0] = estado T (one-hot T1..T6), LEDR[7:6] apagados
    assign LEDR[5:0] = debug ? tstate        : out_value[5:0];
    assign LEDR[7:6] = debug ? 2'b00         : out_value[7:6];
    assign LEDR[8]   = 1'b0;
    assign LEDR[9]   = hlt;          // indicador de parada (sempre)

    // ---- HEX5: estado T (one-hot T1..T6) -> numero 1..6 ----
    reg [3:0] tnum;
    always @(*) begin
        case (tstate)
            6'b000001: tnum = 4'd1;
            6'b000010: tnum = 4'd2;
            6'b000100: tnum = 4'd3;
            6'b001000: tnum = 4'd4;
            6'b010000: tnum = 4'd5;
            6'b100000: tnum = 4'd6;
            default:   tnum = 4'd0;   // IDLE / reset
        endcase
    end
    wire [6:0] seg_state;
    seg7 u_hex5 (.val(tnum), .seg(seg_state));
    assign HEX5 = {1'b1, seg_state};

    // ---- HEX4: instrucao atual (letra) ----
    wire [6:0] seg_instr;
    seg7_instr u_hex4 (.opcode(opcode), .seg(seg_instr));
    assign HEX4 = {1'b1, seg_instr};

    // ---- HEX3, HEX2: acumulador A (registrador real, em hex) ----
    //   debug (SW[1]=1): mostra o registrador B no lugar de A
    wire [7:0] mid_val = debug ? reg_b : acc_a;
    wire [6:0] seg2, seg3;
    seg7 u_hex2 (.val(mid_val[3:0]), .seg(seg2)); // nibble baixo de A
    seg7 u_hex3 (.val(mid_val[7:4]), .seg(seg3)); // nibble alto de A
    assign HEX2 = {1'b1, seg2};
    assign HEX3 = {1'b1, seg3};

    // ---- HEX1, HEX0: resultado (ou barramento W em modo debug) ----
    wire [7:0] disp_val = debug ? bus_w : out_value;
    wire [6:0] seg0, seg1;
    seg7 u_hex0 (.val(disp_val[3:0]), .seg(seg0)); // nibble baixo
    seg7 u_hex1 (.val(disp_val[7:4]), .seg(seg1)); // nibble alto
    assign HEX0 = {1'b1, seg0};
    assign HEX1 = {1'b1, seg1};
endmodule
