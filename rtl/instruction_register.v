// =============================================================
// instruction_register.v  -  Registrador de Instrucoes (IR) do SAP-1
// Recebe a instrucao de 8 bits do barramento e a divide em dois nibbles:
//   opcode  = bits [7:4]  -> vai para o controlador-sequenciador
//   operand = bits [3:0]  -> vai para o barramento quando ~Ei ativo
//                            (a habilitacao e' feita pelo mux do top)
//   li_bar : carrega o IR a partir do barramento [ativo baixo]
// =============================================================
module instruction_register (
    input  wire       clk,
    input  wire       clr_bar,   // ~CLR
    input  wire       li_bar,    // ~Li
    input  wire [7:0] bus_in,
    output wire [3:0] opcode,    // nibble alto
    output wire [3:0] operand    // nibble baixo
);
    reg [7:0] ir;

    always @(posedge clk or negedge clr_bar) begin
        if (!clr_bar)
            ir <= 8'b0000_0000;
        else if (!li_bar)
            ir <= bus_in;
    end

    assign opcode  = ir[7:4];
    assign operand = ir[3:0];
endmodule
