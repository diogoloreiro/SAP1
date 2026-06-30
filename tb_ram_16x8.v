// Testbench unitario - ram_16x8 (ROM de leitura combinacional)
// Verifica o caminho de leitura (data_out = mem[addr]) para os 16
// enderecos, independente de qual programa esteja carregado.
`timescale 1ns/1ps
module tb_ram_16x8;
    reg  [3:0] addr; wire [7:0] data_out;
    integer errors = 0, i;

    ram_16x8 dut (.addr(addr), .data_out(data_out));

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            addr = i[3:0]; #1;
            if (data_out !== dut.mem[i]) begin
                $display("  FAIL addr=%0d: data_out=%02h mem=%02h",
                         i, data_out, dut.mem[i]);
                errors = errors + 1;
            end
            if (data_out === 8'hxx) begin
                $display("  FAIL addr=%0d: data_out indefinido (X)", i);
                errors = errors + 1;
            end
        end
        // a primeira posicao (onde o PC comeca) deve conter uma instrucao
        addr = 0; #1;
        if (data_out === 8'h00)
            $display("  AVISO: mem[0]=00 (nenhum programa carregado?)");

        if (errors == 0) $display("ram_16x8: PASSOU");
        else             $display("ram_16x8: FALHOU (%0d erros)", errors);
        $finish;
    end
endmodule
