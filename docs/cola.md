# Cola do SAP-1 (resumo de 1 página)

## Instruções (5)

| Instrução | Opcode | Faz |
|---|---|---|
| `LDA n` | `0000` | A ← memória[n] |
| `ADD n` | `0001` | A ← A + memória[n] |
| `SUB n` | `0010` | A ← A − memória[n] |
| `OUT` | `1110` | saída ← A |
| `HLT` | `1111` | para o processador |

**Formato da palavra (8 bits):** `[ opcode(4) | operando(4) ]`
O operando é um **endereço** (0–15), não um valor.

## Os 6 estados

| Fase | Estados | O que faz |
|---|---|---|
| **Busca** | T1, T2, T3 | igual p/ toda instrução |
| **Execução** | T4, T5, T6 | depende do opcode |

- **T1:** MAR ← PC · **T2:** PC ← PC+1 · **T3:** IR ← RAM
- Estado avança na **descida** do clock; registradores carregam na **subida**.

## Palavra de controle (CON = 12 bits)

```
{ Cp, Ep, ~Lm, ~CE, ~Li, ~Ei, ~La, Ea, Su, Eu, ~Lb, ~Lo }
  11  10   9    8    7    6    5   4   3   2   1    0
```
- **Ativo-alto** (1=liga): `Cp Ep Ea Su Eu`
- **Ativo-baixo** (0=liga): `~Lm ~CE ~Li ~Ei ~La ~Lb ~Lo`
- **Repouso (IDLE):** `0011_1110_0011`
- **Ler:** compare com o IDLE → os bits **diferentes** são os ativos.

| Estado | CON | Ação |
|---|---|---|
| T1 | `0101_1110_0011` | MAR ← PC |
| T2 | `1011_1110_0011` | PC ← PC+1 |
| T3 | `0010_0110_0011` | IR ← RAM |
| T4 (LDA/ADD/SUB) | `0001_1010_0011` | MAR ← operando |
| T4 (OUT) | `0011_1111_0010` | saída ← A |
| T5 (LDA) | `0010_1100_0011` | A ← RAM |
| T5 (ADD/SUB) | `0010_1110_0001` | B ← RAM |
| T6 (ADD) | `0011_1100_0111` | A ← A+B |
| T6 (SUB) | `0011_1100_1111` | A ← A−B |

## Quem fala / quem ouve no barramento

- 🗣️ **fala:** `Ep`(PC) `~CE`(RAM) `~Ei`(operando) `Ea`(A) `Eu`(ALU)
- 👂 **ouve:** `~Lm`(MAR) `~Li`(IR) `~La`(A) `~Lb`(B) `~Lo`(saída)
- Regra: **um fala, um ou mais ouvem** por estado.

## Displays na placa (HEX5 → HEX0)

| HEX5 | HEX4 | HEX3 HEX2 | HEX1 HEX0 |
|:---:|:---:|:---:|:---:|
| estado T (1–6) | instrução (L/A/5/o/H) | acumulador A | resultado |

Controles: `SW0`=clock auto/manual · `KEY1`=passo · `KEY0`=reset · `SW1`=debug.

## Comandos ModelSim (na pasta `tb_model`)

| Comando | Faz |
|---|---|
| `do wave_sap1.do` | simulação completa com ondas |
| `do wave_controller.do` | ondas do controlador |
| `do run_one.do <nome>` | um componente com ondas |
| `do run_all_tb.do` | todos os testes (PASSOU/FALHOU) |

## Fatos-chave

- Uma instrução = **6 estados**, sempre.
- O operando é **endereço**, não valor (endereçamento **direto**).
- A do `LDA` muda no T5; a do `ADD`/`SUB` muda no T6 (aparece no T1 seguinte).
- O **resultado** só muda no `OUT`; o `HLT` congela em **T4**.
- Barramento = **mux** (um falante); `HLT` = **clock-enable** (sem gating).
