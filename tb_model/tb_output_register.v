// Testbench unitario - output_register (registrador de saida, 8 bits, ~Lo ativo baixo)
`timescale 1ns/1ps
module tb_output_register;
    reg clk, clr_bar, lo_bar; reg [7:0] bus_in; wire [7:0] out_port;
    integer errors = 0;

    output_register dut (.clk(clk), .clr_bar(clr_bar), .lo_bar(lo_bar),
                         .bus_in(bus_in), .out_port(out_port));

    initial clk = 0; always #5 clk = ~clk;

    task check(input [255:0] nm, input [31:0] got, input [31:0] exp);
        begin if (got !== exp) begin
            $display("  FAIL %0s: obtido=%0d esperado=%0d", nm, got, exp);
            errors = errors + 1; end
        end
    endtask

    initial begin
        clr_bar = 0; lo_bar = 1; bus_in = 8'hF0; @(negedge clk); #1;
        check("reset -> 0", out_port, 0); clr_bar = 1;

        // simula a instrucao OUT: carrega o valor do acumulador
        bus_in = 8'd27; lo_bar = 0; @(posedge clk); #1;
        check("OUT carrega 27", out_port, 27);

        // entre dois OUTs o valor fica congelado
        lo_bar = 1; bus_in = 8'd5; @(posedge clk); #1;
        check("congela entre OUTs", out_port, 27);

        bus_in = 8'd9; lo_bar = 0; @(posedge clk); #1;
        check("novo OUT = 9", out_port, 9);

        if (errors == 0) $display("output_register: PASSOU");
        else             $display("output_register: FALHOU (%0d erros)", errors);
        $stop;
    end
endmodule
