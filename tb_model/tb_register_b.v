// Testbench unitario - register_b (registrador B, 8 bits, ~Lb ativo baixo)
`timescale 1ns/1ps
module tb_register_b;
    reg clk, clr_bar, lb_bar; reg [7:0] bus_in; wire [7:0] b_out;
    integer errors = 0;

    register_b dut (.clk(clk), .clr_bar(clr_bar), .lb_bar(lb_bar),
                    .bus_in(bus_in), .b_out(b_out));

    initial clk = 0; always #5 clk = ~clk;

    task check(input [255:0] nm, input [31:0] got, input [31:0] exp);
        begin if (got !== exp) begin
            $display("  FAIL %0s: obtido=%0d esperado=%0d", nm, got, exp);
            errors = errors + 1; end
        end
    endtask

    initial begin
        clr_bar = 0; lb_bar = 1; bus_in = 8'h55; @(negedge clk); #1;
        check("reset -> 0", b_out, 0); clr_bar = 1;

        bus_in = 8'd9; lb_bar = 0; @(posedge clk); #1;
        check("load 9", b_out, 9);

        lb_bar = 1; bus_in = 8'd200; @(posedge clk); #1;
        check("hold", b_out, 9);

        bus_in = 8'd3; lb_bar = 0; @(posedge clk); #1;
        check("load 3", b_out, 3);

        if (errors == 0) $display("register_b: PASSOU");
        else             $display("register_b: FALHOU (%0d erros)", errors);
        $stop;
    end
endmodule
