// Testbench unitario - debouncer (N reduzido para simular rapido)
// clean so muda quando 'noisy' fica estavel por ~N ciclos; glitches
// curtos sao filtrados.
`timescale 1ns/1ps
module tb_debouncer;
    reg clk, rst_n, noisy; wire clean;
    integer errors = 0;

    localparam N = 4;
    debouncer #(.N(N)) dut (.clk(clk), .rst_n(rst_n), .noisy(noisy), .clean(clean));

    initial clk = 0; always #5 clk = ~clk;

    task check(input [255:0] nm, input got, input exp);
        begin if (got !== exp) begin
            $display("  FAIL %0s: obtido=%b esperado=%b", nm, got, exp);
            errors = errors + 1; end
        end
    endtask

    initial begin
        rst_n = 0; noisy = 0; @(posedge clk); #1;
        check("reset clean=0", clean, 1'b0);
        rst_n = 1;

        // nivel estavel em 1 -> clean sobe
        noisy = 1; repeat (N + 4) @(posedge clk); #1;
        check("estavel 1 -> clean=1", clean, 1'b1);

        // glitch curto para 0 (1 ciclo) -> deve ser filtrado
        noisy = 0; @(posedge clk);
        noisy = 1; repeat (2) @(posedge clk); #1;
        check("glitch filtrado (clean=1)", clean, 1'b1);

        // nivel estavel em 0 -> clean desce
        noisy = 0; repeat (N + 4) @(posedge clk); #1;
        check("estavel 0 -> clean=0", clean, 1'b0);

        if (errors == 0) $display("debouncer: PASSOU");
        else             $display("debouncer: FALHOU (%0d erros)", errors);
        $finish;
    end
endmodule
