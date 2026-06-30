// Testbench unitario - adder_subtractor (ALU combinacional)
`timescale 1ns/1ps
module tb_adder_subtractor;
    reg su; reg [7:0] acc, breg; wire [7:0] result;
    integer errors = 0;

    adder_subtractor dut (.su(su), .acc(acc), .breg(breg), .result(result));

    task check(input [255:0] nm, input [31:0] got, input [31:0] exp);
        begin if (got !== exp) begin
            $display("  FAIL %0s: obtido=%0d esperado=%0d", nm, got, exp);
            errors = errors + 1; end
        end
    endtask

    initial begin
        // soma (su=0)
        su = 0;
        acc = 3;   breg = 3;   #1; check("3+3",   result, 6);
        acc = 18;  breg = 9;   #1; check("18+9",  result, 27);
        acc = 200; breg = 100; #1; check("200+100 (wrap 8b)", result, 8'd44); // 300 mod 256

        // subtracao (su=1, complemento de dois)
        su = 1;
        acc = 27;  breg = 3;   #1; check("27-3",  result, 24);
        acc = 5;   breg = 5;   #1; check("5-5",   result, 0);
        acc = 0;   breg = 1;   #1; check("0-1 (=255)", result, 8'd255);

        if (errors == 0) $display("adder_subtractor: PASSOU");
        else             $display("adder_subtractor: FALHOU (%0d erros)", errors);
        $finish;
    end
endmodule
