#!/usr/bin/env python3
# Gera datapath.png - diagrama de blocos do SAP-1 (datapath + barramento W)
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

fig, ax = plt.subplots(figsize=(13, 7.3))
ax.set_xlim(0, 13); ax.set_ylim(0, 7.3); ax.axis("off")

DARK="#0d3b66"; BLUE="#bbdefb"; GREEN="#c8e6c9"; ORANGE="#ffe0b2"; GREY="#e0e0e0"

def block(cx, cy, w, h, label, fc):
    ax.add_patch(FancyBboxPatch((cx-w/2, cy-h/2), w, h,
        boxstyle="round,pad=0.03,rounding_size=0.1", fc=fc, ec="black", lw=1.8, zorder=3))
    ax.text(cx, cy, label, ha="center", va="center", fontsize=11,
            fontweight="bold", zorder=4)

def to_bus(cx, top_y, bus_y, label, up):
    # up=True: bloco embaixo do barramento manda pra cima (fala) OU recebe
    y0, y1 = (top_y, bus_y) if up else (top_y, bus_y)
    ax.add_patch(FancyArrowPatch((cx, y0), (cx, y1), arrowstyle="-|>",
        mutation_scale=13, lw=1.6, color="#37474f", zorder=2))
    ymid=(y0+y1)/2
    ax.text(cx+0.18, ymid, label, ha="left", va="center", fontsize=8.5,
            color="#b71c1c", zorder=5)

BUS_Y=3.65
# ---- barramento ----
ax.plot([1.0,10.7],[BUS_Y,BUS_Y], color=DARK, lw=6, solid_capstyle="round", zorder=1)
ax.text(1.1, BUS_Y+0.28, "Barramento W (8 bits)", ha="left", fontsize=11,
        color=DARK, fontweight="bold")

# ---- blocos de cima ----
top_y=5.8
block(2.2, top_y, 1.7, 0.95, "PC\n(contador)", BLUE)
block(4.5, top_y, 1.7, 0.95, "MAR\n(endereço)", BLUE)
block(7.0, top_y, 1.9, 0.95, "RAM 16×8\n(memória)", BLUE)
block(9.6, top_y, 1.7, 0.95, "IR\n(instrução)", BLUE)

# setas cima <-> barramento
to_bus(2.2, top_y-0.48, BUS_Y+0.08, "Ep", up=False)      # PC fala
ax.add_patch(FancyArrowPatch((4.5,BUS_Y+0.08),(4.5,top_y-0.48), arrowstyle="-|>",
    mutation_scale=13, lw=1.6, color="#37474f", zorder=2))
ax.text(4.68,(BUS_Y+top_y-0.48)/2,"~Lm",ha="left",va="center",fontsize=8.5,color="#b71c1c")
to_bus(7.0, top_y-0.48, BUS_Y+0.08, "~CE", up=False)     # RAM fala
# IR: fala (~Ei) e ouve (~Li)
ax.add_patch(FancyArrowPatch((9.35,BUS_Y+0.08),(9.35,top_y-0.48), arrowstyle="-|>",
    mutation_scale=12, lw=1.5, color="#37474f", zorder=2))
ax.text(9.5,(BUS_Y+top_y-0.5)/2,"~Li",ha="left",fontsize=8,color="#b71c1c")
ax.add_patch(FancyArrowPatch((9.85,top_y-0.48),(9.85,BUS_Y+0.08), arrowstyle="-|>",
    mutation_scale=12, lw=1.5, color="#37474f", zorder=2))
ax.text(10.0,(BUS_Y+top_y-0.5)/2,"~Ei",ha="left",fontsize=8,color="#b71c1c")

# MAR -> RAM (endereço)
ax.add_patch(FancyArrowPatch((5.35,top_y),(6.05,top_y), arrowstyle="-|>",
    mutation_scale=13, lw=1.6, color="#1565c0", zorder=2))
ax.text(5.7, top_y+0.35, "endereço", ha="center", fontsize=8, color="#1565c0")

# ---- blocos de baixo ----
bot_y=1.5
block(2.2, bot_y, 1.7, 0.95, "Acumulador\nA", GREEN)
block(4.7, bot_y, 1.6, 0.95, "ALU\n(A ± B)", ORANGE)
block(7.0, bot_y, 1.6, 0.95, "Registrador\nB", GREEN)
block(9.6, bot_y, 1.7, 0.95, "Saída\n(displays)", GREY)

# A: ouve (~La) e fala (Ea)
ax.add_patch(FancyArrowPatch((2.0,BUS_Y-0.08),(2.0,bot_y+0.48), arrowstyle="-|>",
    mutation_scale=12, lw=1.5, color="#37474f", zorder=2))
ax.text(1.5,(BUS_Y+bot_y+0.5)/2,"~La",ha="right",fontsize=8,color="#b71c1c")
ax.add_patch(FancyArrowPatch((2.45,bot_y+0.48),(2.45,BUS_Y-0.08), arrowstyle="-|>",
    mutation_scale=12, lw=1.5, color="#37474f", zorder=2))
ax.text(2.6,(BUS_Y+bot_y+0.5)/2,"Ea",ha="left",fontsize=8,color="#b71c1c")
# ALU fala (Eu)
ax.add_patch(FancyArrowPatch((4.7,bot_y+0.48),(4.7,BUS_Y-0.08), arrowstyle="-|>",
    mutation_scale=13, lw=1.6, color="#37474f", zorder=2))
ax.text(4.88,(BUS_Y+bot_y+0.5)/2,"Eu",ha="left",fontsize=8.5,color="#b71c1c")
# B ouve (~Lb)
ax.add_patch(FancyArrowPatch((7.0,BUS_Y-0.08),(7.0,bot_y+0.48), arrowstyle="-|>",
    mutation_scale=13, lw=1.6, color="#37474f", zorder=2))
ax.text(7.18,(BUS_Y+bot_y+0.5)/2,"~Lb",ha="left",fontsize=8.5,color="#b71c1c")
# Saída ouve (~Lo)
ax.add_patch(FancyArrowPatch((9.6,BUS_Y-0.08),(9.6,bot_y+0.48), arrowstyle="-|>",
    mutation_scale=13, lw=1.6, color="#37474f", zorder=2))
ax.text(9.78,(BUS_Y+bot_y+0.5)/2,"~Lo",ha="left",fontsize=8.5,color="#b71c1c")

# A -> ALU e B -> ALU
ax.add_patch(FancyArrowPatch((3.05,bot_y),(3.9,bot_y), arrowstyle="-|>",
    mutation_scale=12, lw=1.5, color="#2e7d32", zorder=2))
ax.add_patch(FancyArrowPatch((6.2,bot_y),(5.5,bot_y), arrowstyle="-|>",
    mutation_scale=12, lw=1.5, color="#2e7d32", zorder=2))

# ---- unidade de controle ----
block(11.85, 2.15, 2.0, 2.3, "Unidade de\nControle\n(sequenciador)", "#f3e5f5")
ax.text(11.85, 0.85, "gera os 12 sinais\nde controle (CON)", ha="center",
        fontsize=8, color="#6a1b9a")
# IR opcode -> controle
ax.add_patch(FancyArrowPatch((10.45,top_y-0.2),(11.6,3.1),
    connectionstyle="arc3,rad=0.25", arrowstyle="-|>", mutation_scale=12, lw=1.5,
    color="#6a1b9a", zorder=2))
ax.text(10.7, top_y-0.15, "opcode", ha="left", fontsize=8, color="#6a1b9a")

ax.text(6.5, 7.05, "Datapath do SAP-1", ha="center", fontsize=16, fontweight="bold",
        color=DARK)
ax.text(6.5, 0.35,
    "Azul = busca/memória   ·   Verde = aritmética   ·   Vermelho = sinais de controle (enables)",
    ha="center", fontsize=9)

plt.tight_layout()
plt.savefig("datapath.png", dpi=160, bbox_inches="tight")
print("gerado: datapath.png")
