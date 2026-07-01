# =============================================================
# run_all_tb.do - Roda TODOS os testbenches no ModelSim.
# Uso (na pasta tb_model):  do run_all_tb.do
#   (ou em batch:  vsim -c -do run_all_tb.do)
#
# Os modulos de projeto estao na pasta acima (../); os testbenches
# estao nesta pasta.
# =============================================================
if {[file exists work]} { vdel -all }
vlib work

# ---- modulos do projeto (pasta acima) ----
vlog -quiet ../program_counter.v ../mar.v ../ram_16x8.v ../instruction_register.v \
    ../accumulator.v ../adder_subtractor.v ../register_b.v ../output_register.v \
    ../controller_sequencer.v ../sap1_top.v ../seg7.v ../seg7_instr.v \
    ../clock_divider.v ../debouncer.v

# ---- testbenches (esta pasta) ----
vlog -quiet tb_program_counter.v tb_mar.v tb_instruction_register.v tb_accumulator.v \
    tb_register_b.v tb_output_register.v tb_adder_subtractor.v tb_seg7.v tb_seg7_instr.v \
    tb_ram_16x8.v tb_controller_sequencer.v tb_clock_divider.v tb_debouncer.v tb_sap1.v

set tbs {
    tb_program_counter  tb_mar  tb_instruction_register  tb_accumulator
    tb_register_b  tb_output_register  tb_adder_subtractor  tb_seg7
    tb_seg7_instr  tb_ram_16x8  tb_controller_sequencer  tb_clock_divider
    tb_debouncer  tb_sap1
}

foreach tb $tbs {
    echo "================ $tb ================"
    vsim -quiet -c work.$tb
    run -all
    quit -sim
}
echo "================ FIM DOS TESTES ================"
