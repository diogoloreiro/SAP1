// =============================================================
// ram_16x8.v  -  Memoria RAM 16 x 8 do SAP-1
// Enderecada pelo MAR. Quando ~CE esta ativo, o dado e' colocado
// no barramento W (a habilitacao em si e' feita pelo mux do top).
// Como o SAP-1 basico nao possui instrucao de escrita (STA),
// a memoria e' apenas de leitura durante a execucao e e'
// inicializada com o programa abaixo.
//
//       programa1.txt  -> 3^3 = 27
//       programa2.txt  -> (((7+3)-2)+5)-4 +7-3+5 = 18
//       programa3.txt  -> 3 x 4 = 12
//       programa4.txt  -> 12 / 4 = 3
//
// Formato de cada instrucao:  [opcode(4) | operando(4)]
//   LDA=0000  ADD=0001  SUB=0010  OUT=1110  HLT=1111
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

       
        // Programa 3: 3 x 4 = 12  (somas repetidas de 3)
        mem[0]  = 8'b0000_1011; // LDA 11
        mem[1]  = 8'b0001_1011; // ADD 11
        mem[2]  = 8'b0001_1011; // ADD 11
        mem[3]  = 8'b0001_1011; // ADD 11   -> 12
        mem[4]  = 8'b1110_0000; // OUT       -> 12
        mem[5]  = 8'b0010_1100; // SUB 12   (dado 0)
        mem[6]  = 8'b0001_1101; // ADD 13   (dado 0)
        mem[7]  = 8'b0010_1110; // SUB 14   (dado 0)
        mem[8]  = 8'b0001_1111; // ADD 15   (dado 0)
        mem[9]  = 8'b1110_0000; // OUT       -> 12
        mem[10] = 8'b1111_0000; // HLT
        mem[11] = 8'd3;         // dado
        mem[12] = 8'd0;         // dado
        mem[13] = 8'd0;         // dado
        mem[14] = 8'd0;         // dado
        mem[15] = 8'd0;         // dado

    end

    assign data_out = mem[addr];
endmodule
