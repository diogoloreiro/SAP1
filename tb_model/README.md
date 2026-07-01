# tb_model — Testbenches para ModelSim

Suíte de simulação do SAP-1 escrita para o **ModelSim/Questa** (Intel FPGA
Edition). Os módulos do projeto ficam na pasta acima (`../`); aqui estão os
testbenches e os scripts `.do`.

> Estilo ModelSim: sem `$dumpfile`/`$dumpvars` (VCD) e sem scripts de Icarus.
> A captura de ondas é feita pelo próprio `.wlf` do ModelSim (`add wave`).
> Os testbenches usam `$stop` (pausa a simulação para inspeção das ondas).

## Como rodar (na pasta `tb_model`)

```tcl
do run_all_tb.do            # roda TODOS os testbenches (resumo PASSOU/FALHOU)
do run_one.do accumulator   # roda UM componente, com ondas
do wave_sap1.do             # simulação completa com ondas didáticas
do wave_controller.do       # ondas do controlador (estados + sinais)
```

Em modo batch (sem GUI):
```bash
vsim -c -do run_all_tb.do
```

## Testbenches

| Arquivo | Componente testado |
|---|---|
| `tb_program_counter.v` | contador de programa (PC) |
| `tb_mar.v` | registrador de endereço (MAR) |
| `tb_instruction_register.v` | registrador de instrução (IR) |
| `tb_accumulator.v` | acumulador A |
| `tb_register_b.v` | registrador B |
| `tb_output_register.v` | registrador de saída |
| `tb_adder_subtractor.v` | ALU (somador/subtrator) |
| `tb_seg7.v` | decodificador 7 segmentos |
| `tb_seg7_instr.v` | decodificador opcode → letra |
| `tb_ram_16x8.v` | memória/ROM |
| `tb_controller_sequencer.v` | controlador/sequenciador (FSM) |
| `tb_clock_divider.v` | divisor de clock |
| `tb_debouncer.v` | antirruído de botão |
| `tb_sap1.v` | **integração** (processador completo) |

Cada testbench é **autoverificável**: imprime `<modulo>: PASSOU` ou
`<modulo>: FALHOU (N erros)`.

> O `tb_sap1.v` confere um valor fixo (`RESULTADO_ESPERADO`) que deve bater
> com o programa carregado em `../ram_16x8.v`.
