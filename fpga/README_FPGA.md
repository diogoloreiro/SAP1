# FPGA — SAP-1 na DE10-Lite

Esta pasta embrulha o núcleo (`../rtl/`) para rodar na placa Terasic
DE10-Lite (Intel MAX 10, `10M50DAF484C7G`).

## O que tem aqui

| Arquivo          | Papel                                                  |
|------------------|--------------------------------------------------------|
| sap1_fpga.v      | top-level de placa (núcleo + periféricos)              |
| clock_divider.v  | 50 MHz → 1 Hz, para a execução ser visível             |
| debouncer.v      | antirruido do botão de passo manual                    |
| seg7.v           | decodificador hex → 7 segmentos                        |
| sap1_fpga.qsf    | pinagem (locations) da DE10-Lite                       |

## Montar o projeto no Quartus

1. Crie um projeto novo **dentro desta pasta `fpga/`**, com top-level
   entity `sap1_fpga` (os caminhos `../rtl/` no .qsf assumem isso).
2. Assignments > Import Assignments… e selecione `sap1_fpga.qsf`
   (ou cole o conteúdo dele no .qsf do seu projeto).
3. Processing > Start Compilation.
4. Tools > Programmer, selecione o `.sof` e grave na placa.

## Controles na placa

| Sinal         | Função                                                  |
|---------------|---------------------------------------------------------|
| MAX10_CLK1_50 | clock de 50 MHz da placa (PIN_P11)                      |
| KEY[0]        | RESET (pressionado = reset; ativo baixo)                |
| KEY[1]        | STEP — passo manual de clock (quando SW[0]=1)           |
| SW[0]         | modo de clock: 0 = automático (1 Hz), 1 = manual        |
| LEDR[7:0]     | registrador de saída (resultado)                        |
| LEDR[9]       | HLT — acende quando o processador para                  |
| HEX1 HEX0     | saída em hexadecimal ("1A" no exemplo)                  |

## Roteiro de demonstração (para o vídeo)

1. Defina `SW[0]` (auto ou manual) **antes** de soltar o reset.
2. Pressione e solte `KEY[0]` (reset).
3. Modo automático: o programa roda em ~30 s. Ao final, `LEDR[7:0]` mostra
   `0001 1010`, os displays mostram `1A` e `LEDR[9]` (HLT) acende.
4. Modo manual: cada toque em `KEY[1]` avança um estado T — ótimo para
   mostrar o ciclo de busca/execução estado a estado no vídeo.

## Ajustar a velocidade

A frequência é parametrizável em `sap1_fpga` (`DIV`):
`freq = 50 MHz / (2*DIV)`. Padrão `DIV = 25_000_000` → 1 Hz.
Exemplos: `DIV = 12_500_000` → 2 Hz; `DIV = 5_000_000` → 5 Hz.

## ATENÇÃO aos pinos

A `sap1_fpga.qsf` segue a tabela oficial do "DE10-Lite User Manual".
Confira contra o manual / o .qsf de exemplo da sua placa antes de gravar —
um único pino errado impede o funcionamento. Se a placa for outra modelo,
os pinos mudam totalmente (só os pinos; a lógica é a mesma).

## Observações de projeto

- O HLT NÃO usa gating de clock. Usa um flag de halt registrado +
  clock-enable: o contador de anel para de avançar e a palavra de controle
  vira IDLE, então nenhum registrador carrega. Sintetiza limpo.
- O reset é sincronizado no desassert (assert assíncrono, desassert
  síncrono) — evita problema de recovery/removal no FPGA.
- O seletor de clock (auto/manual) é um mux combinacional simples: defina o
  modo antes de soltar o reset e não troque durante a execução.
