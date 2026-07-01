# 📚 Guia de estudo — SAP-1

Este é o **mapa** para estudar o projeto na ordem certa. Cada item tem um
documento próprio; aqui você vê **o que ler, em que ordem e por quê**.

Objetivo final: entender como um processador simples **busca e executa
instruções** — e conseguir ler a simulação (as ondas) com confiança.

---

## 🎯 A trilha (leia nesta ordem)

### Etapa 1 — As peças
**📄 `componentes.md`** → o que é cada bloco (PC, MAR, IR, A, B, ALU, RAM…).

Comece aqui. Você não precisa decorar — só entender **o que cada bloco
guarda e faz**. A sacada: 5 registradores (MAR, IR, A, B, saída) são o
*mesmo circuito* (carrega/segura/zera).

> ✅ Você terminou quando souber dizer, de cada bloco: "isso guarda X e serve
> pra Y".

### Etapa 2 — Como as peças são comandadas
**📄 `palavra_controle.md`** → os 12 sinais de controle (a palavra CON).

Aqui você entende **como o processador liga/desliga cada bloco** a cada
passo. O truque: comparar cada palavra com o "repouso" (IDLE).

> ✅ Você terminou quando conseguir olhar `0101_1110_0011` e dizer "isso é
> MAR ← PC".

### Etapa 3 — Tudo junto (o coração)
**📄 `fluxo_completo.md`** → o barramento, a história de uma instrução ponta
a ponta, como o controlador decide, e um **exercício**.

Este é **o documento mais importante**. Ele conecta as etapas 1 e 2 na
"história" de uma instrução real (`ADD 11`), estado por estado. Faça o
**exercício do `5 + 2`** — é o que fixa de vez.

> ✅ Você terminou quando conseguir contar, com suas palavras, o que acontece
> do T1 ao T6 de um `ADD`.

### Etapa 4 — Ver funcionando (simulação)
**📄 `guia_ondas.md`** → como ler a janela de ondas do ModelSim.

Agora você abre a simulação e **confirma com os próprios olhos** tudo que
leu. Responda as **7 perguntas de autoteste** no fim do guia.

> ✅ Você terminou quando responder as 7 perguntas olhando a onda.

### Etapa 5 — Um programa real completo
**📄 `programa2_explicado.md`** → o programa da RAM explicado instrução por
instrução (a expressão = 18).

Aqui você vê **um programa inteiro** rodando, não só uma instrução. Ótimo
para juntar tudo.

### Etapa 6 (aprofundamento) — A máquina de estados
**📄 `FSM_explicacao.md`** → o controlador por dentro (contador de anel,
HLT, reset). Leia se quiser entender **como** a palavra de controle é gerada.

### Etapa 7 (opcional) — Apresentar
**📄 `roteiro_video.md`** → roteiro do que falar mostrando a simulação.

---

## 🛠️ A parte prática (faça, não só leia)

Estudar processador **olhando** só funciona até certo ponto. O que trava o
conhecimento é **fazer**:

1. **Rode a simulação** e siga o acumulador:
   ```tcl
   cd tb_model
   do wave_sap1.do
   ```
2. **Faça o exercício `5 + 2`** (está no `fluxo_completo.md`): monte o
   binário, trace o A na mão, e confira na simulação.
3. **Invente um programa seu** (ex.: `4 + 4 + 4`) e preveja o resultado
   antes de simular.
4. **Rode um componente isolado** para ver ele sozinho:
   ```tcl
   do run_one.do accumulator
   do run_one.do controller_sequencer
   ```

---

## ✅ Checklist final — "eu entendi o SAP-1 se…"

- [ ] …sei dizer o que cada bloco (PC, MAR, IR, A, B, ALU) faz.
- [ ] …entendo que só **um** bloco fala no barramento por vez.
- [ ] …sei que toda instrução tem **6 estados** (T1–T3 busca, T4–T6 execução).
- [ ] …consigo ler uma palavra de controle e dizer "quem fala, quem ouve".
- [ ] …entendo por que `LDA 11` carrega 3 (endereço ≠ valor).
- [ ] …sei por que o resultado só muda no `OUT` e trava no `HLT` (T4).
- [ ] …consigo montar um programa novo e prever o resultado.
- [ ] …consigo abrir a onda e confirmar tudo isso.

Se marcar todos, **você entendeu o processador**. 🎯

---

## 🔖 Referência rápida

**Instruções:** `LDA=0000  ADD=0001  SUB=0010  OUT=1110  HLT=1111`
(formato: `[opcode(4) | operando(4)]`; o operando é um **endereço**).

**Estados:** `T1 T2 T3` = busca (igual p/ todas) · `T4 T5 T6` = execução.

**Comandos ModelSim** (na pasta `tb_model`):
| Comando | Faz |
|---|---|
| `do wave_sap1.do` | simulação completa com ondas |
| `do wave_controller.do` | ondas do controlador |
| `do run_one.do <nome>` | um componente com ondas |
| `do run_all_tb.do` | todos os testes (PASSOU/FALHOU) |

**Trocar o programa:** cole um `programaN.txt` no `ram_16x8.v` e ajuste o
`RESULTADO_ESPERADO` no `tb_model/tb_sap1.v`.
