// =============================================================
// accumulator.v  -  Acumulador A do SAP-1
// Registrador de 8 bits. Sua saida alimenta continuamente o
// somador/subtrator (acc_out) e tambem vai para o barramento
// quando Ea esta ativo (habilitacao feita pelo mux do top).
//   la_bar : carrega A a partir do barramento [ativo baixo]
// =============================================================
module accumulator (
    input  wire       clk,
    input  wire       clr_bar,   // ~CLR
    input  wire       la_bar,    // ~La
    input  wire [7:0] bus_in,
    output reg  [7:0] acc_out
);
    always @(posedge clk or negedge clr_bar) begin
        if (!clr_bar)
            acc_out <= 8'b0000_0000;
        else if (!la_bar)
            acc_out <= bus_in;
    end
endmodule
