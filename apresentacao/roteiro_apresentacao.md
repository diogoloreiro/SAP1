# Roteiro da apresentação — SAP-1 (28 slides)

Roteiro de `SAP1_apresentacao.pptx`, com as **falas divididas entre 3
pessoas**. Tempo estimado: **~15–18 min**. As falas também estão nas **notas
do apresentador** de cada slide (PowerPoint: *Exibir ▸ Modo de Apresentador*).

## Divisão geral

| Parte | Apresentador | Slides | Tema |
|---|---|---|---|
| — | Todos | 1–2 | Capa + Sumário |
| 1 | **Pessoa 1** | 4–8 | Introdução e arquitetura |
| 2 | **Pessoa 2** | 10–13 | Componentes e implementação |
| 3 | **Pessoa 3** | 15–27 | Funcionamento e resultados |

> **A Parte 3 é a mais longa.** Sugestão para equilibrar: Pessoa 1 e Pessoa 2
> podem assumir os slides de **encerramento** (25 Conclusão, 26 Trabalhos
> futuros, 27 Referências), enquanto a Pessoa 3 foca em funcionamento (15–24).

---

## Abertura (slides 1–2)

**Slide 1 — Capa**
> "Boa tarde. Somos [nomes], da disciplina de [disciplina]. Vamos apresentar a
> arquitetura completa do processador SAP-1 e a nossa implementação em
> Verilog."

**Slide 2 — Sumário**
> "A apresentação tem três partes: primeiro a arquitetura geral; depois os
> componentes e a implementação; e por fim o funcionamento, a verificação e os
> resultados."

---

## Parte 1 — Pessoa 1 (Introdução e arquitetura)

**Slide 4 — O que é o SAP-1**
> "O SAP-1 é o processador mais simples que ainda é um computador de verdade.
> Apesar de simples, tem os mesmos princípios de um processador real: busca,
> decodifica e executa instruções. Usa arquitetura de Von Neumann."

**Slide 5 — Objetivos**
> "Nossos objetivos foram quatro: entender a arquitetura, implementar em
> Verilog, verificar por simulação e rodar na placa. É mais ou menos essa a
> ordem da apresentação."

**Slide 6 — Especificações**
> "Em números: tudo é de 8 bits, a memória tem 16 posições, há dois
> registradores de dados, a ULA só soma e subtrai, e são apenas 5 instruções.
> Tudo conversa por um único barramento."

**Slide 7 — Diagrama do datapath**
> "Este é o mapa da arquitetura. No centro, o barramento W. Em cima, busca e
> memória: PC, MAR, RAM, IR. Embaixo, a aritmética: acumulador, ULA e B, mais
> a saída. À direita, a unidade de controle. As setas vermelhas são os sinais
> de controle."

**Slide 8 — Barramento W** *(fecha a Parte 1)*
> "Como é um fio só, só um bloco pode escrever por vez. Os sinais de controle
> são justamente os 'enables' de falar e ouvir. É feito com um multiplexador.
> Passo para a Pessoa 2 detalhar cada bloco."

---

## Parte 2 — Pessoa 2 (Componentes e implementação)

**Slide 10 — PC, MAR e IR**
> "Estes três registradores cuidam do fluxo: o PC aponta para a próxima
> instrução, o MAR aponta para a memória, e o IR guarda a instrução atual,
> separando em opcode e operando."

**Slide 11 — RAM 16×8**
> "A memória guarda programa e dados juntos. Ponto que confunde: o operando é
> um endereço, não um valor. 'LDA 11' carrega o conteúdo do endereço 11 —
> endereçamento direto."

**Slide 12 — Acumulador, B e ULA**
> "O coração aritmético: o acumulador guarda as contas, o B guarda o segundo
> número, e a ULA soma ou subtrai. A ULA é combinacional — não armazena, só
> mostra o resultado quando o sinal Eu liga."

**Slide 13 — Padrão de projeto (código)** *(fecha a Parte 2)*
> "Um detalhe de implementação: cinco blocos são o mesmo circuito de
> registrador — reseta, carrega quando habilitado, senão mantém. Muda só a
> largura e o sinal de carga. Isso deixou o código limpo. Passo para a Pessoa
> 3."

---

## Parte 3 — Pessoa 3 (Funcionamento e resultados)

**Slide 15 — Conjunto de instruções**
> "São 5 instruções: LDA carrega da memória, ADD e SUB fazem aritmética, OUT
> mostra e HLT para. Cada uma usa um número diferente de estados úteis, mas
> todas ocupam os 6 estados."

**Slide 16 — Ciclo de instrução (6 estados)**
> "Cada instrução leva 6 passos. Os três primeiros são a busca, sempre iguais.
> Os três últimos são a execução, que muda conforme a instrução. Os estados
> avançam na descida do clock e os registradores carregam na subida."

**Slide 17 — Máquina de estados (FSM)**
> "A unidade de controle é esta máquina de estados: um contador de anel que
> percorre T1 a T6 e volta. O reset entra no IDLE e o HLT congela no T4."

**Slide 18 — Palavra de controle**
> "O que sai da máquina de estados são 12 bits que dizem, a cada estado, o que
> cada bloco faz. Essa palavra depende só do estado e da instrução, nunca do
> dado — por isso o comportamento é determinístico."

**Slide 19 — Microoperações**
> "Este diagrama mostra a execução de cada instrução. A busca (azul) é sempre
> igual; a execução (verde) muda. Cada coluna é uma instrução."

**Slide 20 — Exemplo de execução: ADD**
> "Juntando tudo: o ADD, estado por estado. Busca nos três primeiros; no T4
> acha o dado; no T5 carrega o B; no T6 soma. Seis passos e a soma está feita."

**Slide 21 — Implementação em Verilog**
> "Cada bloco virou um módulo, com boas práticas: barramento por mux, HLT por
> clock-enable, e reset bem tratado. Isso deixa o projeto robusto."

**Slide 22 — Verificação**
> "Não confiamos só no olho: cada bloco tem um teste automático que diz PASSOU
> ou FALHOU. São 14 testes, incluindo um que roda um programa inteiro. Todos
> passam."

**Slide 23 — Na placa (DE10-Lite)**
> "Roda na FPGA com clock lento. Os seis displays mostram o estado, a
> instrução, o acumulador e o resultado. Dá para avançar passo a passo com um
> botão." *(demonstrar ao vivo, se der)*

**Slide 24 — Programas de teste**
> "Testamos com quatro programas. Como o SAP-1 só soma e subtrai, fazemos
> multiplicação com somas e divisão com subtrações. Todos deram o resultado
> esperado."

**Slide 25 — Conclusão**
> "Construímos um processador inteiro e entendemos a arquitetura e o
> funcionamento. Usamos boas práticas, verificamos com testes e validamos na
> placa. Um projeto que uniu teoria e prática."

**Slide 26 — Trabalhos futuros**
> "Como evolução: uma instrução de escrita, desvios para fazer laços, e mais
> instruções — o próximo passo seria o SAP-2."

**Slide 27 — Referências**
> "Nossas referências: o livro do Malvino, a documentação do Quartus e da
> placa, e o padrão Verilog."

**Slide 28 — Obrigado / Perguntas**
> "Obrigado! Estamos abertos a perguntas."

---

## Dicas para o dia

- **Transições:** cada um termina passando a palavra ("passo para o(a)…").
- **Equilíbrio:** a Parte 3 é longa — combinem quem assume os slides 25–27.
- **Cola e glossário** (`docs/`) à mão para perguntas técnicas.
- **Plano B para a demo:** tenham um print/vídeo da onda pronto.
- **Ritmo:** ~35–40 s por slide de conteúdo.
- **Preencher** os nomes na capa e a disciplina/instituição (no `gerar_pptx.py`
  ou direto no PowerPoint).
