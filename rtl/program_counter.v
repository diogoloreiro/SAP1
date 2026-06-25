// =============================================================
// program_counter.v  -  Contador de Programa (PC) do SAP-1
// Contador de 4 bits (0000 a 1111).
//   Cp  : habilita contagem (incrementa na borda de subida)  [ativo alto]
//   Ep  : habilita saida no barramento W -> tratado no mux do top  [ativo alto]
//   clr_bar : clear assincrono [ativo baixo]
// =============================================================
module program_counter (
    input  wire       clk,
    input  wire       clr_bar,   // ~CLR
    input  wire       cp,        // Cp
    output reg  [3:0] pc_out
);
    always @(posedge clk or negedge clr_bar) begin
        if (!clr_bar)
            pc_out <= 4'b0000;
        else if (cp)
            pc_out <= pc_out + 4'b0001;
    end
endmodule
