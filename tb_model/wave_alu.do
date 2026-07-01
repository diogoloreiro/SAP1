# =============================================================
# wave_alu.do - Ondas da ULA / somador-subtrator (tb_adder_subtractor)
# Uso (na pasta tb_model):  do wave_alu.do
# Combinacional: result = acc + breg (su=0) ou acc - breg (su=1),
# em 8 bits (da a volta em 256). Sem clock.
# =============================================================
if {[file exists work]} { vdel -all }
vlib work
vlog -quiet ../rtl/adder_subtractor.v tb_adder_subtractor.v
vsim -voptargs=+acc work.tb_adder_subtractor

delete wave *
configure wave -namecolwidth 200
configure wave -valuecolwidth 90
configure wave -signalnamewidth 1

set TOP /tb_adder_subtractor
add wave -divider "MODO (0 = soma, 1 = subtrai)"
add wave -color {Cyan}    $TOP/su
add wave -divider "OPERANDOS (decimal)"
add wave -radix unsigned  $TOP/acc
add wave -radix unsigned  $TOP/breg
add wave -divider "RESULTADO (decimal)"
add wave -radix unsigned -color {Green}  $TOP/result

run -all
wave zoom full
view wave
