# Guia de leitura das ondas — SAP-1

Guia de referência para **estudar** as ondas (waveform) da simulação do
SAP-1 no ModelSim. Não é roteiro de apresentação — é para você **entender**
o que está vendo na tela.

Como abrir (na pasta `tb_model`):
```tcl
do wave_sap1.do        # simulação completa (programa da RAM)
do wave_controller.do  # só o controlador
```

O programa carregado na RAM é o **3 × 4 = 12** (somas repetidas de 3).

---

## 1. O que é cada sinal

Os sinais estão agrupados na janela Wave. Leia de cima para baixo:

### Relógio / Reset
| Sinal | O que é |
|---|---|
| `clk` | Clock do processador. Tudo acontece nas bordas dele. |
| `clr_bar` | Reset (~CLR), **ativo em baixo**: quando está em 0, zera tudo. |

### Controle
| Sinal | O que é |
|---|---|
| `tstate` | **Estado atual** da máquina: `IDLE, T1…T6`. É o "onde estamos" no ciclo. |
| `opcode` | **Instrução atual** (LDA/ADD/SUB/OUT/HLT), lida da RAM no T3. |
| `hlt` | Sobe para 1 quando o processador **para** (instrução HLT). |

### Datapath (os registradores — em decimal)
| Sinal | O que é |
|---|---|
| `pc_out` | **PC** (contador de programa): endereço da próxima instrução. |
| `addr_out` | **MAR**: endereço que está sendo lido da RAM agora. |
| `acc_out` | **Acumulador A**: onde a conta acontece. **Siga esta linha!** |
| `b_out` | **Registrador B**: segundo operando da soma/subtração. |
| `result` | Saída da **ALU** (A ± B), combinacional. |
| `bus_w` | **Barramento W**: o "cano" por onde os dados trafegam (hex). |

### Saída
| Sinal | O que é |
|---|---|
| `out_port` | **Resultado** — o que apareceria nos LEDs/displays. Só muda no `OUT`. |

---

## 2. Como ler UM ciclo de instrução

Toda instrução leva **6 estados** (T1→T6). Os 3 primeiros são iguais para
todas (busca); os 3 últimos dependem da instrução (execução).

Pegue a **primeira instrução** (`LDA 11`) e siga o `tstate`:

| `tstate` | O que muda na onda | Significado |
|---|---|---|
| **T1** | `addr_out` (MAR) recebe o valor de `pc_out` | "pega o endereço da instrução" |
| **T2** | `pc_out` incrementa (0 → 1) | "PC já aponta para a próxima" |
| **T3** | `opcode` muda para `LDA` | "leu a instrução da RAM para o IR" |
| **T4** | `addr_out` recebe o operando (11) | "aponta para o dado" |
| **T5** | `acc_out` (A) recebe o dado (→ 3) | "carrega A com 3" |
| **T6** | nada muda (passo ocioso) | "LDA já terminou" |

Depois o `tstate` volta para **T1** e começa a **próxima** instrução.

> **Regra de ouro:** primeiro olhe o `tstate` (onde estamos), depois olhe
> qual registrador mudou naquele estado. Essa é a "história" da instrução.

---

## 3. Os detalhes que confundem (e a explicação)

### "Por que o A do ADD só muda no T1 seguinte?"
No `ADD`, o sinal que carrega o acumulador (`~La`) fica ativo no **T6**. O
registrador carrega na **borda de subida** que encerra o T6 — então o valor
novo de `acc_out` só aparece **quando o `tstate` vira de T6 para T1**. Não é
atraso da simulação; é o momento real da carga.

- `LDA` carrega A no **T5** → A muda entre T5 e T6.
- `ADD`/`SUB` carregam A no **T6** → A muda entre T6 e o T1 seguinte.

### "Por que o resultado (out_port) fica parado?"
`out_port` é o **registrador de saída**. Ele só carrega quando roda a
instrução **`OUT`**. Entre um `OUT` e outro ele **congela** — é normal. Para
ver o A mudando, olhe `acc_out`, não `out_port`.

### "Por que trava no T4 no final?"
O `HLT` é detectado no **T4**. Nesse ponto o `hlt` sobe para 1 e o contador
de estados **para de avançar** — por isso o `tstate` fica preso em `T4` para
sempre. O clock continua, mas nada mais carrega.

### "Por que o estado avança na descida do clock?"
O contador de estados anda na **borda de descida**; os registradores do
datapath carregam na **borda de subida**. Assim, quando chega a subida, a
palavra de controle daquele estado já está estável. É de propósito.

---

## 4. Acompanhando o 3 × 4 = 12

Siga só a linha **`acc_out` (A)** ao longo da onda:

| Instrução | A depois | Como |
|---|---|---|
| `LDA 11` | **3** | carrega o dado 3 |
| `ADD 11` | **6** | 3 + 3 |
| `ADD 11` | **9** | 6 + 3 |
| `ADD 11` | **12** | 9 + 3 |
| `OUT` | `out_port` → **12** | mostra o resultado |
| `HLT` | trava em T4, `hlt=1` | fim |

3 + 3 + 3 + 3 = 12 = 3 × 4. A multiplicação é feita por **somas repetidas**,
porque o SAP-1 não tem instrução de multiplicar.

---

## 5. Checklist de autoestudo

Abra `do wave_sap1.do`, dê zoom na primeira instrução e responda (as
respostas estão na seção 2):

1. No **T1**, qual sinal muda? O que ele representa?
2. Em qual estado o `pc_out` incrementa?
3. Em qual estado o `opcode` passa a mostrar a instrução certa?
4. No `LDA`, em qual estado o `acc_out` recebe o valor?
5. No `ADD`, por que o `acc_out` novo só aparece no T1 seguinte?
6. O `out_port` muda em qual instrução?
7. Em qual estado o processador congela quando encontra o `HLT`?

Se você conseguir responder essas 7 olhando a onda, você **entendeu** o
funcionamento do SAP-1.

---

## Apêndice — ondas do controlador (`wave_controller.do`)

Essa onda mostra **só o controlador**, com os 12 sinais de controle. Útil
para ver **quais sinais acendem em cada estado**:

- ativos-**alto** (`cp, ep, ea, su, eu`): acendem em **1**.
- ativos-**baixo** (`lm_bar, ce_bar, li_bar, ei_bar, la_bar, lb_bar, lo_bar`):
  acendem em **0**.

Exemplo: no **T1** você vê `ep=1` e `lm_bar=0` (PC → MAR). No **T3**,
`ce_bar=0` e `li_bar=0` (RAM → IR).
