// =============================================================
// output_register.v  -  Registrador de Saida do SAP-1
// Recebe o valor do acumulador (via barramento, com Ea ativo) e
// o disponibiliza para o visor binario (8 LEDs).
//   lo_bar : carrega o registrador de saida [ativo baixo]
// =============================================================
module output_register (
    input  wire       clk,
    input  wire       clr_bar,   // ~CLR
    input  wire       lo_bar,    // ~Lo
    input  wire [7:0] bus_in,
    output reg  [7:0] out_port
);
    always @(posedge clk or negedge clr_bar) begin
        if (!clr_bar)
            out_port <= 8'b0000_0000;
        else if (!lo_bar)
            out_port <= bus_in;
    end
endmodule
