# Simulação do SAP-1

Esta pasta contém os testbenches e os scripts para simular o processador.
Nada aqui vai para a placa — é só verificação.

## ModelSim / Questa

Abra o ModelSim, vá até esta pasta no Transcript e rode um dos scripts:

```
cd .../sap1/sim

# simulação principal com forma de onda formatada:
do run_modelsim.do

# OU verificação rápida dos 4 testbenches (só PASS/FAIL):
do run_all_tests.do
```

O `run_modelsim.do` abre a janela Wave já com os sinais agrupados:
Clock/Reset, Controle (estado T e palavra CON), Barramento W, Memória
(MAR/RAM) e Registradores (PC, opcode, operando, A, B, ALU, OUT).

### Como ler a forma de onda

- `estado T (one-hot)` muda na **borda de descida**; os registradores
  carregam na **borda de subida** seguinte.
- Para entender, siga UMA instrução olhando `estado T`, `palavra CON` e
  `W bus` lado a lado. A LDA é a mais simples para começar.
- Na Transcript, o valor de um registrador aparece uma linha depois do
  estado que o carregou (efeito do `$display` + `<=`). Na Wave isso não
  acontece. Raciocine pela causa (o sinal de load), não pelo texto.

## Icarus Verilog (linha de comando)

```
cd .../sap1/sim
bash run_icarus.sh
```

Para gerar ondas e abrir no GTKWave:
```
iverilog -g2012 -o /tmp/s ../rtl/*.v tb_sap1.v
vvp /tmp/s            # gera tb_sap1.vcd
gtkwave tb_sap1.vcd
```

## Os testbenches

| Testbench    | Verifica                                                    |
|--------------|-------------------------------------------------------------|
| tb_sap1.v    | programa completo; compara a saída final com 26 (PASS/FAIL) |
| tb_alu.v     | soma, subtração, complemento de 2 e wrap-around da ALU      |
| tb_robust.v  | reset solto com clock alto E baixo; só uma fonte no bus     |
| tb_fpga.v    | divisor de clock + reset sincronizado + display (DE10-Lite) |

O `tb_fpga.v` precisa também dos arquivos de `../fpga/` (o `run_all_tests.do`
e o `run_icarus.sh` já cuidam disso).
