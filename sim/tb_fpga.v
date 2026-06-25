`timescale 1ns/1ps
// Testbench do wrapper DE10-Lite (DIV pequeno para acelerar)
module tb_fpga;
    reg MAX10_CLK1_50;
    reg [1:0] KEY;
    reg [0:0] SW;
    wire [9:0] LEDR;
    wire [7:0] HEX0, HEX1;

    sap1_fpga #(.DIV(4)) dut(.MAX10_CLK1_50(MAX10_CLK1_50), .KEY(KEY), .SW(SW),
                  .LEDR(LEDR), .HEX0(HEX0), .HEX1(HEX1));

    initial MAX10_CLK1_50 = 0; always #5 MAX10_CLK1_50 = ~MAX10_CLK1_50;

    initial begin
        $dumpfile("tb_fpga.vcd"); $dumpvars(0, tb_fpga);
        SW = 1'b0; KEY = 2'b11;
        KEY[0] = 1'b0; #50; KEY[0] = 1'b1;
        fork: w
          begin wait(LEDR[9]==1'b1); repeat(20) @(posedge MAX10_CLK1_50); disable w; end
          begin #500000; $display("TIMEOUT"); disable w; end
        join
        $display("LEDR[7:0] = %b (0x%h = %0d)", LEDR[7:0], LEDR[7:0], LEDR[7:0]);
        $display("HLT (LEDR[9]) = %b", LEDR[9]);
        $display("HEX1=%b HEX0=%b", HEX1, HEX0);
        // 0x1A: seg '1'=7'b1111001, 'A'=7'b0001000, DP=1
        if (LEDR[7:0]===8'h1A && LEDR[9]===1'b1 &&
            HEX1===8'b1_1111001 && HEX0===8'b1_0001000)
            $display(">>> FPGA WRAPPER (DE10-Lite): PASS (saida 0x1A, displays 1 e A) <<<");
        else
            $display(">>> FPGA WRAPPER (DE10-Lite): FAIL <<<");
        #20 $finish;
    end
endmodule
