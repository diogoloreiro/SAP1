// =============================================================
// adder_subtractor.v  -  Somador/Subtrator (ALU) do SAP-1
// Operacao assincrona (combinacional), usando complemento de dois.
//   su = 0 -> result = acc + breg   (soma)
//   su = 1 -> result = acc - breg   (subtracao)
// A saida vai para o barramento quando Eu esta ativo
// (habilitacao feita pelo mux do top).
// =============================================================
module adder_subtractor (
    input  wire       su,        // Su
    input  wire [7:0] acc,
    input  wire [7:0] breg,
    output wire [7:0] result
);
    assign result = su ? (acc - breg) : (acc + breg);
endmodule
