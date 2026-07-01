// Testbench unitario - controller_sequencer
// Verifica: (1) reset -> IDLE; (2) sequencia do anel T1..T6 na descida;
// (3) palavras de controle da busca e da execucao do LDA;
// (4) HLT congela em T4.
`timescale 1ns/1ps
module tb_controller_sequencer;
    reg clk, clr_bar; reg [3:0] opcode;
    wire cp, ep, lm_bar, ce_bar, li_bar, ei_bar, la_bar, ea, su, eu, lb_bar, lo_bar;
    wire [11:0] con; wire [5:0] ring; wire hlt;
    integer errors = 0;

    localparam LDA = 4'b0000, HLT = 4'b1111;
    localparam IDLE = 12'b0011_1110_0011;
    localparam [5:0] T1=6'b000001,T2=6'b000010,T3=6'b000100,
                     T4=6'b001000,T5=6'b010000,T6=6'b100000;

    controller_sequencer dut (.clk(clk), .clr_bar(clr_bar), .opcode(opcode),
        .cp(cp),.ep(ep),.lm_bar(lm_bar),.ce_bar(ce_bar),.li_bar(li_bar),
        .ei_bar(ei_bar),.la_bar(la_bar),.ea(ea),.su(su),.eu(eu),
        .lb_bar(lb_bar),.lo_bar(lo_bar),.con(con),.ring(ring),.hlt(hlt));

    initial clk = 0; always #5 clk = ~clk;

    task check(input [255:0] nm, input [31:0] got, input [31:0] exp);
        begin if (got !== exp) begin
            $display("  FAIL %0s: obtido=%b esperado=%b", nm, got, exp);
            errors = errors + 1; end
        end
    endtask

    initial begin
        // ---- (1) reset -> IDLE ----
        opcode = LDA; clr_bar = 0; @(negedge clk); #1;
        check("reset ring=IDLE", ring, 6'b000000);
        check("reset con=IDLE", con, IDLE);
        check("reset hlt=0", hlt, 0);
        clr_bar = 1;

        // ---- (2)+(3) sequencia e palavras de controle (LDA) ----
        @(negedge clk); #1; check("T1 ring", ring, T1); check("T1 con", con, 12'b0101_1110_0011);
        check("T1 ep=1", ep, 1); check("T1 lm_bar=0", lm_bar, 0);
        @(negedge clk); #1; check("T2 ring", ring, T2); check("T2 con", con, 12'b1011_1110_0011);
        check("T2 cp=1", cp, 1);
        @(negedge clk); #1; check("T3 ring", ring, T3); check("T3 con", con, 12'b0010_0110_0011);
        check("T3 ce_bar=0", ce_bar, 0); check("T3 li_bar=0", li_bar, 0);
        @(negedge clk); #1; check("T4 ring", ring, T4); check("T4 con(LDA)", con, 12'b0001_1010_0011);
        @(negedge clk); #1; check("T5 ring", ring, T5); check("T5 con(LDA)", con, 12'b0010_1100_0011);
        @(negedge clk); #1; check("T6 ring", ring, T6); check("T6 con(LDA=idle)", con, IDLE);
        @(negedge clk); #1; check("volta a T1", ring, T1);
        check("hlt continua 0", hlt, 0);

        // ---- (4) HLT congela em T4 ----
        opcode = HLT; clr_bar = 0; @(negedge clk); #1; clr_bar = 1;
        @(negedge clk);             // T1
        @(negedge clk);             // T2
        @(negedge clk);             // T3
        @(negedge clk); #1;         // T4
        check("HLT chega em T4", ring, T4);
        @(posedge clk); #1;         // halted trava em T4
        check("HLT hlt=1", hlt, 1);
        @(negedge clk); #1; check("HLT congela em T4", ring, T4);
        @(negedge clk); #1; check("HLT continua em T4", ring, T4);

        if (errors == 0) $display("controller_sequencer: PASSOU");
        else             $display("controller_sequencer: FALHOU (%0d erros)", errors);
        $stop;
    end
endmodule
