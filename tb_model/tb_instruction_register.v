// Testbench unitario - instruction_register (carrega 8 bits, divide em opcode/operand)
`timescale 1ns/1ps
module tb_instruction_register;
    reg clk, clr_bar, li_bar; reg [7:0] bus_in;
    wire [3:0] opcode, operand;
    integer errors = 0;

    instruction_register dut (.clk(clk), .clr_bar(clr_bar), .li_bar(li_bar),
        .bus_in(bus_in), .opcode(opcode), .operand(operand));

    initial clk = 0; always #5 clk = ~clk;

    task check(input [255:0] nm, input [31:0] got, input [31:0] exp);
        begin if (got !== exp) begin
            $display("  FAIL %0s: obtido=%0d esperado=%0d", nm, got, exp);
            errors = errors + 1; end
        end
    endtask

    initial begin
        clr_bar = 0; li_bar = 1; bus_in = 8'hFF; @(negedge clk); #1;
        check("reset opcode", opcode, 0);
        check("reset operand", operand, 0);
        clr_bar = 1;

        // carrega ADD 12 = 0001_1100
        bus_in = 8'b0001_1100; li_bar = 0; @(posedge clk); #1;
        check("opcode=0001", opcode, 4'b0001);
        check("operand=1100", operand, 4'b1100);

        // segura com li_bar=1
        li_bar = 1; bus_in = 8'b1111_0000; @(posedge clk); #1;
        check("hold opcode", opcode, 4'b0001);
        check("hold operand", operand, 4'b1100);

        // carrega HLT 0 = 1111_0000
        bus_in = 8'b1111_0000; li_bar = 0; @(posedge clk); #1;
        check("opcode=1111", opcode, 4'b1111);
        check("operand=0000", operand, 4'b0000);

        if (errors == 0) $display("instruction_register: PASSOU");
        else             $display("instruction_register: FALHOU (%0d erros)", errors);
        $stop;
    end
endmodule
