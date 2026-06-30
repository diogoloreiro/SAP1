#!/usr/bin/env python3
# =============================================================
# fsm_exec_diagram.py - Diagrama do CICLO DE EXECUCAO do SAP-1
#
# Mostra o ciclo de BUSCA compartilhado (T1-T3) ramificando, em
# T4, para a microsequencia especifica de cada instrucao
# (LDA, ADD, SUB, OUT, HLT), com os sinais ativos de cada
# micropasso. Espelha a logica de saida do controlador
# (controller_fsm.v / controller_sequencer.v).
#
# Gera: fsm_exec_diagram.{png,pdf,svg}
# Uso:  python3 fsm_exec_diagram.py
# =============================================================
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

# ---- microsequencia de cada instrucao (T4, T5, T6) ----
#      "" = passo ocioso (palavra IDLE)
instr = {
    "LDA": {"op": "0000", "T4": "~Lm, ~Ei\nMAR <- IR.end",
                          "T5": "~CE, ~La\nA <- RAM",
                          "T6": ""},
    "ADD": {"op": "0001", "T4": "~Lm, ~Ei\nMAR <- IR.end",
                          "T5": "~CE, ~Lb\nB <- RAM",
                          "T6": "~La, Eu\nA <- A+B"},
    "SUB": {"op": "0010", "T4": "~Lm, ~Ei\nMAR <- IR.end",
                          "T5": "~CE, ~Lb\nB <- RAM",
                          "T6": "~La, Eu, Su\nA <- A-B"},
    "OUT": {"op": "1110", "T4": "Ea, ~Lo\nOUT <- A",
                          "T5": "", "T6": ""},
    "HLT": {"op": "1111", "T4": "(idle)\nrun <- 0",
                          "T5": "congelado", "T6": "congelado"},
}
order = ["LDA", "ADD", "SUB", "OUT", "HLT"]

col_w, col_gap = 2.4, 0.55
box_h, row_gap = 1.15, 0.5
x0 = 1.0
top = 11.0

# y de cada linha
y_fetch = {"T1": top, "T2": top - (box_h + row_gap),
           "T3": top - 2 * (box_h + row_gap)}
y_T4 = top - 3.6 * (box_h + row_gap)
y_T5 = y_T4 - (box_h + row_gap)
y_T6 = y_T5 - (box_h + row_gap)
y_row = {"T4": y_T4, "T5": y_T5, "T6": y_T6}

n = len(order)
total_w = n * col_w + (n - 1) * col_gap
center_x = x0 + total_w / 2.0

fig, ax = plt.subplots(figsize=(13, 11))
ax.set_xlim(0, x0 + total_w + 1.0)
ax.set_ylim(y_T6 - 1.4, top + box_h + 1.0)
ax.axis("off")

BLUE, GREEN, GRAY, RED = "#bbdefb", "#c8e6c9", "#eceff1", "#ffcdd2"

def box(cx, cy, w, text, fc, bold_title=None):
    ax.add_patch(FancyBboxPatch((cx - w / 2, cy - box_h / 2), w, box_h,
                 boxstyle="round,pad=0.04,rounding_size=0.12",
                 fc=fc, ec="black", lw=1.5, zorder=3))
    if bold_title:
        ax.text(cx, cy + 0.30, bold_title, ha="center", va="center",
                fontsize=12, fontweight="bold", zorder=4)
        ax.text(cx, cy - 0.22, text, ha="center", va="center",
                fontsize=7.2, zorder=4)
    else:
        ax.text(cx, cy, text, ha="center", va="center",
                fontsize=7.4, zorder=4)

def varrow(x1, y1, x2, y2, color="#455a64"):
    ax.add_patch(FancyArrowPatch((x1, y1), (x2, y2),
                 arrowstyle="-|>", mutation_scale=16, lw=1.6,
                 color=color, zorder=2))

# ---- BUSCA compartilhada (T1-T3), centralizada ----
fetch_txt = {"T1": "Ep, ~Lm\nMAR <- PC",
             "T2": "Cp\nPC <- PC+1",
             "T3": "~CE, ~Li\nIR <- RAM"}
for s in ["T1", "T2", "T3"]:
    box(center_x, y_fetch[s], col_w + 1.0, fetch_txt[s], BLUE, bold_title=s)
varrow(center_x, y_fetch["T1"] - box_h / 2, center_x, y_fetch["T2"] + box_h / 2)
varrow(center_x, y_fetch["T2"] - box_h / 2, center_x, y_fetch["T3"] + box_h / 2)

ax.text(center_x + (col_w + 1.0) / 2 + 0.25, y_fetch["T2"],
        "BUSCA\n(igual p/\ntoda\ninstrucao)", ha="left", va="center",
        fontsize=8.5, color="#1565c0", fontweight="bold")

# ---- ramificacao: decodifica opcode apos T3 ----
y_branch = (y_fetch["T3"] - box_h / 2 + y_T4 + box_h / 2) / 2.0
ax.text(center_x, y_branch + 0.08, "decodifica opcode  (em T4)",
        ha="center", va="center", fontsize=8.5, color="#6a1b9a",
        fontweight="bold",
        bbox=dict(boxstyle="round,pad=0.2", fc="#f3e5f5", ec="#6a1b9a"))

# ---- colunas por instrucao ----
for i, name in enumerate(order):
    cx = x0 + col_w / 2 + i * (col_w + col_gap)
    d = instr[name]
    # cabecalho da instrucao
    ax.text(cx, y_T4 + box_h / 2 + 0.55, f"{name}",
            ha="center", va="center", fontsize=12, fontweight="bold")
    ax.text(cx, y_T4 + box_h / 2 + 0.18, f"opcode {d['op']}",
            ha="center", va="center", fontsize=7.5, color="#555")
    # seta da ramificacao -> T4 da coluna
    varrow(center_x, y_fetch["T3"] - box_h / 2,
           cx, y_T4 + box_h / 2, color="#9c27b0")
    # T4, T5, T6
    for s in ["T4", "T5", "T6"]:
        txt = d[s]
        if name == "HLT":
            fc = RED if s == "T4" else GRAY
        else:
            fc = GREEN if txt else GRAY
        label = txt if txt else "(idle)"
        box(cx, y_row[s], col_w, label, fc, bold_title=s)
    varrow(cx, y_T4 - box_h / 2, cx, y_T5 + box_h / 2)
    varrow(cx, y_T5 - box_h / 2, cx, y_T6 + box_h / 2)

# ---- retorno T6 -> T1 (proxima instrucao) ----
ax.text(center_x, y_T6 - 0.95,
        "T6 -> T1: volta para a BUSCA da proxima instrucao "
        "(exceto HLT, que permanece congelado)",
        ha="center", va="center", fontsize=8.5, color="#1565c0")

# ---- titulo e legenda ----
ax.text(center_x, top + box_h + 0.6,
        "Ciclo de Execucao por Instrucao  -  FSM do SAP-1",
        ha="center", fontsize=15, fontweight="bold")
ax.text(center_x, y_T6 - 1.25,
        "Verde = micropasso ativo     Cinza = passo ocioso (palavra IDLE)     "
        "Vermelho = HLT (run<-0)",
        ha="center", fontsize=8.5)

plt.tight_layout()
for ext in ("png", "pdf", "svg"):
    out = f"fsm_exec_diagram.{ext}"
    plt.savefig(out, dpi=160, bbox_inches="tight")
    print(f"Diagrama salvo em: {out}")
