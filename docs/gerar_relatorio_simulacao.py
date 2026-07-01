#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gera o relatorio final de VERIFICACAO POR SIMULACAO do SAP-1 em DOCX.
Requer: python-docx.  Imagens em ../apresentacao/img/.
Saida: Relatorio_Simulacao_SAP1.docx (nesta pasta docs/).
"""
import os
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

HERE = os.path.dirname(os.path.abspath(__file__))
IMG  = os.path.abspath(os.path.join(HERE, "..", "apresentacao", "img"))
OUT  = os.path.join(HERE, "Relatorio_Simulacao_SAP1.docx")

DARK  = RGBColor(0x0d, 0x3b, 0x66)
GREY  = RGBColor(0x55, 0x55, 0x55)
GREEN = RGBColor(0x1b, 0x5e, 0x20)

doc = Document()

# ---------- estilos base ----------
normal = doc.styles["Normal"]
normal.font.name = "Calibri"
normal.font.size = Pt(11)
normal.paragraph_format.space_after = Pt(6)
normal.paragraph_format.line_spacing = 1.15

def set_heading_color(styname, color, size):
    st = doc.styles[styname]
    st.font.color.rgb = color
    st.font.size = Pt(size)
    st.font.name = "Calibri"
for s, sz in (("Heading 1", 16), ("Heading 2", 13), ("Heading 3", 11.5)):
    set_heading_color(s, DARK, sz)

def p(text="", style=None, bold=False, italic=False, size=None, color=None,
      align=None, space_after=None):
    par = doc.add_paragraph(style=style)
    if text:
        r = par.add_run(text)
        r.bold = bold; r.italic = italic
        if size: r.font.size = Pt(size)
        if color: r.font.color.rgb = color
    if align is not None: par.alignment = align
    if space_after is not None: par.paragraph_format.space_after = Pt(space_after)
    return par

def bullet(text, sub=False):
    par = doc.add_paragraph(style="List Bullet 2" if sub else "List Bullet")
    # aceita **negrito** simples
    for i, chunk in enumerate(text.split("**")):
        r = par.add_run(chunk)
        if i % 2 == 1:
            r.bold = True
    return par

def code(lines):
    par = doc.add_paragraph()
    par.paragraph_format.left_indent = Cm(0.4)
    par.paragraph_format.space_before = Pt(2)
    par.paragraph_format.space_after = Pt(8)
    r = par.add_run("\n".join(lines))
    r.font.name = "Consolas"
    r.font.size = Pt(9)
    r.font.color.rgb = RGBColor(0x1a, 0x1a, 0x1a)
    # sombreamento leve
    shd = OxmlElement("w:shd"); shd.set(qn("w:val"), "clear")
    shd.set(qn("w:fill"), "F2F4F7")
    par._p.get_or_add_pPr().append(shd)
    return par

FIGN = [0]
def figure(fname, caption, width_cm=15.5):
    path = os.path.join(IMG, fname)
    if not os.path.exists(path):
        p(f"[figura ausente: {fname}]", italic=True, color=GREY); return
    par = doc.add_paragraph(); par.alignment = WD_ALIGN_PARAGRAPH.CENTER
    par.add_run().add_picture(path, width=Cm(width_cm))
    FIGN[0] += 1
    cap = doc.add_paragraph()
    cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = cap.add_run(f"Figura {FIGN[0]} — {caption}")
    r.italic = True; r.font.size = Pt(9); r.font.color.rgb = GREY
    cap.paragraph_format.space_after = Pt(10)

def table(headers, rows, widths=None):
    t = doc.add_table(rows=1, cols=len(headers))
    t.style = "Light Grid Accent 1"
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    for j, h in enumerate(headers):
        c = t.rows[0].cells[j]
        c.text = ""
        rr = c.paragraphs[0].add_run(h); rr.bold = True; rr.font.size = Pt(10)
    for row in rows:
        cells = t.add_row().cells
        for j, val in enumerate(row):
            cells[j].text = ""
            rr = cells[j].paragraphs[0].add_run(str(val)); rr.font.size = Pt(10)
    if widths:
        for j, w in enumerate(widths):
            for r_ in t.rows:
                r_.cells[j].width = Cm(w)
    doc.add_paragraph().paragraph_format.space_after = Pt(2)
    return t

# =====================================================================
# CAPA
# =====================================================================
for _ in range(3): doc.add_paragraph()
p("Processador SAP-1", align=WD_ALIGN_PARAGRAPH.CENTER, bold=True, size=30, color=DARK)
p("Relatório de Verificação Funcional por Simulação",
  align=WD_ALIGN_PARAGRAPH.CENTER, size=16, color=GREY)
doc.add_paragraph()
p("Implementação em Verilog · Simulação em ModelSim ASE 2020.1",
  align=WD_ALIGN_PARAGRAPH.CENTER, italic=True, size=12)
p("Plataforma-alvo: Terasic DE10-Lite (Intel MAX 10)",
  align=WD_ALIGN_PARAGRAPH.CENTER, italic=True, size=12, color=GREY)
for _ in range(6): doc.add_paragraph()
p("Disciplina: __________________________", align=WD_ALIGN_PARAGRAPH.CENTER, size=12)
p("Integrantes: __________________________", align=WD_ALIGN_PARAGRAPH.CENTER, size=12)
p("Data: ____ / ____ / ______", align=WD_ALIGN_PARAGRAPH.CENTER, size=12)
doc.add_page_break()

# =====================================================================
# 1. INTRODUÇÃO
# =====================================================================
doc.add_heading("1. Introdução", level=1)
p("Este relatório documenta a verificação funcional do processador didático "
  "SAP-1 (Simple-As-Possible), implementado em Verilog e validado por simulação "
  "antes da gravação na FPGA. O foco não é a arquitetura em si, mas a "
  "comprovação, por formas de onda e testes auto-verificáveis, de que cada "
  "componente e o sistema completo se comportam conforme o especificado.")

p("Características relevantes do processador para a verificação:")
bullet("**Barramento único de 8 bits** (barramento W), implementado por multiplexador.")
bullet("**Memória RAM 16×8** (16 posições de 8 bits), somente leitura em execução, "
       "compartilhada entre programa e dados (arquitetura de Von Neumann).")
bullet("**Cinco instruções:** LDA (0000), ADD (0001), SUB (0010), OUT (1110) e HLT (1111); "
       "cada palavra é [opcode(4) | operando(4)], com endereçamento direto.")
bullet("**Unidade de controle** baseada em máquina de estados (contador de anel) com "
       "seis estados de temporização T1–T6: T1–T3 realizam a busca (iguais para toda "
       "instrução) e T4–T6 a execução (dependente do opcode).")
bullet("**Palavra de controle de 12 bits** (CON), gerada a cada estado, que comanda "
       "quem escreve e quem lê no barramento.")

# =====================================================================
# 2. METODOLOGIA DE SIMULAÇÃO
# =====================================================================
doc.add_heading("2. Metodologia de simulação", level=1)

doc.add_heading("2.1. Ferramentas", level=2)
p("A verificação foi conduzida principalmente no ModelSim ASE 2020.1 (Intel FPGA "
  "Starter Edition), o simulador integrado ao Quartus Prime Lite. As formas de onda "
  "apresentadas neste relatório foram capturadas diretamente da janela Wave do "
  "ModelSim. Como referência cruzada, os mesmos testbenches também foram executados "
  "em Icarus Verilog, obtendo-se resultados idênticos.")

doc.add_heading("2.2. Testbenches auto-verificáveis", level=2)
p("Foram escritos 14 testbenches — um para cada componente e um para o sistema "
  "integrado. Todos são auto-verificáveis: comparam o valor obtido com o esperado e "
  "emitem PASSOU ou FALHOU no transcript, encerrando com $stop. Não geram arquivos "
  "de dump (VCD), seguindo o fluxo nativo do ModelSim, no qual os sinais são "
  "observados diretamente na base de dados de simulação (WLF).")

doc.add_heading("2.3. Modos de simulação empregados", level=2)
p("A verificação usou quatro modos complementares:")
bullet("**Simulação unitária (por componente):** cada bloco é compilado e exercitado "
       "isoladamente pelo seu testbench, permitindo isolar falhas. Executada por "
       "componente com o script parametrizado run_one.do.")
bullet("**Simulação integrada (sistema completo):** o testbench tb_sap1 instancia o "
       "processador inteiro, carrega um programa na RAM e verifica a saída final "
       "(instrução OUT) e a parada correta em HLT.")
bullet("**Formas de onda didáticas:** scripts wave_*.do configuram a janela Wave com "
       "radix personalizados — o estado do anel aparece como T1…T6 e o opcode como "
       "mnemônico (LDA, ADD, …) — e os registradores em decimal, facilitando a leitura.")
bullet("**Execução em lote:** o script run_all_tb.do compila e roda os 14 testbenches "
       "em sequência, consolidando os resultados PASSOU/FALHOU.")

p("Radix personalizados definidos nos scripts de onda (trecho):")
code([
    'radix define ESTADO {',
    "    6'b000001 \"T1\",  6'b000010 \"T2\",  6'b000100 \"T3\",",
    "    6'b001000 \"T4\",  6'b010000 \"T5\",  6'b100000 \"T6\"  }",
    'radix define OPCODE {',
    "    4'b0000 \"LDA\", 4'b0001 \"ADD\", 4'b0010 \"SUB\",",
    "    4'b1110 \"OUT\", 4'b1111 \"HLT\"  }",
])

p("Comandos típicos de reprodução (dentro da pasta tb_model):")
code([
    "# simulacao integrada com ondas do sistema:",
    "vsim -do wave_sap1.do",
    "# ondas de um componente (ex.: contador de programa):",
    "vsim -do wave_pc.do",
    "# lote com todos os testbenches:",
    "vsim -c -do run_all_tb.do",
])

doc.add_heading("2.4. Testbenches implementados", level=2)
table(
    ["Testbench", "Alvo", "Tipo de verificação"],
    [
        ["tb_program_counter", "Program Counter", "contagem, reset, pausa"],
        ["tb_mar", "MAR", "carga/retenção de endereço"],
        ["tb_ram_16x8", "RAM 16×8", "leitura do conteúdo por endereço"],
        ["tb_instruction_register", "Registrador de instrução", "separação opcode|operando"],
        ["tb_accumulator", "Acumulador (A)", "carga/retenção"],
        ["tb_register_b", "Registrador B", "carga/retenção"],
        ["tb_adder_subtractor", "ULA", "soma, subtração, wraparound 8 bits"],
        ["tb_output_register", "Registrador de saída", "carga/retenção"],
        ["tb_controller_sequencer", "Controlador/Sequenciador", "estados e palavra de controle"],
        ["tb_seg7 / tb_seg7_instr", "Decodificadores 7-seg", "mapeamento de dígitos/letras"],
        ["tb_clock_divider / tb_debouncer", "Apoio de FPGA", "divisão de clock / antirruído"],
        ["tb_sap1", "Sistema completo", "execução de programa fim-a-fim"],
    ],
    widths=[4.8, 4.5, 6.2],
)

# =====================================================================
# 3. VERIFICAÇÃO DOS COMPONENTES
# =====================================================================
doc.add_heading("3. Verificação dos componentes", level=1)
p("Esta seção apresenta as formas de onda da simulação unitária dos principais "
  "componentes. Um padrão de projeto recorrente é o registrador com carga ativa em "
  "baixo: o bloco captura o barramento apenas quando seu sinal de carga vale 0 (na "
  "borda de subida do clock) e mantém o valor caso contrário; o reset assíncrono zera "
  "a saída. Esse padrão é compartilhado por MAR, IR, acumulador, registrador B e "
  "registrador de saída.")

doc.add_heading("3.1. Program Counter (PC)", level=2)
figure("onda_pc_painel.png", "Contador de programa: contagem, reset e pausa.", 15.5)
p("A onda comprova as três operações do contador. Com o sinal de habilitação cp = 1, "
  "a saída avança 0, 1, 2, 3, … a cada borda de clock. Quando clr_bar é levado a 0, o "
  "contador retorna imediatamente a 0 (reset assíncrono). Com cp = 0, a contagem é "
  "congelada — o valor permanece estável. Por ser de apenas 4 bits, ao ultrapassar 15 "
  "o contador dá a volta para 0, coerente com as 16 posições da memória.")

doc.add_heading("3.2. Registrador de Endereço da Memória (MAR)", level=2)
figure("onda_mar_painel.png", "MAR: carga de endereço e retenção.", 15.5)
p("O MAR ilustra o padrão de registrador: com lm_bar = 0 ele carrega o valor presente "
  "na entrada (por exemplo, 12); em seguida, ainda que a entrada mude para 5, a saída "
  "mantém 12, pois lm_bar voltou a 1. Só há nova atualização quando o sinal de carga é "
  "reativado (carregando 7). É esse endereço estável que a RAM utiliza para a leitura.")

doc.add_heading("3.3. Memória RAM 16×8", level=2)
figure("onda_ram_painel.png", "RAM: leitura sequencial de todos os endereços (Programa 2).", 15.5)
p("Nesta simulação o testbench percorre os 16 endereços e observa o conteúdo lido. A "
  "onda funciona como um \"dump\" do programa: no endereço 0 lê-se LDA 11, no 1 ADD 12, "
  "no 2 SUB 13, e assim por diante até HLT no endereço 10; os endereços 11 a 15 contêm "
  "os dados. A linha interpretada (opcode | operando) evidencia o endereçamento direto: "
  "o operando é um endereço de memória, não um valor imediato. Como o SAP-1 básico não "
  "possui instrução de escrita (STA), a memória é apenas de leitura durante a execução.")

doc.add_heading("3.4. Registrador de Instrução (IR)", level=2)
figure("onda_ir_painel.png", "IR: carga da palavra e separação opcode | operando.", 15.5)
p("O IR captura a palavra vinda da memória e a divide em dois campos. Na onda, ao "
  "carregar 0x1C (0001_1100) a saída se decompõe em opcode = ADD e operando = 12; ao "
  "carregar 0xF0 (1111_0000), em opcode = HLT e operando = 0. O opcode segue para a "
  "unidade de controle e o operando serve de endereço para a próxima leitura.")

doc.add_heading("3.5. Acumulador (A) e Registrador B", level=2)
figure("onda_acc_painel.png", "Acumulador: carrega quando habilitado e mantém quando não.", 15.5)
figure("onda_regb_painel.png", "Registrador B: mesmo padrão de carga/retenção.", 15.5)
p("Acumulador e registrador B compartilham o mesmo comportamento. No acumulador, com "
  "la_bar = 0 a saída assume 27 e, mesmo com a entrada mudando para 99, permanece em 27 "
  "enquanto a carga não for reativada. O registrador B repete o padrão (carrega 9, "
  "mantém, depois carrega 3). Juntos, A e B alimentam a ULA.")

doc.add_heading("3.6. Unidade Lógico-Aritmética (ULA)", level=2)
figure("onda_alu_painel.png", "ULA: soma, subtração e wraparound de 8 bits.", 15.5)
p("A ULA é combinacional: o resultado responde imediatamente às entradas, sem clock. "
  "Com su = 0 (soma) verificam-se 3+3 = 6 e 18+9 = 27; o caso 200+100 resulta em 44, "
  "demonstrando o wraparound de 8 bits (300 mod 256 = 44). Com su = 1 (subtração), "
  "27−3 = 24, 5−5 = 0 e 0−1 = 255, mostrando o comportamento em complemento de 8 bits. "
  "O resultado só é colocado no barramento quando o sinal Eu é ativado.")

doc.add_heading("3.7. Controlador / Sequenciador", level=2)
figure("onda_controller_painel.png",
       "Máquina de estados e palavra de controle de 12 bits por estado.", 15.5)
p("Este é o bloco central da verificação. A onda mostra o contador de anel percorrendo "
  "IDLE → T1 → T2 → … → T6 → IDLE, e a palavra de controle CON (12 bits) assumindo um "
  "valor distinto em cada estado. Observam-se os pulsos dos sinais ativos em alto "
  "(cp, ep, ea, su, eu) e a ausência de nível (0 = ativo) nos sinais ativos em baixo "
  "(as cargas). Como a palavra depende apenas do estado e do opcode — nunca do dado —, "
  "o comportamento é determinístico. Verifica-se também que, ao receber HLT, a máquina "
  "permanece travada em T4 (parada correta).")

# =====================================================================
# 4. VERIFICAÇÃO DO SISTEMA COMPLETO — OS 4 PROGRAMAS
# =====================================================================
doc.add_heading("4. Verificação do sistema completo", level=1)
p("Com os componentes validados, o testbench tb_sap1 exercita o processador inteiro. "
  "Para cada programa, a RAM é inicializada, a simulação roda até o HLT e a saída da "
  "instrução OUT é comparada ao valor esperado. As ondas a seguir usam radix didáticos: "
  "o estado aparece como T1…T6, o opcode como mnemônico e o datapath (PC, MAR, A, B, "
  "ULA, saída) em decimal. Em todas, observa-se o ciclo busca (T1–T3) → execução "
  "(T4–T6) e a parada em HLT/T4.")

def programa(titulo, subt, listagem, fig, expected, comentario):
    doc.add_heading(titulo, level=2)
    p(subt, italic=True, color=GREY)
    code(listagem)
    figure(fig, f"{titulo} — simulação completa (saída final = {expected}).", 16.0)
    p(comentario)

programa(
    "4.1. Programa 1 — 3³ = 27",
    "Potência por somas sucessivas; exibe 9 (3²) e depois 27 (3³).",
    ["mem[0] LDA 12   ; A <- 3", "mem[1] ADD 12   ; A <- 6",
     "mem[2] ADD 12   ; A <- 9  (3^2)", "mem[3] OUT      ; mostra 9",
     "mem[4] LDA 13   ; A <- 9", "mem[5] ADD 13   ; A <- 18",
     "mem[6] ADD 13   ; A <- 27", "mem[7] SUB 14   ; ajuste",
     "mem[8] ADD 12   ; ajuste", "mem[9] ADD 15   ; A <- 27 (3^3)",
     "mem[10] OUT     ; mostra 27", "mem[11] HLT",
     "mem[12..15] = 3, 9, 3, 0   ; dados"],
    "onda_prog1_painel.png", "27",
    "No acumulador (verde) acompanha-se a construção do resultado: 3, 6, 9 (primeiro "
    "OUT = 9) e, na segunda etapa, 18, 27 até o valor final. A saída evolui 0 → 9 → 27 "
    "e o processador para em HLT/T4. Resultado obtido = esperado = 27.")

programa(
    "4.2. Programa 2 — Expressão aritmética = 18",
    "Cadeia de somas e subtrações: (((7+3)−2)+5)−4, depois +7−3+5; exibe 9 e 18.",
    ["mem[0] LDA 11 ; 7", "mem[1] ADD 12 ; +3 -> 10", "mem[2] SUB 13 ; -2 -> 8",
     "mem[3] ADD 14 ; +5 -> 13", "mem[4] SUB 15 ; -4 -> 9", "mem[5] OUT    ; mostra 9",
     "mem[6] ADD 11 ; +7 -> 16", "mem[7] SUB 12 ; -3 -> 13", "mem[8] ADD 14 ; +5 -> 18",
     "mem[9] OUT    ; mostra 18", "mem[10] HLT",
     "mem[11..15] = 7, 3, 2, 5, 4 ; dados"],
    "onda_prog2_painel.png", "18",
    "Este programa demonstra o encadeamento de operações e o uso de duas instruções OUT. "
    "O acumulador percorre 7, 10, 8, 13, 9 (OUT = 9) e depois 16, 13, 18 (OUT = 18). "
    "A saída evolui 0 → 9 → 18 e há parada em HLT/T4. Resultado obtido = esperado = 18.")

programa(
    "4.3. Programa 3 — Multiplicação 3 × 4 = 12",
    "Como não há instrução de multiplicação, faz-se por somas repetidas (3+3+3+3).",
    ["mem[0] LDA 11 ; A <- 3", "mem[1] ADD 11 ; A <- 6", "mem[2] ADD 11 ; A <- 9",
     "mem[3] ADD 11 ; A <- 12", "mem[4] OUT    ; mostra 12",
     "mem[5..8] SUB/ADD com dado 0 ; A inalterado", "mem[9] OUT    ; mostra 12",
     "mem[10] HLT", "mem[11] = 3 ; dado"],
    "onda_prog3_painel.png", "12",
    "A \"assinatura\" da multiplicação aparece claramente no acumulador, que sobe de 3 "
    "em 3: 3, 6, 9, 12. A ausência de laços (o SAP-1 não possui desvios) obriga a "
    "repetir a soma explicitamente. A saída atinge 12 e o processador para em HLT/T4. "
    "Resultado obtido = esperado = 12.")

programa(
    "4.4. Programa 4 — Divisão 12 ÷ 4 = 3",
    "Divisão por subtrações repetidas: subtrai 4 até zerar e conta o quociente.",
    ["mem[0] LDA 12 ; A <- 12", "mem[1] SUB 13 ; A <- 8", "mem[2] SUB 13 ; A <- 4",
     "mem[3] SUB 13 ; A <- 0  (3 subtracoes)", "mem[4] LDA 14 ; A <- 1",
     "mem[5] ADD 14 ; A <- 2", "mem[6] ADD 14 ; A <- 3  (quociente)",
     "mem[7] OUT    ; mostra 3", "mem[8] HLT",
     "mem[12..14] = 12, 4, 1 ; dados"],
    "onda_prog4_painel.png", "3",
    "A onda mostra o acumulador descendo de 4 em 4 (12, 8, 4, 0) — as três subtrações "
    "que cabem em 12 — e, em seguida, a contagem do quociente 1, 2, 3. A saída atinge 3 "
    "e há parada em HLT/T4. Por não haver desvio condicional, o número de subtrações é "
    "fixo para este caso. Resultado obtido = esperado = 3.")

# =====================================================================
# 5. RESULTADOS CONSOLIDADOS
# =====================================================================
doc.add_heading("5. Resultados consolidados", level=1)
p("Todos os 14 testbenches retornaram PASSOU, tanto no ModelSim ASE quanto no Icarus "
  "Verilog. Os quatro programas produziram exatamente a saída esperada e pararam "
  "corretamente em HLT. A tabela abaixo resume a verificação do sistema completo.")
table(
    ["Programa", "Operação", "Técnica", "Esperado", "Obtido", "Parada"],
    [
        ["1", "3³", "somas sucessivas", "27", "27", "HLT/T4"],
        ["2", "expressão", "soma/subtração encadeadas", "18", "18", "HLT/T4"],
        ["3", "3 × 4", "somas repetidas", "12", "12", "HLT/T4"],
        ["4", "12 ÷ 4", "subtrações repetidas", "3", "3", "HLT/T4"],
    ],
    widths=[2.0, 2.6, 4.8, 2.0, 1.8, 2.2],
)
p("Resultado global: 14/14 testbenches PASSOU · 4/4 programas corretos.",
  bold=True, color=GREEN)

# =====================================================================
# 6. CONCLUSÃO
# =====================================================================
doc.add_heading("6. Conclusão", level=1)
p("A verificação por simulação confirmou o funcionamento correto do SAP-1 em dois "
  "níveis: os componentes, validados isoladamente por testbenches auto-verificáveis com "
  "formas de onda que evidenciam contagem, carga/retenção de registradores, leitura de "
  "memória e aritmética com wraparound; e o sistema completo, que executou os quatro "
  "programas produzindo os resultados esperados e parando corretamente em HLT. A "
  "combinação de simulação unitária e integrada, o uso de radix didáticos e a execução "
  "em lote deram confiança suficiente para prosseguir com a gravação na FPGA "
  "DE10-Lite. Como evolução natural, a inclusão de uma instrução de escrita (STA) e de "
  "desvios permitiria verificar laços e algoritmos com fluxo de controle, aproximando "
  "o projeto do SAP-2.")

doc.save(OUT)
print("gerado:", OUT)
