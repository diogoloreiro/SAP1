// Testbench unitario - accumulator (registrador A, 8 bits, ~La ativo baixo)
`timescale 1ns/1ps
module tb_accumulator;
    reg clk, clr_bar, la_bar; reg [7:0] bus_in; wire [7:0] acc_out;
    integer errors = 0;

    accumulator dut (.clk(clk), .clr_bar(clr_bar), .la_bar(la_bar),
                     .bus_in(bus_in), .acc_out(acc_out));

    initial clk = 0; always #5 clk = ~clk;

    task check(input [255:0] nm, input [31:0] got, input [31:0] exp);
        begin if (got !== exp) begin
            $display("  FAIL %0s: obtido=%0d esperado=%0d", nm, got, exp);
            errors = errors + 1; end
        end
    endtask

    initial begin
        clr_bar = 0; la_bar = 1; bus_in = 8'hAA; @(negedge clk); #1;
        check("reset -> 0", acc_out, 0); clr_bar = 1;

        bus_in = 8'd27; la_bar = 0; @(posedge clk); #1;
        check("load 27", acc_out, 27);

        la_bar = 1; bus_in = 8'd99; @(posedge clk); #1;
        check("hold", acc_out, 27);

        bus_in = 8'd0; la_bar = 0; @(posedge clk); #1;
        check("load 0", acc_out, 0);

        if (errors == 0) $display("accumulator: PASSOU");
        else             $display("accumulator: FALHOU (%0d erros)", errors);
        $stop;
    end
endmodule
