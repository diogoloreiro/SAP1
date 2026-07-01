# =============================================================
# wave_ram.do - Ondas da RAM 16x8 (tb_ram_16x8)
# Uso (na pasta tb_model):  do wave_ram.do
# Memoria so-leitura: percorre os enderecos (addr) e mostra o
# conteudo (data_out). Separa tambem opcode | operando do dado lido.
# =============================================================
if {[file exists work]} { vdel -all }
vlib work
vlog -quiet ../rtl/ram_16x8.v tb_ram_16x8.v
vsim -voptargs=+acc work.tb_ram_16x8

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

set TOP /tb_ram_16x8
add wave -divider "ENDERECO (decimal)"
add wave -radix unsigned -color {Cyan}   $TOP/addr
add wave -divider "CONTEUDO LIDO"
add wave -radix hex                      $TOP/data_out
add wave -divider "INTERPRETADO: OPCODE | OPERANDO"
add wave -radix OPCODE -color Magenta  $TOP/data_out(7:4)
add wave -radix unsigned -color Green  $TOP/data_out(3:0)

run -all
wave zoom full
view wave
