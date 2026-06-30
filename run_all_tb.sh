#!/bin/bash
# =============================================================
# run_all_tb.sh - Roda todos os testbenches (unitarios + geral)
#                 usando Icarus Verilog. Resumo PASSOU/FALHOU.
# Uso:  bash run_all_tb.sh
# =============================================================
cd "$(dirname "$0")"
TMP=$(mktemp -d)
results=""

run() {              # $1 = arquivo tb ; $2... = arquivos de projeto
  local tb=$1; shift
  local name; name=$(basename "$tb" .v)
  if iverilog -o "$TMP/sim" "$tb" "$@" 2>"$TMP/err"; then
      local out; out=$(vvp "$TMP/sim" 2>/dev/null | grep -vE "VCD|dump")
      echo "$out"
      if echo "$out" | grep -qE "FALHOU|FAIL|NAO PAROU"; then
          results+="  [FALHOU] $name"$'\n'
      else
          results+="  [ok]     $name"$'\n'
      fi
  else
      echo "$name: ERRO DE COMPILACAO"; cat "$TMP/err"
      results+="  [ERRO]   $name"$'\n'
  fi
}

CORE="program_counter.v mar.v ram_16x8.v instruction_register.v accumulator.v \
adder_subtractor.v register_b.v output_register.v controller_sequencer.v sap1_top.v"

echo "================ TESTES UNITARIOS ================"
run tb_program_counter.v      program_counter.v
run tb_mar.v                  mar.v
run tb_instruction_register.v instruction_register.v
run tb_accumulator.v          accumulator.v
run tb_register_b.v           register_b.v
run tb_output_register.v      output_register.v
run tb_adder_subtractor.v     adder_subtractor.v
run tb_seg7.v                 seg7.v
run tb_seg7_instr.v           seg7_instr.v
run tb_ram_16x8.v             ram_16x8.v
run tb_controller_sequencer.v controller_sequencer.v
run tb_clock_divider.v        clock_divider.v
run tb_debouncer.v            debouncer.v

echo ""
echo "================ TESTE GERAL (integracao) ================"
run tb_sap1.v $CORE

echo ""
echo "==================== RESUMO ===================="
echo -n "$results"
rm -rf "$TMP"
