// =============================================================
// clock_divider.v  -  Divisor de clock para o SAP-1 no FPGA
//
// Divide o clock da placa (tipicamente 50 MHz) para uma frequencia
// baixa o suficiente para a execucao ser visivel nos LEDs.
//
//   freq_saida = freq_entrada / (2 * DIV)
//
// Exemplos para clock de 50 MHz:
//   DIV = 25_000_000 -> 1 Hz   (1 estado T por segundo)  [padrao]
//   DIV = 12_500_000 -> 2 Hz
//   DIV =  5_000_000 -> 5 Hz
//
// Com 1 Hz, uma instrucao (6 estados T) leva ~6 s; o programa de
// 5 instrucoes roda em ~30 s, bom para o video da entrega.
// =============================================================
module clock_divider #(
    parameter integer DIV = 25_000_000
)(
    input  wire clk_in,    // clock da placa
    input  wire rst_n,     // reset assincrono [ativo baixo]
    output reg  clk_out    // clock lento
);
    // largura suficiente para contar ate DIV-1
    reg [31:0] count;

    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            count   <= 32'd0;
            clk_out <= 1'b0;
        end else if (count >= (DIV - 1)) begin
            count   <= 32'd0;
            clk_out <= ~clk_out;
        end else begin
            count   <= count + 32'd1;
        end
    end
endmodule
