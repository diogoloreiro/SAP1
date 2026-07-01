// Testbench unitario - program_counter
`timescale 1ns/1ps
module tb_program_counter;
    reg clk, clr_bar, cp; wire [3:0] pc_out;
    integer errors = 0;

    program_counter dut (.clk(clk), .clr_bar(clr_bar), .cp(cp), .pc_out(pc_out));

    initial clk = 0; always #5 clk = ~clk;

    task check(input [255:0] nm, input [31:0] got, input [31:0] exp);
        begin if (got !== exp) begin
            $display("  FAIL %0s: obtido=%0d esperado=%0d", nm, got, exp);
            errors = errors + 1; end
        end
    endtask

    integer k;
    initial begin
        // reset assincrono
        clr_bar = 0; cp = 0; @(negedge clk); #1;
        check("reset -> 0", pc_out, 0);
        clr_bar = 1;

        // cp=1 incrementa a cada subida
        cp = 1;
        for (k = 1; k <= 5; k = k + 1) begin
            @(posedge clk); #1;
            check("incremento", pc_out, k);
        end

        // cp=0 segura o valor
        cp = 0;
        @(posedge clk); #1;
        check("hold (cp=0)", pc_out, 5);

        // wrap-around 15 -> 0
        cp = 1; clr_bar = 0; @(negedge clk); #1; clr_bar = 1; // volta a 0
        for (k = 0; k < 16; k = k + 1) @(posedge clk);
        #1; check("wrap 15->0", pc_out, 0);

        if (errors == 0) $display("program_counter: PASSOU");
        else             $display("program_counter: FALHOU (%0d erros)", errors);
        $stop;
    end
endmodule
