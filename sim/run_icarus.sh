#!/usr/bin/env bash
# =============================================================
# run_icarus.sh  -  SAP-1: compila e roda os testbenches no Icarus
#
# COMO USAR (dentro de sim/):   bash run_icarus.sh
#
# Alternativa ao ModelSim para validacao rapida na linha de comando.
# Requer: iverilog e vvp (Icarus Verilog).
# =============================================================
set -e
cd "$(dirname "$0")"

RTL="../rtl/program_counter.v ../rtl/mar.v ../rtl/ram_16x8.v \
../rtl/instruction_register.v ../rtl/accumulator.v ../rtl/adder_subtractor.v \
../rtl/register_b.v ../rtl/output_register.v ../rtl/controller_sequencer.v \
../rtl/sap1_top.v"
FPGA="../fpga/clock_divider.v ../fpga/debouncer.v ../fpga/seg7.v ../fpga/sap1_fpga.v"

echo "=================================================="
echo "  tb_sap1 - programa completo"
echo "=================================================="
iverilog -g2012 -o /tmp/sap1_tb $RTL tb_sap1.v && vvp /tmp/sap1_tb | grep -E "RESULTADO|Saida"

echo "=================================================="
echo "  tb_alu - ALU isolada"
echo "=================================================="
iverilog -g2012 -o /tmp/alu_tb ../rtl/adder_subtractor.v tb_alu.v && vvp /tmp/alu_tb | grep -E "ALU:"

echo "=================================================="
echo "  tb_robust - fase do reset + barramento"
echo "=================================================="
iverilog -g2012 -o /tmp/rob_tb $RTL tb_robust.v && vvp /tmp/rob_tb | grep -E "Fase|BUS"

echo "=================================================="
echo "  tb_fpga - cadeia de FPGA (DE10-Lite)"
echo "=================================================="
iverilog -g2012 -o /tmp/fpga_tb $RTL $FPGA tb_fpga.v && vvp /tmp/fpga_tb | grep -E "WRAPPER"

echo "=================================================="
echo "  Para gerar ondas (GTKWave):"
echo "  iverilog -g2012 -o /tmp/s \$RTL tb_sap1.v && vvp /tmp/s && gtkwave tb_sap1.vcd"
echo "=================================================="
