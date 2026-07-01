#!/usr/bin/env python3
# =============================================================
# md2pdf.py - Converte um arquivo Markdown em PDF (weasyprint).
# Uso:  python3 md2pdf.py <arquivo.md> [saida.pdf]
# =============================================================
import sys, markdown
from weasyprint import HTML

CSS = """
@page { size: A4; margin: 2cm 1.8cm; }
body { font-family: 'DejaVu Sans', Arial, sans-serif; font-size: 10.5pt;
       line-height: 1.45; color: #1a1a1a; }
h1 { color: #0d3b66; border-bottom: 3px solid #0d3b66; padding-bottom: 4px;
     font-size: 20pt; }
h2 { color: #0d3b66; border-bottom: 1px solid #bbb; padding-bottom: 2px;
     margin-top: 18px; font-size: 14pt; }
h3 { color: #1565c0; font-size: 11.5pt; margin-top: 12px; }
code { background: #eef1f4; padding: 1px 4px; border-radius: 3px;
       font-family: 'DejaVu Sans Mono', monospace; font-size: 9pt; }
pre { background: #1e2430; color: #e6edf3; padding: 10px 12px;
      border-radius: 6px; overflow-x: auto; font-size: 8.6pt; }
pre code { background: none; color: inherit; padding: 0; }
table { border-collapse: collapse; width: 100%; margin: 8px 0; font-size: 9.3pt; }
th, td { border: 1px solid #cfd6dd; padding: 4px 8px; text-align: left; }
th { background: #0d3b66; color: #fff; }
tr:nth-child(even) td { background: #f3f6f9; }
blockquote { border-left: 4px solid #f0a500; background: #fff8e6;
             margin: 8px 0; padding: 6px 12px; color: #5c4a00; }
strong { color: #0d3b66; }
hr { border: none; border-top: 1px solid #ccc; margin: 14px 0; }
"""

def main():
    if len(sys.argv) < 2:
        print("uso: python3 md2pdf.py <arquivo.md> [saida.pdf]"); sys.exit(1)
    src = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else src.rsplit(".", 1)[0] + ".pdf"
    with open(src, encoding="utf-8") as f:
        html_body = markdown.markdown(f.read(),
                        extensions=["tables", "fenced_code", "sane_lists"])
    html = f"<html><head><meta charset='utf-8'><style>{CSS}</style></head>" \
           f"<body>{html_body}</body></html>"
    HTML(string=html).write_pdf(out)
    print(f"PDF gerado: {out}")

if __name__ == "__main__":
    main()
