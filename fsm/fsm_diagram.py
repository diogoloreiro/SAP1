#!/usr/bin/env python3
# =============================================================
# fsm_diagram.py - Desenha o diagrama de estados da FSM do
#                  controlador/sequenciador do SAP-1.
#
# Gera 'fsm_diagram.png' a partir da maquina implementada em
# controller_fsm.v / controller_sequencer.v:
#
#   IDLE -> T1 -> T2 -> T3 -> T4 -> T5 -> T6 -> T1 ...
#
#   - IDLE  : estado ocioso de partida (absorve a fase do reset)
#   - T1..T3: ciclo de BUSCA  (igual para toda instrucao)
#   - T4..T6: ciclo de EXECUCAO (saida depende do opcode)
#   - HLT    : se opcode==HLT em T4, run=0 e a FSM congela
#
# Uso:  python3 fsm_diagram.py
# =============================================================
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch

# ---- sinais ativos (saidas de Moore) em cada estado ----
#      (do always de saida do controlador)
outputs = {
    "IDLE": "(ocioso)\nnenhum sinal",
    "T1":   "Ep, ~Lm\n(PC -> MAR)",
    "T2":   "Cp\n(PC++)",
    "T3":   "~CE, ~Li\n(RAM -> IR)",
    "T4":   "LDA/ADD/SUB: ~Lm,~Ei\nOUT: Ea,~Lo",
    "T5":   "LDA: ~CE,~La\nADD/SUB: ~CE,~Lb",
    "T6":   "ADD: ~La,Eu\nSUB: ~La,Eu,Su",
}

# ---- cores por fase do ciclo ----
colors = {
    "IDLE": "#cfd8dc",
    "T1": "#bbdefb", "T2": "#bbdefb", "T3": "#bbdefb",   # BUSCA  (azul)
    "T4": "#c8e6c9", "T5": "#c8e6c9", "T6": "#c8e6c9",   # EXEC   (verde)
}

fig, ax = plt.subplots(figsize=(11, 9))
ax.set_xlim(-7, 7)
ax.set_ylim(-7, 7)
ax.set_aspect("equal")
ax.axis("off")

# ---- T1..T6 dispostos em hexagono; IDLE a esquerda ----
R = 4.2
ring = ["T1", "T2", "T3", "T4", "T5", "T6"]
pos = {}
# T1 no topo, girando no sentido horario
for i, s in enumerate(ring):
    ang = np.pi/2 - i * (2*np.pi/6)
    pos[s] = (R*np.cos(ang), R*np.sin(ang))
pos["IDLE"] = (-6.3, 5.0)

node_r = 1.05

def draw_node(name):
    x, y = pos[name]
    ax.add_patch(Circle((x, y), node_r, facecolor=colors[name],
                        edgecolor="black", lw=1.8, zorder=3))
    ax.text(x, y + 0.30, name, ha="center", va="center",
            fontsize=13, fontweight="bold", zorder=4)
    ax.text(x, y - 0.42, outputs[name], ha="center", va="center",
            fontsize=6.4, zorder=4)

def arrow(a, b, color="black", rad=0.0, label=None, lcolor=None, loff=(0, 0)):
    xa, ya = pos[a]
    xb, yb = pos[b]
    p = FancyArrowPatch((xa, ya), (xb, yb),
                        connectionstyle=f"arc3,rad={rad}",
                        arrowstyle="-|>", mutation_scale=18,
                        lw=1.8, color=color,
                        shrinkA=26, shrinkB=26, zorder=2)
    ax.add_patch(p)
    if label:
        mx, my = (xa + xb) / 2.0, (ya + yb) / 2.0
        # desloca o rotulo para fora do arco
        nx, ny = (yb - ya), -(xb - xa)
        norm = (nx**2 + ny**2) ** 0.5
        nx, ny = nx / norm, ny / norm
        ax.text(mx + nx * 0.55 + loff[0], my + ny * 0.55 + loff[1], label,
                ha="center", va="center", fontsize=6.6,
                color=lcolor or color, zorder=5,
                bbox=dict(boxstyle="round,pad=0.15", fc="white",
                          ec="none", alpha=0.85))

for n in pos:
    draw_node(n)

# ---- transicoes do anel: T1->T2->...->T6->T1 ----
#      todas avancam no negedge clk, desde que run=1 (nao halted)
for i in range(len(ring)):
    lbl = "negedge clk\n& run" if i == 0 else None
    arrow(ring[i], ring[(i + 1) % len(ring)], color="#1565c0",
          rad=-0.18, label=lbl, lcolor="#1565c0")

# ---- partida: IDLE -> T1 ----
arrow("IDLE", "T1", color="#37474f", rad=-0.1,
      label="negedge clk", lcolor="#37474f", loff=(0, 0.3))

# ---- seta de reset entrando em IDLE ----
xi, yi = pos["IDLE"]
ax.add_patch(FancyArrowPatch((xi - 2.2, yi + 1.6), (xi - 0.55, yi + 0.6),
             arrowstyle="-|>", mutation_scale=18, lw=1.8,
             color="#b71c1c", zorder=2))
ax.text(xi - 2.4, yi + 1.9, "~CLR=0\n(reset assinc.)", ha="center",
        fontsize=8, color="#b71c1c")

# ---- HLT: auto-laco em T4 (congela quando opcode==HLT) ----
xt4, yt4 = pos["T4"]
ax.add_patch(FancyArrowPatch((xt4 + 0.7, yt4 - 0.7), (xt4 + 0.9, yt4 + 0.4),
             connectionstyle="arc3,rad=2.6",
             arrowstyle="-|>", mutation_scale=15, lw=1.6,
             color="#6a1b9a", zorder=2))
ax.text(xt4 + 2.3, yt4 - 0.2, "opcode=HLT\n=> run=0\n(congela)",
        ha="left", fontsize=8, color="#6a1b9a")

# ---- legenda ----
ax.text(0, 6.4, "FSM do Controlador/Sequenciador  -  SAP-1",
        ha="center", fontsize=15, fontweight="bold")
ax.text(0, -6.4,
        "Azul = ciclo de BUSCA (T1-T3, igual p/ toda instrucao)     "
        "Verde = ciclo de EXECUCAO (T4-T6, depende do opcode)\n"
        "Estado avanca na borda de DESCIDA do clock; registradores carregam na SUBIDA.",
        ha="center", fontsize=8.5)

plt.tight_layout()
for ext in ("png", "pdf", "svg"):
    out = f"fsm_diagram.{ext}"
    plt.savefig(out, dpi=160, bbox_inches="tight")
    print(f"Diagrama salvo em: {out}")
