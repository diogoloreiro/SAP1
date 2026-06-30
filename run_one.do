# =============================================================
# run_one.do - Roda UM testbench (com ondas) no ModelSim.
#
# Uso:  do run_one.do <nome>
#   ex: do run_one.do accumulator
#       do run_one.do controller_sequencer
#       do run_one.do seg7
#       do run_one.do sap1        (teste geral / integracao)
#
# Nomes disponiveis (= nome do modulo, sem 'tb_'):
#   program_counter  mar  instruction_register  accumulator
#   register_b  output_register  adder_subtractor  seg7
#   seg7_instr  ram_16x8  controller_sequencer  clock_divider
#   debouncer  sap1
# =============================================================
if {[file exists work]} { vdel -all }
vlib work

quietly set comp $1

if {$comp eq "sap1"} {
    # teste geral: precisa do nucleo inteiro
    vlog -quiet program_counter.v mar.v ram_16x8.v instruction_register.v \
        accumulator.v adder_subtractor.v register_b.v output_register.v \
        controller_sequencer.v sap1_top.v tb_sap1.v
    vsim -voptargs=+acc work.tb_sap1
} else {
    # teste unitario: o modulo + seu testbench
    vlog -quiet ${comp}.v tb_${comp}.v
    vsim -voptargs=+acc work.tb_${comp}
}

add wave *
run -all
