# =============================================================
# wave_regb.do - Ondas do Registrador B (tb_register_b)
# Uso (na pasta tb_model):  do wave_regb.do
# Guarda o segundo operando da ULA: carrega bus_in quando lb_bar=0
# na subida do clock; senao mantem; reset zera.
# =============================================================
if {[file exists work]} { vdel -all }
vlib work
vlog -quiet ../rtl/register_b.v tb_register_b.v
vsim -voptargs=+acc work.tb_register_b

delete wave *
configure wave -namecolwidth 200
configure wave -valuecolwidth 90
configure wave -signalnamewidth 1

set TOP /tb_register_b
add wave -divider "RELOGIO / RESET"
add wave -color {Yellow}  $TOP/clk
add wave                  $TOP/clr_bar
add wave -divider "CARGA (ativo-baixo: 0 = carrega)"
add wave -color {Cyan}    $TOP/lb_bar
add wave -divider "ENTRADA / SAIDA (decimal)"
add wave -radix unsigned  $TOP/bus_in
add wave -radix unsigned -color {Green}  $TOP/b_out

run -all
wave zoom full
view wave
