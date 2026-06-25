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
//   HEX0, HEX1     valor de saida em hexadecimal (nibble baixo/alto)
//                  HEXn[7] = ponto decimal (apagado)
//
//   Resultado esperado do programa de exemplo: LEDR = 0001 1010,
//   HEX1 HEX0 = "1A" (= 26 decimal).
//
//   OBS.: a DE10-Lite tem apenas KEY[1:0] (2 botoes). Defina SW[0]
//   ANTES de soltar o reset e nao troque o modo durante a execucao.
// =============================================================
module sap1_fpga #(
    parameter integer DIV = 25_000_000   // 50 MHz / (2*DIV) = 1 Hz
)(
    input  wire        MAX10_CLK1_50,
    input  wire [1:0]  KEY,
    input  wire [0:0]  SW,
    output wire [9:0]  LEDR,
    output wire [7:0]  HEX0,
    output wire [7:0]  HEX1
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

    sap1_top u_cpu (
        .clk      (cpu_clk),
        .clr_bar  (rst_n),
        .out_port (out_value),
        .hlt      (hlt)
    );

    // -------------------------------------------------------
    // Saidas visuais
    // -------------------------------------------------------
    assign LEDR[7:0] = out_value;   // resultado em binario
    assign LEDR[8]   = 1'b0;
    assign LEDR[9]   = hlt;         // indicador de parada

    // 7 segmentos (HEXn[7] = ponto decimal, apagado = 1)
    wire [6:0] seg0, seg1;
    seg7 u_hex0 (.val(out_value[3:0]), .seg(seg0)); // nibble baixo
    seg7 u_hex1 (.val(out_value[7:4]), .seg(seg1)); // nibble alto
    assign HEX0 = {1'b1, seg0};
    assign HEX1 = {1'b1, seg1};
endmodule
