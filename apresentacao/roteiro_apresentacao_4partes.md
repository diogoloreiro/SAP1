# Roteiro da apresentação — SAP-1 (4 partes · 3 pessoas)

Roteiro de `SAP1_apresentacao_4partes.pptx` (25 slides). A apresentação tem
**4 partes**, divididas entre **3 apresentadores** — a **Pessoa 2** cobre as
partes 2 e 3. Tempo estimado: **~14–16 min**. As falas também estão nas
**notas do apresentador** de cada slide.

## Divisão geral

| Parte | Apresentador | Slides | Tema |
|---|---|---|---|
| — | Todos | 1–2 | Capa + Sumário |
| 1 | **Pessoa 1** | 4–8 | Objetivo e FSM (a abordagem) |
| 2 | **Pessoa 2** | 10–13 | Program Counter e Memória RAM |
| 3 | **Pessoa 2** | 15–18 | Palavra de controle |
| 4 | **Pessoa 3** | 20–24 | Validação e conclusão |

> A **Pessoa 2** apresenta as partes 2 e 3 seguidas (componentes → controle),
> sem passar a palavra no meio.

---

## Abertura (slides 1–2)

**Slide 1 — Capa**
> "Boa tarde. Somos [nomes], da disciplina de [disciplina]. Vamos apresentar
> nossa implementação do processador SAP-1, organizada em quatro partes."

**Slide 2 — Sumário**
> "A Pessoa 1 abre com o objetivo e a máquina de estados; a Pessoa 2 cobre o
> contador de programa, a memória e a palavra de controle; e a Pessoa 3 fecha
> com a validação e a conclusão."

---

## Parte 1 — Pessoa 1 · Objetivo e FSM

**Slide 4 — Objetivo do trabalho**
> "Nosso objetivo foi implementar o SAP-1, o processador mais simples que
> ainda é um computador de verdade. A ideia era entender, construindo, como um
> processador funciona por dentro — e rodar de verdade na placa."

**Slide 5 — Nossa abordagem** *(o que pensamos sobre como fazer)*
> "Nossa estratégia teve quatro pilares: modularizar — cada bloco virou um
> arquivo; controlar tudo por uma máquina de estados; verificar cada parte por
> simulação; e só então ir para a placa. Essa ordem evitou erros."

**Slide 6 — A arquitetura (datapath)**
> "Esta é a arquitetura. No centro, o barramento por onde os dados passam. Em
> cima, busca e memória. Embaixo, a aritmética. À direita, a unidade de
> controle — que é a nossa máquina de estados, o foco desta parte."

**Slide 7 — O ciclo de instrução (6 estados)**
> "O funcionamento é organizado em 6 estados. Os três primeiros são a busca,
> sempre iguais. Os três últimos são a execução. Quem controla essa sequência
> é a máquina de estados."

**Slide 8 — A máquina de estados (FSM)** *(fecha a Parte 1)*
> "E aqui está a FSM: um contador de anel que gira pelos estados T1 a T6 e
> volta. O reset a coloca no IDLE, e o HLT a congela no T4. Passo para a Pessoa
> 2 mostrar os primeiros blocos."

---

## Parte 2 — Pessoa 2 · Program Counter e Memória RAM

**Slide 10 — Program Counter (PC)**
> "O PC é um contador que guarda o endereço da próxima instrução. O sinal Cp
> faz ele incrementar, e o Ep coloca o valor no barramento. É de 4 bits porque
> a memória só tem 16 posições."

**Slide 11 — MAR**
> "O MAR é o elo com a memória: ele segura o endereço que a RAM vai ler. É
> carregado duas vezes por instrução — no T1 recebe o PC, para buscar a
> instrução; no T4 recebe o operando, para buscar o dado."

**Slide 12 — Memória RAM 16×8**
> "A memória guarda programa e dados juntos. Ponto que confunde: o operando de
> uma instrução é um endereço, não um valor. 'LDA 11' carrega o que está no
> endereço 11 — endereçamento direto."

**Slide 13 — PC, MAR e RAM na busca** *(transição para a Parte 3 — mesma pessoa)*
> "Juntando os três: na busca, o PC manda o endereço para o MAR, o PC se
> incrementa, e a RAM entrega a instrução para o IR. Esses passos são iguais
> para toda instrução. **Agora vou mostrar como esses sinais são gerados — a
> palavra de controle.**"

---

## Parte 3 — Pessoa 2 · Palavra de controle *(continua a mesma pessoa)*

**Slide 15 — A palavra de controle (12 bits)**
> "O que sai da máquina de estados é a palavra de controle: 12 bits que, a
> cada estado, dizem o que cada bloco faz. Ela depende só do estado e da
> instrução, nunca do dado — por isso o comportamento é determinístico."

**Slide 16 — Falar e ouvir no barramento**
> "Na prática, a palavra escolhe quem fala e quem ouve no barramento. Há cinco
> sinais de falar e cinco de ouvir. Um detalhe: alguns são ativos em baixo,
> agem quando valem zero — por isso o repouso não é tudo zero."

**Slide 17 — As palavras de controle por estado**
> "Esta tabela mostra as 'receitas': a palavra de 12 bits de cada estado e a
> ação que ela produz. A busca é igual para todas; a execução muda conforme a
> instrução."

**Slide 18 — Exemplo: execução do ADD** *(fecha a Parte 3)*
> "Juntando tudo num exemplo: o ADD, estado por estado. Cada linha é uma
> palavra de controle em ação — busca, acha o dado, carrega o B e soma. Passo
> para a Pessoa 3 mostrar como validamos tudo isso."

---

## Parte 4 — Pessoa 3 · Validação e conclusão

**Slide 20 — Implementação em Verilog**
> "Cada bloco virou um módulo, com boas práticas: barramento por
> multiplexador, HLT por clock-enable em vez de desligar o clock, e um reset
> bem tratado. Isso deixou o projeto robusto e sintetizável."

**Slide 21 — Verificação por simulação**
> "Para validar, não confiamos só no olho: cada bloco tem um teste automático
> que diz PASSOU ou FALHOU. São 14 testes, incluindo um que roda um programa
> inteiro e confere o resultado. Todos passam."

**Slide 22 — Execução na placa (DE10-Lite)**
> "E roda de verdade na placa, com clock lento. Os seis displays mostram o
> estado, a instrução, o acumulador e o resultado. Dá para avançar passo a
> passo com um botão." *(demonstrar ao vivo, se der)*

**Slide 23 — Programas testados**
> "Testamos com quatro programas. Como o SAP-1 só soma e subtrai, fazemos
> multiplicação com somas repetidas e divisão com subtrações. Todos deram o
> resultado esperado."

**Slide 24 — Conclusão e trabalhos futuros**
> "Para concluir: construímos um processador inteiro e entendemos a
> arquitetura e o funcionamento. Verificamos com testes e validamos na placa.
> Como evolução, daria para adicionar escrita na memória e desvios, chegando
> ao SAP-2. Obrigado."

**Slide 25 — Obrigado / Perguntas**
> "Obrigado! Estamos abertos a perguntas."

---

## Dicas para o dia

- **Transições:** só há duas trocas reais de pessoa — depois do slide 8
  (Pessoa 1 → Pessoa 2) e depois do slide 18 (Pessoa 2 → Pessoa 3).
- A **Pessoa 2** tem a maior parte — ensaiar bem a ligação entre a Parte 2 e a
  Parte 3 (slide 13 → 15).
- **Cola e glossário** (`docs/`) à mão para perguntas técnicas.
- **Plano B para a demo:** tenham um print/vídeo da onda pronto.
- **Preencher** os nomes na capa e a disciplina/instituição (variáveis no topo
  do `gerar_pptx_4partes.py`).
