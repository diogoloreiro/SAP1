# =============================================================
# wave_mar.do - Ondas do MAR (tb_mar)
# Uso (na pasta tb_model):  do wave_mar.do
# Registrador de endereco (4 bits): carrega bus_in quando lm_bar=0
# na subida do clock; senao mantem; reset zera.
# =============================================================
if {[file exists work]} { vdel -all }
vlib work
vlog -quiet ../rtl/mar.v tb_mar.v
vsim -voptargs=+acc work.tb_mar

delete wave *
configure wave -namecolwidth 200
configure wave -valuecolwidth 90
configure wave -signalnamewidth 1

set TOP /tb_mar
add wave -divider "RELOGIO / RESET"
add wave -color {Yellow}  $TOP/clk
add wave                  $TOP/clr_bar
add wave -divider "CARGA (ativo-baixo: 0 = carrega)"
add wave -color {Cyan}    $TOP/lm_bar
add wave -divider "ENDERECO (entrada / saida, decimal)"
add wave -radix unsigned  $TOP/bus_in
add wave -radix unsigned -color {Green}  $TOP/addr_out

run -all
wave zoom full
view wave
