# =============================================================
# wave_sap1.do - Ondas DIDATICAS da simulacao completa (tb_sap1)
# Uso (na pasta tb_model):  do wave_sap1.do
#
# Mostra o estado como T1..T6, o opcode como mnemonico e os
# registradores (PC, MAR, A, B, ALU, resultado) em DECIMAL.
# =============================================================
if {[file exists work]} { vdel -all }
vlib work
vlog -quiet ../rtl/program_counter.v ../rtl/mar.v ../rtl/ram_16x8.v ../rtl/instruction_register.v \
    ../rtl/accumulator.v ../rtl/adder_subtractor.v ../rtl/register_b.v ../rtl/output_register.v \
    ../rtl/controller_sequencer.v ../rtl/sap1_top.v tb_sap1.v
vsim -voptargs=+acc work.tb_sap1

# ---- radix: estado do anel (one-hot -> nome) ----
radix define ESTADO {
    6'b000000 "IDLE",
    6'b000001 "T1",
    6'b000010 "T2",
    6'b000100 "T3",
    6'b001000 "T4",
    6'b010000 "T5",
    6'b100000 "T6",
    -default binary
}

# ---- radix: opcode -> mnemonico ----
radix define OPCODE {
    4'b0000 "LDA",
    4'b0001 "ADD",
    4'b0010 "SUB",
    4'b1110 "OUT",
    4'b1111 "HLT",
    -default hex
}

delete wave *
configure wave -namecolwidth 210
configure wave -valuecolwidth 90
configure wave -signalnamewidth 1

set TB  /tb_sap1
set DUT /tb_sap1/dut

add wave -divider "RELOGIO / RESET"
add wave -color {Yellow}  $TB/clk
add wave                  $TB/clr_bar

add wave -divider "CONTROLE"
add wave -radix ESTADO -color {Magenta}  $TB/tstate
add wave -radix OPCODE -color {Cyan}     $DUT/opcode
add wave -color {Orange}                 $TB/hlt

add wave -divider "DATAPATH (em decimal)"
add wave -radix unsigned  $DUT/u_pc/pc_out
add wave -radix unsigned  $DUT/u_mar/addr_out
add wave -radix unsigned -color {Green}  $DUT/u_acc/acc_out
add wave -radix unsigned  $DUT/u_b/b_out
add wave -radix unsigned  $DUT/u_alu/result
add wave -radix hex       $TB/bus_w

add wave -divider "SAIDA (resultado)"
add wave -radix unsigned -color {Orange}  $TB/out_port

run -all
wave zoom full
