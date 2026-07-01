# Roteiro de apresentação — Simulação do SAP-1 (3 × 4 = 12)

Comando para abrir a onda no ModelSim: `do wave_sap1.do`

Programa na RAM: **3 × 4 = 12** (multiplicação por somas repetidas de 3).

---

## Cena 1 — Visão geral (Zoom Full)

**Mostrar:** a onda inteira.

**Falar:**
> "Este é o SAP-1 executando 3 × 4 por somas repetidas. Em cima temos o
> clock e o reset; depois o estado do processador, a instrução atual e o
> sinal de parada (HLT); embaixo, os registradores (PC, MAR, acumulador A,
> registrador B, ALU) e a saída."

**Apontar:** a linha do **`opcode`** — a sequência de instruções
`LDA → ADD → ADD → ADD → OUT → … → HLT`. "Cada bloco é uma instrução."

---

## Cena 2 — O ciclo de busca (zoom na 1ª instrução, LDA)

**Fazer:** dar **zoom** na primeira instrução (arrastar na régua de tempo).
Agora dá pra ver `T1 T2 T3 T4 T5 T6` no `tstate`.

**Falar:**
> "Toda instrução começa igual: o ciclo de BUSCA, em três passos."

**Apontar, estado a estado:**
- **T1** — `pc_out` vai para o `MAR` (addr_out). "Pega o endereço da instrução."
- **T2** — `pc_out` incrementa (0 → 1). "O PC já aponta para a próxima."
- **T3** — `opcode` muda para `LDA`. "A instrução foi lida da RAM para o IR."

---

## Cena 3 — A execução e a conta crescendo (acumulador A)

**Apontar:** a linha **verde `acc_out` (A)** — é a estrela.

**Falar, acompanhando A:**
> "Agora a parte que faz a conta. Olhem o acumulador:"
- `LDA` → **A = 3**  ("carrega o primeiro 3")
- `ADD` → **A = 6**  ("soma mais 3")
- `ADD` → **A = 9**
- `ADD` → **A = 12** ("3 + 3 + 3 + 3 = 12, que é 3 × 4")

**Detalhe fino (opcional, impressiona):**
> "Reparem que no ADD o A só muda na virada de T6 para o T1 seguinte —
> porque o sinal de carga do acumulador (~La) só fica ativo no T6, e o
> registrador carrega na borda que encerra esse estado."

---

## Cena 4 — A saída (OUT)

**Apontar:** quando o `opcode` = **`OUT`**, a linha **laranja `out_port`** vai
para **12**.

**Falar:**
> "A instrução OUT copia o acumulador para o registrador de saída — é o que
> apareceria nos displays da placa. Aqui o resultado: 12."

---

## Cena 5 — A parada (HLT)

**Apontar:** no fim, `opcode` = **`HLT`**, o `hlt` sobe para **1** e o
`tstate` **congela em T4**.

**Falar:**
> "Por fim, o HLT. Ele é detectado no estado T4 e congela o processador ali
> mesmo — o contador de estados para de avançar. Na placa, isso acende o LED
> de HLT e os displays ficam mostrando 0C, que é 12 em hexadecimal."

---

## Cena 6 — Fechamento (resultado na placa)

**Falar:**
> "Na DE10-Lite o painel final fica assim:"

| HEX5 | HEX4 | HEX3 HEX2 | HEX1 HEX0 |
|:---:|:---:|:---:|:---:|
| `4` (estado) | `H` (HLT) | `0C` (A=12) | `0C` (resultado) |

> "Estado 4, instrução H de HLT, acumulador e resultado em 0C — 12 decimal."

---

## Resumo de 1 frase (para o final)

> "O SAP-1 não multiplica de uma vez: ele soma o 3 quatro vezes, um passo de
> cada vez, controlado pela máquina de estados T1–T6 — e é exatamente isso
> que a simulação mostra."

---

### Checklist técnico (se perguntarem)

- 6 estados por instrução (T1–T3 busca, T4–T6 execução).
- Estado avança na borda de DESCIDA; registradores carregam na SUBIDA.
- HLT por clock-enable (congela o anel), sem desligar o clock.
- Verificação: testbench autoverificável deu `PASSOU: saida = 12`.
