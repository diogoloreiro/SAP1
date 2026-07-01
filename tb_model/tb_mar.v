// Testbench unitario - mar (registrador de endereco, 4 bits)
`timescale 1ns/1ps
module tb_mar;
    reg clk, clr_bar, lm_bar; reg [3:0] bus_in; wire [3:0] addr_out;
    integer errors = 0;

    mar dut (.clk(clk), .clr_bar(clr_bar), .lm_bar(lm_bar),
             .bus_in(bus_in), .addr_out(addr_out));

    initial clk = 0; always #5 clk = ~clk;

    task check(input [255:0] nm, input [31:0] got, input [31:0] exp);
        begin if (got !== exp) begin
            $display("  FAIL %0s: obtido=%0d esperado=%0d", nm, got, exp);
            errors = errors + 1; end
        end
    endtask

    initial begin
        clr_bar = 0; lm_bar = 1; bus_in = 4'hA; @(negedge clk); #1;
        check("reset -> 0", addr_out, 0);
        clr_bar = 1;

        // lm_bar=0 carrega
        bus_in = 4'd12; lm_bar = 0; @(posedge clk); #1;
        check("load 12", addr_out, 12);

        // lm_bar=1 segura mesmo mudando o barramento
        lm_bar = 1; bus_in = 4'd5; @(posedge clk); #1;
        check("hold (lm_bar=1)", addr_out, 12);

        // novo load
        bus_in = 4'd7; lm_bar = 0; @(posedge clk); #1;
        check("load 7", addr_out, 7);

        if (errors == 0) $display("mar: PASSOU");
        else             $display("mar: FALHOU (%0d erros)", errors);
        $stop;
    end
endmodule
