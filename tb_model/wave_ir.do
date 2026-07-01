# =============================================================
# wave_ir.do - Ondas do Registrador de Instrucao (tb_instruction_register)
# Uso (na pasta tb_model):  do wave_ir.do
# Carrega a palavra (8 bits) quando li_bar=0 e a separa em
# opcode (4 bits altos, mnemonico) e operando (4 bits baixos).
# =============================================================
if {[file exists work]} { vdel -all }
vlib work
vlog -quiet ../rtl/instruction_register.v tb_instruction_register.v
vsim -voptargs=+acc work.tb_instruction_register

radix define OPCODE {
    4'b0000 "LDA",
    4'b0001 "ADD",
    4'b0010 "SUB",
    4'b1110 "OUT",
    4'b1111 "HLT",
    -default hex
}

delete wave *
configure wave -namecolwidth 200
configure wave -valuecolwidth 90
configure wave -signalnamewidth 1

set TOP /tb_instruction_register
add wave -divider "RELOGIO / RESET"
add wave -color {Yellow}  $TOP/clk
add wave                  $TOP/clr_bar
add wave -divider "CARGA (ativo-baixo: 0 = carrega)"
add wave -color {Cyan}    $TOP/li_bar
add wave -divider "PALAVRA DE ENTRADA (hex)"
add wave -radix hex       $TOP/bus_in
add wave -divider "SEPARACAO: OPCODE | OPERANDO"
add wave -radix OPCODE -color {Magenta}  $TOP/opcode
add wave -radix unsigned -color {Green}  $TOP/operand

run -all
wave zoom full
view wave
