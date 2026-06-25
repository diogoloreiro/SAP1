# =============================================================
# run_all_tests.do  -  SAP-1: roda os 4 testbenches em sequencia
#
# COMO USAR (no ModelSim, dentro de sim/):  do run_all_tests.do
#
# Compila tudo e executa cada testbench imprimindo PASS/FAIL no
# Transcript. Use para verificacao rapida (sem abrir a Wave).
# =============================================================

catch {quit -sim}
catch {vdel -all}
vlib work

# nucleo RTL
set RTL { \
  ../rtl/program_counter.v ../rtl/mar.v ../rtl/ram_16x8.v \
  ../rtl/instruction_register.v ../rtl/accumulator.v ../rtl/adder_subtractor.v \
  ../rtl/register_b.v ../rtl/output_register.v ../rtl/controller_sequencer.v \
  ../rtl/sap1_top.v }
eval vlog -quiet $RTL

# wrapper de FPGA (necessario para o tb_fpga)
eval vlog -quiet ../fpga/clock_divider.v ../fpga/debouncer.v ../fpga/seg7.v ../fpga/sap1_fpga.v

# testbenches
eval vlog -quiet tb_sap1.v tb_robust.v tb_alu.v tb_fpga.v

proc roda {top titulo} {
    echo "============================================================"
    echo "  $titulo  ($top)"
    echo "============================================================"
    vsim -quiet work.$top
    run -all
    quit -sim
}

roda tb_sap1   "Programa completo (LDA/ADD/SUB/OUT/HLT)"
roda tb_alu    "ALU isolada (complemento de 2, wrap-around)"
roda tb_robust "Fase do reset + unicidade do barramento"
roda tb_fpga   "Cadeia de FPGA (divisor + reset + display)"

echo "============================================================"
echo " Fim. Confira os PASS de cada testbench acima."
echo "============================================================"
