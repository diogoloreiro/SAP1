#!/usr/bin/env python3
# =============================================================
# fsm_trace_diagram.py - Trace da FSM do SAP-1 sobre o exemplo
#                        do FSM_explicacao.md (e do ram_16x8.v).
#
# Percorre as 3 primeiras instrucoes do programa 3^3:
#       LDA 12 ; ADD 12 ; ADD 12
# mostrando, estado por estado (T1..T6), os sinais ativos, a
# transferencia de registradores e o acumulador A indo 0->3->6->9.
#
# Gera: fsm_trace_diagram.{png,pdf,svg}
# Uso:  python3 fsm_trace_diagram.py
# =============================================================
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

# Cada instrucao = lista de 6 micropassos (T1..T6).
# (Tn, sinais, transferencia, A_apos)  -- A_apos=None se A nao muda
# fase: "F" busca (azul), "E" execucao (verde), "I" idle (cinza)
instrs = [
    ("LDA 12   (PC=0)   A: 0 -> 3", [
        ("T1", "Ep, ~Lm",  "MAR <- PC(0)",        None, "F"),
        ("T2", "Cp",       "PC <- 1",             None, "F"),
        ("T3", "~CE, ~Li", "IR <- RAM[0]=LDA 12", None, "F"),
        ("T4", "~Lm, ~Ei", "MAR <- 12",           None, "E"),
        ("T5", "~CE, ~La", "A <- RAM[12]=3",       3,   "E"),
        ("T6", "(idle)",   "--",                  None, "I"),
    ]),
    ("ADD 12   (PC=1)   A: 3 -> 6", [
        ("T1", "Ep, ~Lm",  "MAR <- PC(1)",        None, "F"),
        ("T2", "Cp",       "PC <- 2",             None, "F"),
        ("T3", "~CE, ~Li", "IR <- RAM[1]=ADD 12", None, "F"),
        ("T4", "~Lm, ~Ei", "MAR <- 12",           None, "E"),
        ("T5", "~CE, ~Lb", "B <- RAM[12]=3",      None, "E"),
        ("T6", "~La, Eu",  "A <- A+B = 6",         6,   "E"),
    ]),
    ("ADD 12   (PC=2)   A: 6 -> 9  (= 3^2)", [
        ("T1", "Ep, ~Lm",  "MAR <- PC(2)",        None, "F"),
        ("T2", "Cp",       "PC <- 3",             None, "F"),
        ("T3", "~CE, ~Li", "IR <- RAM[2]=ADD 12", None, "F"),
        ("T4", "~Lm, ~Ei", "MAR <- 12",           None, "E"),
        ("T5", "~CE, ~Lb", "B <- RAM[12]=3",      None, "E"),
        ("T6", "~La, Eu",  "A <- A+B = 9",         9,   "E"),
    ]),
]

BLUE, GREEN, GRAY = "#bbdefb", "#c8e6c9", "#eceff1"
PHASE = {"F": BLUE, "E": GREEN, "I": GRAY}
HILITE = "#ffe082"  # destaque onde A muda

cw, ch = 2.7, 1.55          # largura/altura da celula
gx, gy = 0.45, 1.35         # espacos horizontal/vertical
x0, y_top = 0.8, 12.5
n_cols = 6

fig_w = x0 + n_cols * (cw + gx) + 3.4
fig_h = y_top + 1.6
fig, ax = plt.subplots(figsize=(fig_w, fig_h))
ax.set_xlim(0, fig_w)
ax.set_ylim(0, fig_h)
ax.axis("off")

def cell_xy(row, col):
    x = x0 + col * (cw + gx)
    y = y_top - row * (ch + gy)
    return x, y

def varrow(x1, y1, x2, y2, color="#455a64", rad=0.0):
    ax.add_patch(FancyArrowPatch((x1, y1), (x2, y2),
                 connectionstyle=f"arc3,rad={rad}",
                 arrowstyle="-|>", mutation_scale=15, lw=1.5,
                 color=color, zorder=2))

a_running = 0
for r, (title, steps) in enumerate(instrs):
    x_first, y = cell_xy(r, 0)
    # titulo da instrucao
    ax.text(x_first, y + ch / 2 + 0.42, title, ha="left", va="center",
            fontsize=12, fontweight="bold", color="#37474f")
    for c, (tn, sig, xfer, a_after, phase) in enumerate(steps):
        x, _ = cell_xy(r, c)
        fc = HILITE if a_after is not None else PHASE[phase]
        ec = "#f57f17" if a_after is not None else "black"
        lw = 2.6 if a_after is not None else 1.4
        ax.add_patch(FancyBboxPatch((x, y - ch / 2), cw, ch,
                     boxstyle="round,pad=0.04,rounding_size=0.12",
                     fc=fc, ec=ec, lw=lw, zorder=3))
        ax.text(x + cw / 2, y + ch / 2 - 0.27, tn, ha="center",
                va="center", fontsize=12, fontweight="bold", zorder=4)
        ax.text(x + cw / 2, y + 0.02, sig, ha="center", va="center",
                fontsize=8, color="#1a237e", zorder=4)
        ax.text(x + cw / 2, y - 0.34, xfer, ha="center", va="center",
                fontsize=7.6, zorder=4)
        if a_after is not None:
            ax.text(x + cw / 2, y - ch / 2 + 0.02, f"A = {a_after}",
                    ha="center", va="center", fontsize=10,
                    fontweight="bold", color="#bf360c", zorder=4)
            a_running = a_after
        # seta para a proxima celula (mesma linha)
        if c < n_cols - 1:
            varrow(x + cw, y, x + cw + gx, y)
    # valor de A ao fim da instrucao (coluna direita)
    xr, _ = cell_xy(r, n_cols - 1)
    ax.text(xr + cw + 0.9, y, f"A = {a_running}", ha="center", va="center",
            fontsize=15, fontweight="bold", color="#bf360c",
            bbox=dict(boxstyle="round,pad=0.3", fc="#fff3e0", ec="#bf360c",
                      lw=1.6), zorder=4)
    # seta de retorno T6 -> T1 da proxima instrucao
    if r < len(instrs) - 1:
        x_last, _ = cell_xy(r, n_cols - 1)
        x_next, y_next = cell_xy(r + 1, 0)
        varrow(x_last + cw / 2, y - ch / 2, x_next + cw / 2,
               y_next + ch / 2, color="#1565c0", rad=-0.12)
        ax.text((x_last + x_next) / 2 + cw / 2 + 1.2,
                (y + y_next) / 2, "T6 -> T1\n(proxima instr.)",
                ha="center", va="center", fontsize=8, color="#1565c0")

# titulo e legenda
ax.text(fig_w / 2, fig_h - 0.5,
        "Trace da FSM  -  exemplo  LDA 12 ; ADD 12 ; ADD 12  (A: 0->3->6->9)",
        ha="center", fontsize=15, fontweight="bold")
ax.text(fig_w / 2, 0.45,
        "Azul = BUSCA (T1-T3)     Verde = EXECUCAO (T4-T6)     "
        "Cinza = passo ocioso     Amarelo/borda = micropasso que altera A",
        ha="center", fontsize=9)

plt.tight_layout()
for ext in ("png", "pdf", "svg"):
    out = f"fsm_trace_diagram.{ext}"
    plt.savefig(out, dpi=160, bbox_inches="tight")
    print(f"Diagrama salvo em: {out}")
