`timescale 1ns/1ps
// Testa a ALU isoladamente: soma com carry-out descartado e subtracao negativa (compl. 2)
module tb_alu;
    reg su; reg [7:0] a, b; wire [7:0] r;
    adder_subtractor uut(.su(su), .acc(a), .breg(b), .result(r));
    integer fails = 0;
    task chk; input [7:0] exp; begin
        if (r!==exp) begin $display("FAIL: su=%b a=%0d b=%0d -> r=%0d (esp %0d)",su,a,b,r,exp); fails=fails+1; end
        else $display("ok: su=%b a=%0d b=%0d -> r=%0d (0x%h)",su,a,b,r,r);
    end endtask
    initial begin
        su=0; a=8'd16; b=8'd14; #1; chk(8'd30);     // soma normal
        su=1; a=8'd30; b=8'd4;  #1; chk(8'd26);     // sub normal
        su=1; a=8'd5;  b=8'd9;  #1; chk(8'hFC);     // 5-9 = -4 -> 0xFC (compl 2)
        su=0; a=8'd200;b=8'd100;#1; chk(8'd44);     // 300 mod 256 = 44 (wrap)
        su=0; a=8'd255;b=8'd1;  #1; chk(8'd0);      // wrap para 0
        if (fails==0) $display(">>> ALU: TODOS OS CASOS PASS <<<");
        else $display(">>> ALU: %0d FALHAS <<<", fails);
        $finish;
    end
endmodule
