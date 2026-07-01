// Testbench unitario - seg7 (decodificador hexadecimal, ativo baixo {g,f,e,d,c,b,a})
`timescale 1ns/1ps
module tb_seg7;
    reg [3:0] val; wire [6:0] seg;
    integer errors = 0;

    seg7 dut (.val(val), .seg(seg));

    task check(input [255:0] nm, input [31:0] got, input [31:0] exp);
        begin if (got !== exp) begin
            $display("  FAIL %0s: obtido=%07b esperado=%07b", nm, got[6:0], exp[6:0]);
            errors = errors + 1; end
        end
    endtask

    initial begin
        val = 4'h0; #1; check("0", seg, 7'b1000000);
        val = 4'h1; #1; check("1", seg, 7'b1111001);
        val = 4'h2; #1; check("2", seg, 7'b0100100);
        val = 4'h9; #1; check("9", seg, 7'b0010000);
        val = 4'hA; #1; check("A", seg, 7'b0001000);
        val = 4'hB; #1; check("B", seg, 7'b0000011);
        val = 4'hF; #1; check("F", seg, 7'b0001110);

        if (errors == 0) $display("seg7: PASSOU");
        else             $display("seg7: FALHOU (%0d erros)", errors);
        $stop;
    end
endmodule
