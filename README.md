# SAP-1 em Verilog — Lista 4 (Sistemas Digitais, UFAM/FEEC)

Processador SAP-1 de 8 bits em Verilog. Validado em Icarus Verilog 12.0;
preparado para ModelSim (simulação) e Quartus + DE10-Lite (FPGA).

## Organização das pastas

```
sap1/
├── rtl/     NÚCLEO do processador — comum à simulação E ao FPGA
├── sim/     SIMULAÇÃO — testbenches e scripts (ModelSim / Icarus)
├── fpga/    FPGA — wrapper de placa, periféricos e pinagem (DE10-Lite)
└── docs/    REFERÊNCIA — tabela de estados, ISA, palavra de controle
```

A regra mental: `rtl/` é o processador em si (sintetizável e simulável).
`sim/` só serve para testar (não vai para a placa). `fpga/` é o que embrulha
o núcleo para rodar na placa (divisor de clock, displays, pinos).

---

### rtl/ — núcleo (10 módulos)

| Arquivo                     | Bloco                                   |
|-----------------------------|-----------------------------------------|
| program_counter.v           | contador de programa (4 bits)           |
| mar.v                       | registrador de endereço de memória      |
| ram_16x8.v                  | RAM 16×8 (o programa é carregado aqui)  |
| instruction_register.v      | registrador de instrução                |
| accumulator.v               | acumulador A                            |
| adder_subtractor.v          | ALU (soma/subtração, complemento de 2)  |
| register_b.v                | registrador B                           |
| output_register.v           | registrador de saída                    |
| controller_sequencer.v      | controlador + contador de anel T1–T6    |
| sap1_top.v                  | topo do núcleo (barramento W via mux)   |

O top-level de simulação é `sap1_top` (dentro de rtl/).

### sim/ — simulação

| Arquivo            | O que faz                                              |
|--------------------|--------------------------------------------------------|
| tb_sap1.v          | testbench principal: roda o programa, compara saída    |
| tb_alu.v           | testa a ALU isolada (complemento de 2, wrap-around)    |
| tb_robust.v        | fase do reset (clock alto/baixo) + unicidade do bus    |
| tb_fpga.v          | cadeia completa do wrapper de placa                    |
| run_modelsim.do    | ModelSim: compila, abre Wave formatada, roda tudo      |
| run_all_tests.do   | ModelSim: roda os 4 testbenches (PASS/FAIL no console) |
| run_icarus.sh      | Icarus: validação rápida na linha de comando           |

Veja `sim/README_SIM.md` para os comandos.

### fpga/ — placa (DE10-Lite, MAX 10)

| Arquivo            | O que faz                                              |
|--------------------|--------------------------------------------------------|
| clock_divider.v    | divide 50 MHz → 1 Hz (execução visível nos LEDs)       |
| debouncer.v        | antirruido p/ o clock manual (passo a passo)           |
| seg7.v             | decodificador hexadecimal p/ displays de 7 segmentos   |
| sap1_fpga.v        | top-level de placa (junta núcleo + periféricos)        |
| sap1_fpga.qsf      | pinagem do Quartus para a DE10-Lite                    |

Veja `fpga/README_FPGA.md` para gravar na placa.

### docs/ — referência

`REFERENCIA.md`: tabela de estados completa, ISA, palavra de controle e o
programa de exemplo. Bom material para colar no relatório.

---

## Início rápido (simulação)

ModelSim — dentro de `sim/`:
```
do run_modelsim.do
```

Icarus — dentro de `sim/`:
```
bash run_icarus.sh
```

Resultado esperado em todos: saída = **26 = 0x1A**, com `PASS`.

## Programa carregado

`LDA 13 ; ADD 14 ; SUB 15 ; OUT ; HLT`, com mem[13]=16, mem[14]=14,
mem[15]=4. Resultado: 16 + 14 − 4 = **26**. Para mudar, edite o bloco
`initial` em `rtl/ram_16x8.v`.

## Estado do projeto

- [x] Núcleo Verilog (10 módulos) — validado
- [x] Testbench self-checking + testes de robustez — PASS
- [x] Wrapper de FPGA + pinagem DE10-Lite — validado em simulação
- [x] Tabela de estados e diagrama da FSM (docs/ e relatório)
- [ ] Relatório final
- [ ] Vídeo de demonstração na placa
