# =============================================================
# wave_pc.do - Ondas do Program Counter (tb_program_counter)
# Uso (na pasta tb_model):  do wave_pc.do
# Mostra o contador incrementando (cp=1) e o reset (clr_bar=0).
# =============================================================
if {[file exists work]} { vdel -all }
vlib work
vlog -quiet ../rtl/program_counter.v tb_program_counter.v
vsim -voptargs=+acc work.tb_program_counter

delete wave *
configure wave -namecolwidth 200
configure wave -valuecolwidth 90
configure wave -signalnamewidth 1

set TOP /tb_program_counter
add wave -divider "RELOGIO / RESET"
add wave -color {Yellow}  $TOP/clk
add wave                  $TOP/clr_bar
add wave -divider "HABILITA CONTAGEM"
add wave -color {Cyan}    $TOP/cp
add wave -divider "SAIDA (endereco, decimal)"
add wave -radix unsigned -color {Green}  $TOP/pc_out

run -all
wave zoom full
