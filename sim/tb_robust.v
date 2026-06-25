`timescale 1ns/1ps
// Testbench de robustez: valida (a) independencia da fase do reset
// e (b) unicidade de fonte no barramento W.
module tb_robust;
    reg clk, clr_bar;
    wire [7:0] out_port;
    wire hlt;
    integer bus_errors = 0;

    sap1_top dut(.clk(clk), .clr_bar(clr_bar), .out_port(out_port), .hlt(hlt));
    initial clk = 0; always #10 clk = ~clk;

    // ---- ponto 8: no maximo UMA fonte dirige o barramento por vez ----
    wire ram_drv = (dut.ce_bar == 1'b0);
    wire ir_drv  = (dut.ei_bar == 1'b0);
    wire [3:0] n_drivers = dut.ep + ram_drv + ir_drv + dut.ea + dut.eu;
    always @(*) begin
        if (clr_bar && n_drivers > 1) begin
            $display("ERRO BUS @t=%0t: %0d fontes simultaneas (Ep=%b CE=%b Ei=%b Ea=%b Eu=%b)",
                     $time, n_drivers, dut.ep, ram_drv, ir_drv, dut.ea, dut.eu);
            bus_errors = bus_errors + 1;
        end
    end

    task run_program;
        input release_high; // 1 = solta reset com clk alto, 0 = com clk baixo
        begin
            clr_bar = 0; #25;
            if (release_high) @(posedge clk); else @(negedge clk);
            clr_bar = 1;
            wait(hlt==1); repeat(3) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("tb_robust.vcd"); $dumpvars(0, tb_robust);

        // --- caso A: solta reset com clock BAIXO ---
        run_program(0);
        $display("Fase reset = clock BAIXO -> OUT=%0d (esperado 26) %s",
                 out_port, (out_port===8'd26)?"PASS":"FAIL");

        // --- caso B: solta reset com clock ALTO (o caso fragil antigo) ---
        run_program(1);
        $display("Fase reset = clock ALTO  -> OUT=%0d (esperado 26) %s",
                 out_port, (out_port===8'd26)?"PASS":"FAIL");

        if (bus_errors==0)
            $display(">>> BUS: nenhuma colisao de fontes (PASS) <<<");
        else
            $display(">>> BUS: %0d colisoes (FAIL) <<<", bus_errors);

        #20 $finish;
    end
endmodule
