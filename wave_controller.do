# =============================================================
# wave_controller.do - Ondas DIDATICAS do controller_sequencer
# Uso:  do wave_controller.do
#
# Mostra o estado como T1..T6 (em vez de one-hot), o opcode como
# mnemonico, e agrupa os sinais para leitura facil.
# =============================================================
if {[file exists work]} { vdel -all }
vlib work
vlog -quiet controller_sequencer.v tb_controller_sequencer.v
vsim -voptargs=+acc work.tb_controller_sequencer

# ---- radix: estado do anel (one-hot -> nome legivel) ----
radix define ESTADO {
    6'b000000 "IDLE",
    6'b000001 "T1",
    6'b000010 "T2",
    6'b000100 "T3",
    6'b001000 "T4",
    6'b010000 "T5",
    6'b100000 "T6",
    -default binary
}

# ---- radix: opcode -> mnemonico ----
radix define OPCODE {
    4'b0000 "LDA",
    4'b0001 "ADD",
    4'b0010 "SUB",
    4'b1110 "OUT",
    4'b1111 "HLT",
    -default hex
}

# ---- monta a janela de ondas ----
delete wave *
configure wave -namecolwidth 200
configure wave -valuecolwidth 90
configure wave -signalnamewidth 1

set TOP /tb_controller_sequencer

add wave -divider "RELOGIO / RESET"
add wave -color {Yellow}    $TOP/clk
add wave                    $TOP/clr_bar

add wave -divider "ESTADO  (o que ler primeiro)"
add wave -radix ESTADO -color {Magenta}  $TOP/ring
add wave -radix OPCODE                   $TOP/opcode
add wave -color {Orange}                 $TOP/hlt

add wave -divider "PALAVRA DE CONTROLE (12 bits)"
add wave -radix binary -color {Cyan}     $TOP/con

add wave -divider "SINAIS ATIVOS-ALTO  (1 = ativo)"
add wave $TOP/cp
add wave $TOP/ep
add wave $TOP/ea
add wave $TOP/su
add wave $TOP/eu

add wave -divider "SINAIS ATIVOS-BAIXO (0 = ativo)"
add wave $TOP/lm_bar
add wave $TOP/ce_bar
add wave $TOP/li_bar
add wave $TOP/ei_bar
add wave $TOP/la_bar
add wave $TOP/lb_bar
add wave $TOP/lo_bar

run -all
wave zoom full
