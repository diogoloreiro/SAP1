# =============================================================
# run_sim.do  -  Script de simulacao do SAP-1 para o ModelSim
#
# Uso (dentro do ModelSim, na pasta do projeto):
#     do run_sim.do
#
# Ou pela linha de comando (modo batch, sem GUI):
#     vsim -c -do run_sim.do
#
# Compila o nucleo + testbench, abre a simulacao, adiciona as
# ondas principais e roda ate o $finish (HLT).
# =============================================================

# ---- biblioteca de trabalho limpa ----
if {[file exists work]} { vdel -all }
vlib work

# ---- compila os modulos do NUCLEO (sap1_top) ----
#  Obs.: usa controller_sequencer.v (o do projeto). Para testar a
#  versao FSM, troque pela linha comentada abaixo.
vlog -quiet program_counter.v
vlog -quiet mar.v
vlog -quiet ram_16x8.v
vlog -quiet instruction_register.v
vlog -quiet accumulator.v
vlog -quiet adder_subtractor.v
vlog -quiet register_b.v
vlog -quiet output_register.v
vlog -quiet controller_sequencer.v
# vlog -quiet controller_fsm.v        ;# <- alternativa (ajuste o nome no sap1_top)
vlog -quiet sap1_top.v

# ---- compila o testbench ----
vlog -quiet tb_sap1.v

# ---- abre a simulacao (+acc preserva sinais p/ debug/ondas) ----
vsim -voptargs=+acc work.tb_sap1

# ---- ondas ----
add wave -divider "Controle"
add wave -radix unsigned  sim:/tb_sap1/dut/u_pc/pc_out
add wave -radix binary    sim:/tb_sap1/tstate
add wave                  sim:/tb_sap1/hlt
add wave -divider "Datapath"
add wave -radix hex       sim:/tb_sap1/bus_w
add wave -radix unsigned  sim:/tb_sap1/dut/u_acc/acc_out
add wave -radix unsigned  sim:/tb_sap1/dut/u_b/b_out
add wave -radix unsigned  sim:/tb_sap1/dut/u_mar/addr_out
add wave -divider "Saida"
add wave -radix unsigned  sim:/tb_sap1/out_port
add wave                  sim:/tb_sap1/clk
add wave                  sim:/tb_sap1/clr_bar

# ---- roda ate o $finish do testbench ----
run -all

# ---- ajusta o zoom das ondas (se houver GUI) ----
catch {wave zoom full}
