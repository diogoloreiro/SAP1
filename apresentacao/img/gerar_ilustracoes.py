#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Gera ilustracoes extras para o relatorio de implementacao do SAP-1:
#   timing_two_edge.png   - disciplina de duas bordas (negedge/posedge)
#   control_word.png      - layout da palavra de controle de 12 bits
#   memory_map.png        - mapa dos 16 slots (programa x dados)
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle, FancyArrowPatch
import numpy as np

DARK="#0d3b66"; BLUE="#1565c0"; ORANGE="#e65100"
LB="#bbdefb"; LO="#ffe0b2"; LG="#c8e6c9"; GREY="#eceff1"

# =====================================================================
# 1) DIAGRAMA DE TEMPORIZACAO DE DUAS BORDAS
# =====================================================================
def timing():
    fig, ax = plt.subplots(figsize=(12, 5.6))
    ax.set_xlim(0, 12); ax.set_ylim(0, 5.6); ax.axis("off")
    ax.text(6, 5.3, "Disciplina de duas bordas — ciclo de busca (T1–T3)",
            ha="center", fontsize=15, fontweight="bold", color=DARK)

    per = 3.0; x0 = 1.6
    yb, yt = 4.0, 4.7
    # clock: NEGEDGE na borda da caixa (x0+k*per) e POSEDGE no meio (x0+k*per+per/2)
    #   -> LOW na 1a metade do estado, HIGH na 2a metade
    xs=[x0-0.45, x0, x0]; ys=[yt, yt, yb]
    for k in range(3):
        xa=x0+k*per
        xs += [xa+per/2, xa+per/2, xa+per, xa+per]
        ys += [yb, yt, yt, yb]
    ys[-1]=yt; xs[-1]=x0+3*per   # termina alto no fim
    ax.plot(xs, ys, color="black", lw=2)
    ax.text(x0-1.5, (yb+yt)/2, "clk", ha="left", va="center", fontsize=12,
            fontweight="bold", color="#f9a825")

    # linhas de borda (negedge = limites) e meio (posedge)
    for k in range(4):
        ax.axvline(x0+k*per, ymin=0.06, ymax=0.86, color=BLUE, ls="--", lw=1.1, alpha=.7)
    for k in range(3):
        ax.axvline(x0+k*per+per/2, ymin=0.06, ymax=0.86, color=ORANGE, ls=":", lw=1.4, alpha=.85)

    # --- estado: caixas que trocam nas bordas (negedge) ---
    ye0, ye1 = 2.9, 3.6
    labels=["T1","T2","T3"]
    for k in range(3):
        xa=x0+k*per
        ax.add_patch(Rectangle((xa, ye0), per, ye1-ye0, fc=LB, ec=DARK, lw=1.4))
        ax.text(xa+per/2, (ye0+ye1)/2, labels[k], ha="center", va="center",
                fontsize=13, fontweight="bold")
    ax.text(x0-1.5, (ye0+ye1)/2, "estado", ha="left", va="center", fontsize=12,
            fontweight="bold", color=DARK)

    # --- microoperacao efetivada no POSEDGE (meio do estado) ---
    ym0, ym1 = 1.6, 2.3
    ops=["MAR ← PC","PC ← PC+1","IR ← RAM"]
    for k in range(3):
        cx=x0+k*per+per/2   # posedge = meio da caixa do estado
        ax.add_patch(FancyBboxPatch((cx-1.05, ym0), 2.1, ym1-ym0,
            boxstyle="round,pad=0.02,rounding_size=0.08", fc=LG, ec="#2e7d32", lw=1.3))
        ax.text(cx, (ym0+ym1)/2, ops[k], ha="center", va="center", fontsize=10.5,
                fontweight="bold")
        ax.annotate("", xy=(cx, ym1+0.55), xytext=(cx, ym1+0.02),
                    arrowprops=dict(arrowstyle="-|>", color=ORANGE, lw=1.7))
    ax.text(x0-1.5, (ym0+ym1)/2, "carrega\n(posedge)", ha="left", va="center",
            fontsize=10.5, fontweight="bold", color="#2e7d32")

    # legenda
    ax.plot([1.2,1.9],[0.72,0.72], color=BLUE, ls="--", lw=1.3)
    ax.text(2.0,0.72,"negedge (borda): o estado avança", va="center", fontsize=10, color=BLUE)
    ax.plot([6.4,7.1],[0.72,0.72], color=ORANGE, ls=":", lw=1.6)
    ax.text(7.2,0.72,"posedge (meio): os registradores carregam", va="center", fontsize=10, color=ORANGE)
    ax.text(6,0.22,"A palavra de controle de Tn já está estável quando chega o posedge que efetiva a transferência.",
            ha="center", fontsize=9.5, style="italic", color="#455a64")

    plt.tight_layout()
    fig.savefig("timing_two_edge.png", dpi=155, bbox_inches="tight")
    plt.close(fig); print("gerado: timing_two_edge.png")

# =====================================================================
# 2) LAYOUT DA PALAVRA DE CONTROLE (12 bits)
# =====================================================================
def control_word():
    bits = [
        ("Cp","alto","PC++"), ("Ep","alto","PC→bus"),
        ("~Lm","baixo","carrega MAR"), ("~CE","baixo","RAM→bus"),
        ("~Li","baixo","carrega IR"), ("~Ei","baixo","oper→bus"),
        ("~La","baixo","carrega A"), ("Ea","alto","A→bus"),
        ("Su","alto","subtrai"), ("Eu","alto","ULA→bus"),
        ("~Lb","baixo","carrega B"), ("~Lo","baixo","carrega saída"),
    ]
    fig, ax = plt.subplots(figsize=(13, 3.6))
    ax.set_xlim(0, 12); ax.set_ylim(0, 3.6); ax.axis("off")
    ax.text(6, 3.35, "Palavra de controle CON (12 bits)", ha="center",
            fontsize=15, fontweight="bold", color=DARK)
    ax.text(6, 3.02, "MSB (bit 11)  →  LSB (bit 0)", ha="center", fontsize=9.5, color="#607d8b")
    w=1.0
    for i,(name,lvl,fn) in enumerate(bits):
        binv = 11-i  # numero do bit
        x=i*w
        fc = LB if lvl=="alto" else LO
        ec = BLUE if lvl=="alto" else ORANGE
        ax.add_patch(Rectangle((x,1.5),w,1.0, fc=fc, ec=ec, lw=1.6))
        ax.text(x+w/2, 2.12, name, ha="center", va="center", fontsize=11.5, fontweight="bold")
        ax.text(x+w/2, 1.72, f"bit {binv}", ha="center", va="center", fontsize=8, color="#546e7a")
        ax.text(x+w/2, 1.28, fn, ha="center", va="top", fontsize=7.6, color="#37474f")
    # legenda
    ax.add_patch(Rectangle((2.7,0.35),0.5,0.35, fc=LB, ec=BLUE, lw=1.4))
    ax.text(3.3,0.52,"ativo em ALTO (1 = ativo)", va="center", fontsize=10, color=BLUE)
    ax.add_patch(Rectangle((6.7,0.35),0.5,0.35, fc=LO, ec=ORANGE, lw=1.4))
    ax.text(7.3,0.52,"ativo em BAIXO (0 = ativo)", va="center", fontsize=10, color=ORANGE)
    ax.text(6,0.02,"Repouso = 0011_1110_0011 (cargas em 1 = inativas).",
            ha="center", fontsize=9, style="italic", color="#455a64")
    plt.tight_layout()
    fig.savefig("control_word.png", dpi=155, bbox_inches="tight")
    plt.close(fig); print("gerado: control_word.png")

# =====================================================================
# 3) MAPA DE MEMORIA (16 slots) - Programa 2
# =====================================================================
def memory_map():
    prog = [
        ("0","LDA 11","instr"),("1","ADD 12","instr"),("2","SUB 13","instr"),
        ("3","ADD 14","instr"),("4","SUB 15","instr"),("5","OUT","instr"),
        ("6","ADD 11","instr"),("7","SUB 12","instr"),("8","ADD 14","instr"),
        ("9","OUT","instr"),("10","HLT","instr"),
        ("11","7","dado"),("12","3","dado"),("13","2","dado"),
        ("14","5","dado"),("15","4","dado"),
    ]
    fig, ax = plt.subplots(figsize=(7.6, 8.8))
    ax.set_xlim(0, 6); ax.set_ylim(-0.5, 17.4); ax.axis("off")
    ax.text(3, 16.9, "Mapa da memória 16×8 — Programa 2", ha="center",
            fontsize=14, fontweight="bold", color=DARK)
    ax.text(3, 16.4, "programa e dados compartilham os 16 slots (Von Neumann)",
            ha="center", fontsize=9.5, color="#607d8b")
    hx=1.0
    for k,(addr,txt,kind) in enumerate(prog):
        y=15-k   # 0 no topo
        fc = LB if kind=="instr" else LG
        ax.add_patch(Rectangle((1.4,y),3.2,0.9, fc=fc, ec=DARK, lw=1.2))
        ax.text(1.1,y+0.45, addr, ha="right", va="center", fontsize=10, color="#455a64")
        ax.text(3.0,y+0.45, txt, ha="center", va="center", fontsize=11, fontweight="bold")
    # chaves de regiao
    ax.annotate("", xy=(4.85,15.0), xytext=(4.85,5.0),
                arrowprops=dict(arrowstyle="-", color=BLUE, lw=2.2))
    ax.text(5.0,10.0,"PROGRAMA\n(0–10)", ha="left", va="center", fontsize=10.5,
            fontweight="bold", color=BLUE, rotation=0)
    ax.annotate("", xy=(4.85,4.0), xytext=(4.85,-0.0),
                arrowprops=dict(arrowstyle="-", color="#2e7d32", lw=2.2))
    ax.text(5.0,2.0,"DADOS\n(11–15)", ha="left", va="center", fontsize=10.5,
            fontweight="bold", color="#2e7d32")
    ax.text(3,-0.9,"Endereço de 4 bits ⇒ 16 posições. Programa maior ⇒ menos espaço para dados.",
            ha="center", fontsize=9, style="italic", color="#455a64")
    plt.tight_layout()
    fig.savefig("memory_map.png", dpi=155, bbox_inches="tight")
    plt.close(fig); print("gerado: memory_map.png")

# =====================================================================
# 4) HIERARQUIA DE MODULOS
# =====================================================================
def hierarchy():
    fig, ax = plt.subplots(figsize=(12, 7.2))
    ax.set_xlim(0, 12); ax.set_ylim(0, 7.2); ax.axis("off")
    ax.text(6, 6.9, "Hierarquia de módulos", ha="center", fontsize=15,
            fontweight="bold", color=DARK)

    def box(cx, cy, w, h, label, fc, ec="black", fs=10, bold=True):
        ax.add_patch(FancyBboxPatch((cx-w/2, cy-h/2), w, h,
            boxstyle="round,pad=0.02,rounding_size=0.06", fc=fc, ec=ec, lw=1.5, zorder=3))
        ax.text(cx, cy, label, ha="center", va="center", fontsize=fs,
                fontweight="bold" if bold else "normal", zorder=4)

    def link(x1,y1,x2,y2):
        ax.add_patch(FancyArrowPatch((x1,y1),(x2,y2), arrowstyle="-",
            mutation_scale=1, lw=1.2, color="#78909c", zorder=1))

    # topo de placa
    box(6, 6.25, 3.4, 0.6, "sap1_fpga  (top de placa)", "#f3e5f5", "#6a1b9a", 11)
    # camada fpga (esquerda) e nucleo (centro/direita)
    box(2.3, 5.0, 3.2, 0.55, "clock_divider · debouncer", LO, ORANGE, 9.5)
    box(2.3, 4.3, 3.2, 0.55, "reset sync · seg7 · seg7_instr", LO, ORANGE, 9.5)
    box(7.4, 5.0, 3.6, 0.6, "sap1_top  (núcleo)", LB, DARK, 11)
    link(6,5.95,2.3,5.28); link(6,5.95,2.3,4.58); link(6,5.95,7.4,5.3)

    # componentes do nucleo (grade)
    comps = [
        "program_counter","mar","ram_16x8",
        "instruction_register","accumulator","register_b",
        "adder_subtractor","output_register","controller_sequencer",
    ]
    x0=2.4; y0=3.1; dx=3.6; dy=0.85; cols=3
    for i,c in enumerate(comps):
        r=i//cols; col=i%cols
        cx=x0+col*dx; cy=y0-r*dy
        box(cx, cy, 3.3, 0.6, c, LB, DARK, 9.2)
        link(7.4,4.7,cx,cy+0.3)
    ax.text(6,0.55,"controller_fsm.v é uma implementação ALTERNATIVA do controle (mesmas "
            "portas) — trocável no topo.", ha="center", fontsize=8.6, style="italic",
            color="#455a64")
    ax.text(2.3,5.55,"camada de placa (fpga/)", ha="center", fontsize=8.5, color=ORANGE)
    ax.text(7.4,5.5,"instancia os 9 blocos do núcleo (rtl/)", ha="center", fontsize=8.5, color=DARK)
    plt.tight_layout()
    fig.savefig("module_hierarchy.png", dpi=155, bbox_inches="tight")
    plt.close(fig); print("gerado: module_hierarchy.png")

# =====================================================================
# 5) FLUXO DO ADD NO BARRAMENTO (T1..T6)
# =====================================================================
def add_flow():
    steps = [
        ("T1","PC","MAR","busca","Ep, ~Lm"),
        ("T2","(PC++)","—","busca","Cp"),
        ("T3","RAM","IR","busca","~CE, ~Li"),
        ("T4","operando do IR","MAR","exec","~Lm, ~Ei"),
        ("T5","RAM (o dado)","B","exec","~CE, ~Lb"),
        ("T6","ULA (A+B)","A","exec","~La, Eu"),
    ]
    fig, ax = plt.subplots(figsize=(11, 7.4))
    ax.set_xlim(0, 11); ax.set_ylim(0, 7.4); ax.axis("off")
    ax.text(5.5, 7.05, "Execução de um ADD — transferências no barramento W",
            ha="center", fontsize=15, fontweight="bold", color=DARK)
    ytop=6.2; dy=0.95
    for i,(st,src,dst,cyc,sig) in enumerate(steps):
        y=ytop-i*dy
        fc = LB if cyc=="busca" else LG
        ec = DARK if cyc=="busca" else "#2e7d32"
        # estado
        ax.add_patch(FancyBboxPatch((0.4,y-0.32),0.95,0.64,
            boxstyle="round,pad=0.02,rounding_size=0.08", fc=fc, ec=ec, lw=1.6))
        ax.text(0.875,y,st, ha="center", va="center", fontsize=12, fontweight="bold")
        # fonte
        ax.add_patch(Rectangle((1.9,y-0.3),2.5,0.6, fc="white", ec=ec, lw=1.3))
        ax.text(3.15,y,src, ha="center", va="center", fontsize=10.5, fontweight="bold")
        # seta com rotulo "barramento W"
        ax.add_patch(FancyArrowPatch((4.5,y),(6.7,y), arrowstyle="-|>",
            mutation_scale=15, lw=1.8, color="#b71c1c"))
        ax.text(5.6,y+0.22,"barramento W", ha="center", fontsize=7.6, color="#b71c1c")
        # destino
        if dst=="—":
            ax.text(7.9,y,"(sem transferência)", ha="center", va="center",
                    fontsize=9.5, style="italic", color="#78909c")
        else:
            ax.add_patch(Rectangle((6.8,y-0.3),2.2,0.6, fc=fc, ec=ec, lw=1.4))
            ax.text(7.9,y,dst, ha="center", va="center", fontsize=10.5, fontweight="bold")
        # sinais ativos
        ax.text(10.6,y,sig, ha="right", va="center", fontsize=9, color="#37474f")
    ax.text(0.875, ytop+0.62,"estado", ha="center", fontsize=8.5, color="#607d8b")
    ax.text(3.15, ytop+0.62,"fala (fonte)", ha="center", fontsize=8.5, color="#607d8b")
    ax.text(7.9, ytop+0.62,"ouve (destino)", ha="center", fontsize=8.5, color="#607d8b")
    ax.text(10.6, ytop+0.62,"sinais", ha="right", fontsize=8.5, color="#607d8b")
    # legenda cores
    ax.add_patch(Rectangle((2.0,0.35),0.4,0.3, fc=LB, ec=DARK, lw=1.2))
    ax.text(2.5,0.5,"busca (T1–T3, igual p/ toda instrução)", va="center", fontsize=9, color=DARK)
    ax.add_patch(Rectangle((6.6,0.35),0.4,0.3, fc=LG, ec="#2e7d32", lw=1.2))
    ax.text(7.1,0.5,"execução (T4–T6)", va="center", fontsize=9, color="#2e7d32")
    ax.text(5.5,0.02,"A só é reescrito no posedge de T6 → o novo valor aparece já no T1 seguinte.",
            ha="center", fontsize=8.8, style="italic", color="#455a64")
    plt.tight_layout()
    fig.savefig("add_flow.png", dpi=155, bbox_inches="tight")
    plt.close(fig); print("gerado: add_flow.png")

# =====================================================================
# 6) MAPA GERAL DAS ENTIDADES (cards)
# =====================================================================
def entity_map():
    ents = [
        ("Barramento W", "via única de 8 bits", "um escreve · vários leem", DARK, "#e3f2fd"),
        ("Controlador / Sequenciador", "FSM T1–T6; gera a palavra CON", "recebe opcode", "#6a1b9a", "#f3e5f5"),
        ("PC (contador)", "endereço da próxima instrução (4b)", "Cp: ++  ·  Ep: escreve", DARK, LB),
        ("MAR (endereço)", "retém o endereço para a RAM", "~Lm: carrega", DARK, LB),
        ("RAM 16×8", "programa + dados (só leitura)", "~CE: escreve", DARK, LB),
        ("IR (instrução)", "guarda instr.; separa opcode|operando", "~Li: carrega  ·  ~Ei: operando", DARK, LB),
        ("Acumulador A", "registrador de trabalho (8b)", "~La: carrega  ·  Ea: escreve", "#2e7d32", LG),
        ("Registrador B", "2º operando da ULA", "~Lb: carrega", "#2e7d32", LG),
        ("ULA (A ± B)", "soma/subtrai (combinacional)", "Su: modo  ·  Eu: escreve", ORANGE, LO),
        ("Registrador de saída", "resultado no visor", "~Lo: carrega", "#455a64", GREY),
    ]
    fig, ax = plt.subplots(figsize=(12.5, 10.2))
    ax.set_xlim(0, 12.5); ax.set_ylim(0, 10.2); ax.axis("off")
    ax.text(6.25, 9.9, "Mapa geral das entidades", ha="center", fontsize=16,
            fontweight="bold", color=DARK)
    ax.text(6.25, 9.55, "cada bloco: função · sinais que o comandam",
            ha="center", fontsize=10, color="#607d8b")
    cols=2; cw=5.8; ch=1.28; x0=0.5; y0=8.7; gx=0.35; gy=0.2
    for i,(name,role,sig,ec,fc) in enumerate(ents):
        r=i//cols; c=i%cols
        x=x0+c*(cw+gx); y=y0-r*(ch+gy)
        ax.add_patch(FancyBboxPatch((x,y-ch),cw,ch,
            boxstyle="round,pad=0.02,rounding_size=0.06", fc=fc, ec=ec, lw=1.8, zorder=3))
        ax.text(x+0.25, y-0.30, name, ha="left", va="center", fontsize=11.5,
                fontweight="bold", color=ec, zorder=4)
        ax.text(x+0.25, y-0.66, role, ha="left", va="center", fontsize=9.3,
                color="#263238", zorder=4)
        ax.text(x+0.25, y-1.00, sig, ha="left", va="center", fontsize=8.6,
                color="#b71c1c", zorder=4)
    ax.text(6.25,0.5,"Azul = busca/memória · Verde = aritmética · Laranja = ULA · "
            "Roxo = controle · Cinza = saída. Vermelho = sinais de controle.",
            ha="center", fontsize=8.6, style="italic", color="#455a64")
    plt.tight_layout()
    fig.savefig("entity_map.png", dpi=155, bbox_inches="tight")
    plt.close(fig); print("gerado: entity_map.png")

if __name__ == "__main__":
    timing(); control_word(); memory_map(); hierarchy(); add_flow(); entity_map()
