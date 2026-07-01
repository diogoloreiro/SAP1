# Glossário — SAP-1

Termos-chave do projeto, cada um em uma linha. Bom para quem está começando.

## Arquitetura

- **SAP-1** — *Simple-As-Possible computer*: processador didático de 8 bits
  do livro do Malvino.
- **Datapath** — o "caminho dos dados": os registradores e a ALU por onde os
  valores passam.
- **Barramento W** — o fio único de 8 bits que liga todos os blocos; só um
  bloco "fala" nele por vez.
- **Multiplexador (mux)** — o circuito que escolhe qual bloco fala no
  barramento (usado no lugar de tri-state, melhor para FPGA).

## Blocos

- **PC** (Program Counter) — contador de 4 bits com o endereço da próxima
  instrução.
- **MAR** (Memory Address Register) — guarda o endereço que a RAM vai ler.
- **RAM 16×8** — memória de 16 posições de 8 bits (programa + dados); só
  leitura no SAP-1.
- **IR** (Instruction Register) — guarda a instrução atual e a divide em
  opcode + operando.
- **Acumulador (A)** — registrador principal, onde a conta acontece.
- **Registrador B** — segundo operando da soma/subtração.
- **ALU** — *Arithmetic Logic Unit*: faz `A + B` ou `A − B` (combinacional).
- **Registrador de saída** — guarda o resultado para os LEDs/displays.
- **Controlador/sequenciador** — o "cérebro" que gera os sinais de controle.

## Instruções

- **Opcode** — os 4 bits que dizem **qual** instrução (LDA, ADD, …).
- **Operando** — os 4 bits que dizem **onde** está o dado (um endereço).
- **Endereçamento direto** — o operando é o endereço do dado (por isso
  `LDA 11` = "carregue o que está no endereço 11").
- **LDA / ADD / SUB / OUT / HLT** — carregar / somar / subtrair / mostrar /
  parar.

## Controle e tempo

- **Palavra de controle (CON)** — os 12 bits que ligam/desligam cada sinal em
  cada estado.
- **Ativo-alto** — sinal que age quando vale **1** (ex.: `Cp`, `Ep`).
- **Ativo-baixo** — sinal que age quando vale **0**; marcado com til `~`
  (ex.: `~La`).
- **Enable** — sinal que "habilita" um bloco (a falar ou a ouvir no
  barramento).
- **Ciclo de busca (fetch)** — T1–T3: pegar a instrução da memória.
- **Ciclo de execução (execute)** — T4–T6: fazer o trabalho da instrução.
- **T-state** — um dos estados de tempo (T1 a T6).
- **Contador de anel (ring counter)** — registrador que percorre os estados
  em círculo (T1→…→T6→T1).
- **One-hot** — codificação em que só um bit é 1 por vez (ex.: T3 = `000100`).
- **Borda de subida/descida** — a transição do clock de 0→1 (subida) ou 1→0
  (descida). Aqui: estados avançam na descida, registradores carregam na
  subida.
- **Clock-enable** — técnica de "congelar" um registrador sem desligar o
  clock (usada no HLT).
- **Gating de clock** — desligar o clock por lógica (má prática em FPGA;
  **evitada** aqui).
- **Reset assíncrono** — reset que age na hora, sem esperar o clock (`~CLR`).

## Simulação

- **Testbench** — código que aplica estímulos e verifica um módulo.
- **Autoverificável** — testbench que sozinho diz PASSOU/FALHOU.
- **Waveform (onda)** — o gráfico dos sinais ao longo do tempo (janela Wave).
- **`.do`** — script do ModelSim (comandos automatizados).
- **DUT** (*Device Under Test*) — o módulo sendo testado.
