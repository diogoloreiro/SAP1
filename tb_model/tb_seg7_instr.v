// Testbench unitario - seg7_instr (opcode -> letra L/A/5/o/H)
`timescale 1ns/1ps
module tb_seg7_instr;
    reg [3:0] opcode; wire [6:0] seg;
    integer errors = 0;

    seg7_instr dut (.opcode(opcode), .seg(seg));

    task check(input [255:0] nm, input [31:0] got, input [31:0] exp);
        begin if (got !== exp) begin
            $display("  FAIL %0s: obtido=%07b esperado=%07b", nm, got[6:0], exp[6:0]);
            errors = errors + 1; end
        end
    endtask

    initial begin
        opcode = 4'b0000; #1; check("LDA->L", seg, 7'b1000111);
        opcode = 4'b0001; #1; check("ADD->A", seg, 7'b0001000);
        opcode = 4'b0010; #1; check("SUB->5", seg, 7'b0010010);
        opcode = 4'b1110; #1; check("OUT->o", seg, 7'b0100011);
        opcode = 4'b1111; #1; check("HLT->H", seg, 7'b0001001);
        opcode = 4'b0111; #1; check("outro->apagado", seg, 7'b1111111);

        if (errors == 0) $display("seg7_instr: PASSOU");
        else             $display("seg7_instr: FALHOU (%0d erros)", errors);
        $stop;
    end
endmodule
