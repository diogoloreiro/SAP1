// =============================================================
// sap1_top.v  -  Processador SAP-1 completo (top-level)
//
// Conecta todos os modulos atraves do barramento W de 8 bits.
//
// O barramento W e' implementado como um MULTIPLEXADOR (e nao com
// tri-state interno), pois a maioria dos FPGAs nao possui buffers
// tri-state internos. Apenas um "enable" fica ativo por vez, mas a
// prioridade do mux evita estados indefinidos (X) na simulacao.
//
// Entradas/saidas do topo:
//   clk     : clock principal
//   clr_bar : reset assincrono geral [ativo baixo]  (~CLR)
//   out_port: 8 LEDs do visor binario
//   hlt     : indica que o processador parou (HLT)
// =============================================================
module sap1_top (
    input  wire       clk,
    input  wire       clr_bar,
    output wire [7:0] out_port,
    output wire       hlt
);
    // ---- barramento W ----
    wire [7:0] w_bus;

    // ---- sinais de controle (palavra CON) ----
    wire cp, ep, lm_bar, ce_bar, li_bar, ei_bar;
    wire la_bar, ea, su, eu, lb_bar, lo_bar;
    wire [11:0] con;
    wire [5:0]  ring;

    // ---- interconexoes ----
    wire [3:0] pc_out;
    wire [3:0] mar_addr;
    wire [7:0] ram_data;
    wire [3:0] ir_opcode;
    wire [3:0] ir_operand;
    wire [7:0] acc_out;
    wire [7:0] b_out;
    wire [7:0] alu_out;

    // ---- clock unico, livre de gating ----
    // O HLT NAO para mais o clock por logica combinacional. O
    // congelamento e' feito por clock-enable dentro do controlador
    // (o contador de anel para de avancar). Como a palavra de controle
    // vira IDLE quando halted, nenhum registrador carrega -> todos
    // seguram seus valores naturalmente. Isso evita gating de clock,
    // que e' uma ma pratica em FPGA (glitches no clock).
    wire clk_cpu = clk;

    // -------------------------------------------------------
    // MULTIPLEXADOR DO BARRAMENTO W
    //   Ep        -> PC (4 bits, estendido com zeros)
    //   ~CE ativo -> RAM (8 bits)
    //   ~Ei ativo -> operando do IR (4 bits, estendido)
    //   Ea        -> acumulador (8 bits)
    //   Eu        -> saida da ALU (8 bits)
    // -------------------------------------------------------
    assign w_bus = ep             ? {4'b0000, pc_out}      :
                   (ce_bar==1'b0) ? ram_data               :
                   (ei_bar==1'b0) ? {4'b0000, ir_operand}  :
                   ea             ? acc_out                :
                   eu             ? alu_out                :
                                    8'b0000_0000;

    // -------------------------------------------------------
    // INSTANCIAS
    // -------------------------------------------------------
    program_counter u_pc (
        .clk     (clk_cpu),
        .clr_bar (clr_bar),
        .cp      (cp),
        .pc_out  (pc_out)
    );

    mar u_mar (
        .clk     (clk_cpu),
        .clr_bar (clr_bar),
        .lm_bar  (lm_bar),
        .bus_in  (w_bus[3:0]),
        .addr_out(mar_addr)
    );

    ram_16x8 u_ram (
        .addr     (mar_addr),
        .data_out (ram_data)
    );

    instruction_register u_ir (
        .clk     (clk_cpu),
        .clr_bar (clr_bar),
        .li_bar  (li_bar),
        .bus_in  (w_bus),
        .opcode  (ir_opcode),
        .operand (ir_operand)
    );

    accumulator u_acc (
        .clk     (clk_cpu),
        .clr_bar (clr_bar),
        .la_bar  (la_bar),
        .bus_in  (w_bus),
        .acc_out (acc_out)
    );

    adder_subtractor u_alu (
        .su     (su),
        .acc    (acc_out),
        .breg   (b_out),
        .result (alu_out)
    );

    register_b u_b (
        .clk     (clk_cpu),
        .clr_bar (clr_bar),
        .lb_bar  (lb_bar),
        .bus_in  (w_bus),
        .b_out   (b_out)
    );

    output_register u_out (
        .clk     (clk_cpu),
        .clr_bar (clr_bar),
        .lo_bar  (lo_bar),
        .bus_in  (w_bus),
        .out_port(out_port)
    );

    controller_sequencer u_ctrl (
        .clk     (clk_cpu),
        .clr_bar (clr_bar),
        .opcode  (ir_opcode),
        .cp      (cp),
        .ep      (ep),
        .lm_bar  (lm_bar),
        .ce_bar  (ce_bar),
        .li_bar  (li_bar),
        .ei_bar  (ei_bar),
        .la_bar  (la_bar),
        .ea      (ea),
        .su      (su),
        .eu      (eu),
        .lb_bar  (lb_bar),
        .lo_bar  (lo_bar),
        .con     (con),
        .ring    (ring),
        .hlt     (hlt)
    );
endmodule
