# =============================================================
# run_one.do - Roda UM testbench (com ondas) no ModelSim.
#
# Uso (na pasta tb_model):  do run_one.do <nome>
#   ex: do run_one.do accumulator
#       do run_one.do controller_sequencer
#       do run_one.do sap1        (teste geral / integracao)
#
# Nomes (= nome do modulo, sem 'tb_'):
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
    vlog -quiet ../rtl/program_counter.v ../rtl/mar.v ../rtl/ram_16x8.v ../rtl/instruction_register.v \
        ../rtl/accumulator.v ../rtl/adder_subtractor.v ../rtl/register_b.v ../rtl/output_register.v \
        ../rtl/controller_sequencer.v ../rtl/sap1_top.v tb_sap1.v
    vsim -voptargs=+acc work.tb_sap1
} else {
    # teste unitario: o modulo (em rtl/ ou fpga/) + seu testbench
    if {[file exists ../rtl/${comp}.v]} { set dir rtl } else { set dir fpga }
    vlog -quiet ../${dir}/${comp}.v tb_${comp}.v
    vsim -voptargs=+acc work.tb_${comp}
}

add wave *
run -all
