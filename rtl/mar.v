// =============================================================
// mar.v  -  Registrador de Endereco de Memoria (MAR) do SAP-1
// Armazena o endereco de 4 bits vindo do barramento W.
//   lm_bar : carrega o MAR a partir do barramento [ativo baixo]
// =============================================================
module mar (
    input  wire       clk,
    input  wire       clr_bar,   // ~CLR
    input  wire       lm_bar,    // ~Lm
    input  wire [3:0] bus_in,    // 4 bits menos significativos do barramento W
    output reg  [3:0] addr_out
);
    always @(posedge clk or negedge clr_bar) begin
        if (!clr_bar)
            addr_out <= 4'b0000;
        else if (!lm_bar)
            addr_out <= bus_in;
    end
endmodule
