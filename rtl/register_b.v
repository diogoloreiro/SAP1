// =============================================================
// register_b.v  -  Registrador B do SAP-1
// Fornece o segundo operando para o somador/subtrator.
//   lb_bar : carrega B a partir do barramento [ativo baixo]
// =============================================================
module register_b (
    input  wire       clk,
    input  wire       clr_bar,   // ~CLR
    input  wire       lb_bar,    // ~Lb
    input  wire [7:0] bus_in,
    output reg  [7:0] b_out
);
    always @(posedge clk or negedge clr_bar) begin
        if (!clr_bar)
            b_out <= 8'b0000_0000;
        else if (!lb_bar)
            b_out <= bus_in;
    end
endmodule
