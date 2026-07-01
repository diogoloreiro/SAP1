// =============================================================
// seg7_instr.v  -  Decodificador de OPCODE -> letra no display
//
// Mostra a instrucao atual (nibble alto do IR) como uma letra
// no display de 7 segmentos, em vez do codigo hexadecimal cru:
//
//   opcode      instrucao   letra mostrada
//   0000 (0x0)  LDA         "L"
//   0001 (0x1)  ADD         "A"
//   0010 (0x2)  SUB         "5"  (parecido com 'S')
//   1110 (0xE)  OUT         "o"  (minusculo, p/ nao virar '0')
//   1111 (0xF)  HLT         "H"
//   outros                  apagado
//
// Saida ATIVA EM BAIXO (0 = segmento aceso), ordem {g,f,e,d,c,b,a},
// igual ao seg7.v.
//
//      aaa
//     f   b
//      ggg
//     e   c
//      ddd
// =============================================================
module seg7_instr (
    input  wire [3:0] opcode,
    output reg  [6:0] seg      // {g,f,e,d,c,b,a}, ativo baixo
);
    localparam LDA = 4'b0000;
    localparam ADD = 4'b0001;
    localparam SUB = 4'b0010;
    localparam OUT = 4'b1110;
    localparam HLT = 4'b1111;

    always @(*) begin
        case (opcode)
            LDA:     seg = 7'b1000111; // L  (d,e,f)
            ADD:     seg = 7'b0001000; // A  (a,b,c,e,f,g)
            SUB:     seg = 7'b0010010; // 5/S (a,c,d,f,g)
            OUT:     seg = 7'b0100011; // o  (c,d,e,g)
            HLT:     seg = 7'b0001001; // H  (b,c,e,f,g)
            default: seg = 7'b1111111; // apagado
        endcase
    end
endmodule
