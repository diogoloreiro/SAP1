# =============================================================
# run_all_tb.do - Roda todos os testbenches no ModelSim.
# Uso (no ModelSim, na pasta do projeto):  do run_all_tb.do
# Ou em batch:                             vsim -c -do run_all_tb.do
# =============================================================
if {[file exists work]} { vdel -all }
vlib work

# compila tudo (modulos de projeto + testbenches)
vlog -quiet *.v

# lista de testbenches a executar
set tbs {
    tb_program_counter
    tb_mar
    tb_instruction_register
    tb_accumulator
    tb_register_b
    tb_output_register
    tb_adder_subtractor
    tb_seg7
    tb_seg7_instr
    tb_ram_16x8
    tb_controller_sequencer
    tb_clock_divider
    tb_debouncer
    tb_sap1
}

foreach tb $tbs {
    echo "================ $tb ================"
    vsim -quiet -c work.$tb
    run -all
    quit -sim
}
echo "================ FIM DOS TESTES ================"
