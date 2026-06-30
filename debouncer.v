// =============================================================
// debouncer.v  -  Antirruido (debounce) para botao mecanico
//
// Sincroniza e filtra o ruido de um botao da placa. Mantem a saida
// estavel ate que a entrada permaneca constante por N ciclos do
// clock de referencia. Usado para o clock manual (passo a passo).
//
//   DE2-115: clock de 50 MHz -> N = 500_000 ~= 10 ms de filtro.
// =============================================================
module debouncer #(
    parameter integer N = 500_000
)(
    input  wire clk,
    input  wire rst_n,
    input  wire noisy,
    output reg  clean
);
    reg sync0, sync1;
    reg [31:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync0 <= 1'b0;
            sync1 <= 1'b0;
            cnt   <= 32'd0;
            clean <= 1'b0;
        end else begin
            // sincronizador de 2 estagios
            sync0 <= noisy;
            sync1 <= sync0;

            if (sync1 == clean) begin
                cnt <= 32'd0;                 // estavel: zera o contador
            end else begin
                cnt <= cnt + 32'd1;           // mudou: conta
                if (cnt >= (N - 1)) begin
                    clean <= sync1;           // aceita o novo nivel
                    cnt   <= 32'd0;
                end
            end
        end
    end
endmodule
