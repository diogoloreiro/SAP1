# =============================================================
# run_modelsim.do  -  SAP-1: compila, carrega e simula no ModelSim
#
# COMO USAR:
#   1. Abra o ModelSim/Questa.
#   2. No Transcript, va ate a pasta sim/:   cd .../sap1/sim
#   3. Rode:                                  do run_modelsim.do
#
# Compila o nucleo RTL (../rtl) + o testbench principal (tb_sap1),
# abre a janela Wave com os sinais agrupados e executa tudo.
# =============================================================

# ---- limpa estado anterior (seguro mesmo se nao houver) ----
catch {quit -sim}
catch {vdel -all}
vlib work

# ---- compila o nucleo RTL ----
set RTL { \
  ../rtl/program_counter.v ../rtl/mar.v ../rtl/ram_16x8.v \
  ../rtl/instruction_register.v ../rtl/accumulator.v ../rtl/adder_subtractor.v \
  ../rtl/register_b.v ../rtl/output_register.v ../rtl/controller_sequencer.v \
  ../rtl/sap1_top.v }
eval vlog -quiet $RTL

# ---- compila o testbench ----
vlog -quiet tb_sap1.v

# ---- carrega a simulacao (com acesso aos sinais internos) ----
vsim -voptargs=+acc work.tb_sap1

# ---- forma de onda agrupada e formatada ----
configure wave -namecolwidth 200
configure wave -valuecolwidth 90

add wave -divider "Clock e Reset"
add wave -label "clk"   /tb_sap1/clk
add wave -label "~CLR"  /tb_sap1/clr_bar

add wave -divider "Controle (FSM)"
add wave -label "estado T (one-hot)" -radix binary       /tb_sap1/dut/ring
add wave -label "palavra CON (12b)"  -radix binary       /tb_sap1/dut/con
add wave -label "HLT"                                    /tb_sap1/dut/hlt

add wave -divider "Barramento W"
add wave -label "W bus" -radix hexadecimal /tb_sap1/dut/w_bus

add wave -divider "Memoria"
add wave -label "MAR"      -radix unsigned     /tb_sap1/dut/mar_addr
add wave -label "RAM out"  -radix hexadecimal  /tb_sap1/dut/ram_data

add wave -divider "Registradores"
add wave -label "PC"        -radix unsigned     /tb_sap1/dut/pc_out
add wave -label "opcode"    -radix hexadecimal  /tb_sap1/dut/ir_opcode
add wave -label "operando"  -radix hexadecimal  /tb_sap1/dut/ir_operand
add wave -label "A (acum.)" -radix hexadecimal  /tb_sap1/dut/acc_out
add wave -label "B"         -radix hexadecimal  /tb_sap1/dut/b_out
add wave -label "ALU"       -radix hexadecimal  /tb_sap1/dut/alu_out
add wave -label "OUT (saida)" -radix hexadecimal /tb_sap1/dut/out_port

# ---- executa tudo e ajusta o zoom ----
run -all
wave zoom full

echo "============================================================"
echo " Simulacao concluida. Veja o resultado (PASS/FAIL) acima e"
echo " a forma de onda na janela Wave. Dica: siga uma instrucao"
echo " olhando 'estado T', 'palavra CON' e 'W bus' lado a lado."
echo "============================================================"
