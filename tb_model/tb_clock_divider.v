// Testbench unitario - clock_divider (DIV reduzido para simular rapido)
// clk_out troca de nivel a cada DIV bordas de subida do clk_in.
`timescale 1ns/1ps
module tb_clock_divider;
    reg clk_in, rst_n; wire clk_out;
    integer errors = 0;

    localparam DIV = 3;
    clock_divider #(.DIV(DIV)) dut (.clk_in(clk_in), .rst_n(rst_n), .clk_out(clk_out));

    initial clk_in = 0; always #5 clk_in = ~clk_in;

    task check(input [255:0] nm, input got, input exp);
        begin if (got !== exp) begin
            $display("  FAIL %0s: obtido=%b esperado=%b", nm, got, exp);
            errors = errors + 1; end
        end
    endtask

    initial begin
        rst_n = 0; @(posedge clk_in); #1;
        check("reset clk_out=0", clk_out, 1'b0);
        rst_n = 1;

        // apos DIV subidas, clk_out deve virar 1
        repeat (DIV) @(posedge clk_in); #1;
        check("apos DIV -> 1", clk_out, 1'b1);

        // mais DIV subidas -> volta a 0
        repeat (DIV) @(posedge clk_in); #1;
        check("apos 2*DIV -> 0", clk_out, 1'b0);

        // mais DIV -> 1 de novo (periodicidade)
        repeat (DIV) @(posedge clk_in); #1;
        check("apos 3*DIV -> 1", clk_out, 1'b1);

        if (errors == 0) $display("clock_divider: PASSOU");
        else             $display("clock_divider: FALHOU (%0d erros)", errors);
        $stop;
    end
endmodule
