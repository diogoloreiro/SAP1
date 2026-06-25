// =============================================================
// ram_16x8.v  -  Memoria RAM 16 x 8 do SAP-1
// Enderecada pelo MAR. Quando ~CE esta ativo, o dado e' colocado
// no barramento W (a habilitacao em si e' feita pelo mux do top).
// Como o SAP-1 basico nao possui instrucao de escrita (STA),
// a memoria e' apenas de leitura durante a execucao e e'
// inicializada com o programa abaixo.
//
//  ---- PROGRAMA DE TESTE ----
//  end  conteudo      mnemonico     comentario
//   0   0000 1101     LDA 13        A <- mem[13] = 16
//   1   0001 1110     ADD 14        A <- A + mem[14] = 16+14 = 30
//   2   0010 1111     SUB 15        A <- A - mem[15] = 30-4  = 26
//   3   1110 0000     OUT           saida <- A = 26 (0x1A)
//   4   1111 0000     HLT           para o processamento
//  13   0001 0000     dado = 16
//  14   0000 1110     dado = 14
//  15   0000 0100     dado = 4
// =============================================================
module ram_16x8 (
    input  wire [3:0] addr,
    output wire [7:0] data_out
);
    reg [7:0] mem [0:15];

    integer i;
    initial begin
        for (i = 0; i < 16; i = i + 1)
            mem[i] = 8'h00;

        mem[0]  = 8'b0000_1101; // LDA 13
        mem[1]  = 8'b0001_1110; // ADD 14
        mem[2]  = 8'b0010_1111; // SUB 15
        mem[3]  = 8'b1110_0000; // OUT
        mem[4]  = 8'b1111_0000; // HLT

        mem[13] = 8'd16;        // dado
        mem[14] = 8'd14;        // dado
        mem[15] = 8'd4;         // dado
    end

    assign data_out = mem[addr];
endmodule
