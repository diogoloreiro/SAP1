# =============================================================
# wave_acc.do - Ondas do Acumulador (tb_accumulator)
# Uso (na pasta tb_model):  do wave_acc.do
# Mostra o padrao de registrador: carrega bus_in quando la_bar=0
# (na subida do clock), senao mantem; reset zera.
# =============================================================
if {[file exists work]} { vdel -all }
vlib work
vlog -quiet ../rtl/accumulator.v tb_accumulator.v
vsim -voptargs=+acc work.tb_accumulator

delete wave *
configure wave -namecolwidth 200
configure wave -valuecolwidth 90
configure wave -signalnamewidth 1

set TOP /tb_accumulator
add wave -divider "RELOGIO / RESET"
add wave -color {Yellow}  $TOP/clk
add wave                  $TOP/clr_bar
add wave -divider "CARGA (ativo-baixo: 0 = carrega)"
add wave -color {Cyan}    $TOP/la_bar
add wave -divider "ENTRADA / SAIDA (decimal)"
add wave -radix unsigned  $TOP/bus_in
add wave -radix unsigned -color {Green}  $TOP/acc_out

run -all
wave zoom full
view wave
