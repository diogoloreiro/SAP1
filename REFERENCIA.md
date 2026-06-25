# Referência do SAP-1 — tabela de estados, ISA e palavra de controle

Documento de apoio (útil também para o relatório).

## Conjunto de instruções (ISA)

| Mnemônico | Opcode | Operação            |
|-----------|--------|---------------------|
| LDA addr  | 0000   | A ← RAM[addr]       |
| ADD addr  | 0001   | A ← A + RAM[addr]   |
| SUB addr  | 0010   | A ← A − RAM[addr]   |
| OUT       | 1110   | saída ← A           |
| HLT       | 1111   | para o processador  |

Formato da instrução: `OOOO AAAA` — 4 bits de opcode + 4 bits de endereço.

## Palavra de controle (12 bits)

```
CON = { Cp  Ep  ~Lm  ~CE  ~Li  ~Ei  ~La  Ea  Su  Eu  ~Lb  ~Lo }
bit:   11  10   9    8    7    6    5   4   3   2   1    0
```

| Sinal | Nível ativo | Função                                   |
|-------|-------------|------------------------------------------|
| Cp    | alto        | incrementa o PC                          |
| Ep    | alto        | PC coloca valor no barramento            |
| ~Lm   | baixo       | MAR lê do barramento                     |
| ~CE   | baixo       | RAM coloca dado no barramento            |
| ~Li   | baixo       | IR lê do barramento                      |
| ~Ei   | baixo       | IR coloca operando no barramento         |
| ~La   | baixo       | acumulador A lê do barramento            |
| Ea    | alto        | A coloca valor no barramento             |
| Su    | alto        | ALU em modo subtração                    |
| Eu    | alto        | ALU coloca resultado no barramento       |
| ~Lb   | baixo       | registrador B lê do barramento           |
| ~Lo   | baixo       | registrador de saída lê do barramento    |

Palavra ociosa (nenhum sinal ativo): `0011 1110 0011`.

## Tabela de estados (saídas da FSM)

Ciclo de busca (T1–T3) — igual para toda instrução:

| Estado | CON (12 bits)   | Sinais ativos | O que faz                |
|--------|-----------------|---------------|--------------------------|
| T1     | 0101 1110 0011  | Ep, ~Lm       | MAR ← PC                 |
| T2     | 1011 1110 0011  | Cp            | PC ← PC + 1              |
| T3     | 0010 0110 0011  | ~CE, ~Li      | IR ← RAM[MAR]            |

Ciclo de execução (T4–T6) — depende do opcode:

| Instr. | Estado | CON (12 bits)   | Sinais ativos | O que faz             |
|--------|--------|-----------------|---------------|-----------------------|
| LDA    | T4     | 0001 1010 0011  | ~Lm, ~Ei      | MAR ← operando        |
| LDA    | T5     | 0010 1100 0011  | ~CE, ~La      | A ← RAM[operando]     |
| LDA    | T6     | 0011 1110 0011  | —             | ocioso                |
| ADD    | T4     | 0001 1010 0011  | ~Lm, ~Ei      | MAR ← operando        |
| ADD    | T5     | 0010 1110 0001  | ~CE, ~Lb      | B ← RAM[operando]     |
| ADD    | T6     | 0011 1100 0111  | ~La, Eu       | A ← A + B             |
| SUB    | T4     | 0001 1010 0011  | ~Lm, ~Ei      | MAR ← operando        |
| SUB    | T5     | 0010 1110 0001  | ~CE, ~Lb      | B ← RAM[operando]     |
| SUB    | T6     | 0011 1100 1111  | ~La, Su, Eu   | A ← A − B             |
| OUT    | T4     | 0011 1111 0010  | Ea, ~Lo       | saída ← A             |
| OUT    | T5     | 0011 1110 0011  | —             | ocioso                |
| OUT    | T6     | 0011 1110 0011  | —             | ocioso                |
| HLT    | T4     | 0011 1110 0011  | — (trava halt)| para o processador    |

## Programa de exemplo (carregado em rtl/ram_16x8.v)

```
end  conteúdo      instrução    efeito
 0   0000 1101     LDA 13       A ← mem[13] = 16
 1   0001 1110     ADD 14       A ← A + mem[14] = 30
 2   0010 1111     SUB 15       A ← A − mem[15] = 26
 3   1110 0000     OUT          saída ← A = 26
 4   1111 0000     HLT          para
13   0001 0000     dado = 16
14   0000 1110     dado = 14
15   0000 0100     dado = 4
```

Resultado esperado: saída = **26 = 0x1A = 0001 1010**.

## Detalhe de temporização (importante para ler a simulação)

- O contador de anel (T1–T6) avança na **borda de descida** do clock.
- Os registradores carregam na **borda de subida**.
- Logo, a palavra de controle do estado Tn já está estável quando os
  registradores reagem, no posedge seguinte.
- Na Transcript do simulador, o valor de um registrador aparece uma linha
  "atrasada" em relação ao estado que mandou carregá-lo (efeito do `$display`
  com atribuição não-bloqueante). Na janela Wave isso não ocorre — o valor
  muda na borda correta.
