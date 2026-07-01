# SAP-1 em Verilog — Quartus Prime + DE10-Lite

Implementação do processador didático **SAP-1** (*Simple-As-Possible*, do
Malvino) em Verilog, para a placa **Terasic DE10-Lite** (FPGA Intel MAX 10
`10M50DAF484C7G`), desenvolvido no **Quartus Prime Lite 20.1**.

O processador é de 8 bits e entende 5 instruções: `LDA`, `ADD`, `SUB`,
`OUT` e `HLT`. Cada instrução roda em 6 estados de tempo (T1–T6) gerados
por um contador de anel no controlador/sequenciador.

---

## Estrutura de pastas

```
SAP1/
├── rtl/          → núcleo do processador (datapath + controle)
├── fpga/         → camada de placa (displays, clock, debounce)
├── tb_model/     → testbenches e scripts de simulação (ModelSim)
├── docs/         → documentação e guias de estudo (.md + .pdf)
├── fsm/          → diagramas da máquina de estados
├── programas/    → programas de teste para a RAM (.txt)
├── SAP1.qpf      → projeto do Quartus
├── sap1_top.qsf  → pinagem da DE10-Lite
└── README.md
```

### `rtl/` — núcleo do SAP-1
| Arquivo | Bloco |
|---|---|
| `sap1_top.v` | Topo do núcleo — conecta tudo pelo barramento W |
| `program_counter.v` | Contador de programa (PC) |
| `mar.v` | Registrador de endereço de memória (MAR) |
| `ram_16x8.v` | Memória RAM 16×8 (contém o programa) |
| `instruction_register.v` | Registrador de instrução (IR) |
| `controller_sequencer.v` | Controlador/sequenciador (a máquina de estados) |
| `controller_fsm.v` | Mesma FSM em formato clássico (alternativa didática) |
| `accumulator.v` | Acumulador A |
| `register_b.v` | Registrador B |
| `adder_subtractor.v` | ALU (somador/subtrator) |
| `output_register.v` | Registrador de saída |

### `fpga/` — camada de placa
| Arquivo | Função |
|---|---|
| `sap1_fpga.v` | Topo de placa (clock lento, debounce, reset sync, displays) |
| `clock_divider.v` | Divisor 50 MHz → 1 Hz |
| `debouncer.v` | Antirruído dos botões |
| `seg7.v` | Decodificador 7 segmentos (hexadecimal) |
| `seg7_instr.v` | Decodificador opcode → letra (L/A/5/o/H) |

### `programas/` — programas de teste (RAM)
| Arquivo | Programa | Resultado |
|---|---|---|
| `programa1.txt` | 3³ | 27 (`1B`) |
| `programa2.txt` | (((7+3)−2)+5)−4+7−3+5 | 18 (`12`) |
| `programa3.txt` | 3 × 4 | 12 (`0C`) |
| `programa4.txt` | 12 ÷ 4 | 3 (`03`) |

### `tb_model/` — testes (ModelSim)
| Arquivo | O que é |
|---|---|
| `tb_sap1.v` | Testbench geral (integração) — roda o programa e confere o resultado |
| `tb_<modulo>.v` | Um testbench autoverificável por componente |
| `run_all_tb.do` | Roda todos os testes |
| `run_one.do` | Roda um testbench só, com ondas |
| `wave_sap1.do` | Ondas didáticas da simulação completa |
| `wave_controller.do` | Ondas didáticas do controlador |

### `docs/` e `fsm/` — documentação
| Arquivo | Conteúdo |
|---|---|
| `docs/GUIA_ESTUDO.md` | **Comece por aqui** — roteiro de estudo do projeto |
| `docs/componentes.md` | Cada bloco explicado em detalhe |
| `docs/palavra_controle.md` | A palavra de controle (CON) na prática |
| `docs/fluxo_completo.md` | Como tudo funciona junto (barramento + 1 instrução) |
| `docs/guia_ondas.md` | Como ler as ondas no ModelSim |
| `docs/programa2_explicado.md` | O programa da RAM explicado instrução a instrução |
| `docs/roteiro_video.md` | Roteiro de apresentação |
| `fsm/FSM_explicacao.md` | A máquina de estados por dentro |
| `fsm/fsm_*.{png,pdf,svg}` | Diagramas da FSM (+ scripts `.py` que os geram) |

---

## Como simular (ModelSim)

Os testbenches e scripts ficam na pasta `tb_model/`. Abra o ModelSim nessa
pasta (ou `cd tb_model` no console) e rode:

```tcl
do wave_sap1.do            # simulação completa com ondas didáticas
do run_all_tb.do           # roda todos os testbenches (PASSOU/FALHOU)
do run_one.do accumulator  # roda só um componente, com ondas
do wave_controller.do      # ondas do controlador
```

---

## Como trocar o programa da RAM

1. Abra `rtl/ram_16x8.v`.
2. Substitua o bloco de linhas `mem[...]` pelo conteúdo de um dos
   `programas/programaN.txt`.
3. Recompile no Quartus (ou re-simule).
4. Se for simular, ajuste `RESULTADO_ESPERADO` em `tb_model/tb_sap1.v` para
   bater com o novo programa.

> O programa **começa sempre no endereço 0** e os operandos (`LDA 11`, etc.)
> são endereços **absolutos** — não desloque os índices.

---

## Como gravar na placa (DE10-Lite)

1. **Compile Design** no Quartus.
2. **Programmer** → grave o `.sof`.
3. Controles:
   - `SW[0]` = clock: 0 automático (~1 Hz), 1 manual
   - `KEY[1]` = passo manual (quando `SW[0]=1`)
   - `KEY[0]` = reset
   - `SW[1]` = modo debug (mostra barramento W / registrador B)

### Layout dos displays
| HEX5 | HEX4 | HEX3 HEX2 | HEX1 HEX0 |
|:---:|:---:|:---:|:---:|
| estado T (1–6) | instrução (L/A/5/o/H) | acumulador A | resultado |

Exemplo ao parar no `HLT` do 3×4: `4 · H · 0C · 0C`.

---

## Detalhes de projeto (boas práticas)

- Barramento W via **multiplexador** (não tri-state interno).
- **HLT por clock-enable** (congela o contador de anel), sem *gating* de clock.
- Estado avança na **borda de descida**; registradores carregam na **subida**.
