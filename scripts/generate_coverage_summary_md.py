#!/usr/bin/env python3
"""
Genera resumen de cobertura en Markdown, HTML y CSV a partir de coverage-report.txt.
Incluye enlaces a los archivos fuente y puede integrarse en README.md.
"""
import re
from pathlib import Path
import csv

TXT_REPORT = Path("coverage-reports/coverage-report.txt")
MD_REPORT = Path("coverage-reports/coverage-summary.md")
HTML_REPORT = Path("coverage-reports/coverage-summary.html")
CSV_REPORT = Path("coverage-reports/coverage-summary.csv")
README = Path("README.md")

REPO_ROOT = Path(__file__).parent.resolve()

if not TXT_REPORT.exists():
    print(f"ERROR: No existe {TXT_REPORT}")
    exit(1)

# Expresiones regulares para extraer datos
file_line_re = re.compile(r"^\s*(/.+\.swift)\s+(\d+\.\d+)%")
total_re = re.compile(r"^\s*EssentialFeed\.framework\s+(\d+\.\d+)%")

files = []
total_coverage = None

with TXT_REPORT.open() as f:
    for line in f:
        m = file_line_re.match(line)
        if m:
            files.append((m.group(1), float(m.group(2))))
        else:
            t = total_re.match(line)
            if t and total_coverage is None:
                total_coverage = float(t.group(1))

# Filtrar solo archivos de Auth, Registro y Seguridad
INCLUDED_FEATURES = [
    'Authentication Feature',
    'Registration Feature',
    'Security Feature'
]
def is_included(path):
    return any(feature in path for feature in INCLUDED_FEATURES)

# Incluir archivos de test relevantes aunque no tengan cobertura (mostrar como N/A)
test_dirs = [
    'EssentialFeed/EssentialFeedTests/Authentication Feature',
    'EssentialFeed/EssentialFeedTests/Registration Feature',
    'EssentialFeed/EssentialFeedTests/Security Feature',
]
test_files = []
from glob import glob
for d in test_dirs:
    test_files += glob(f"{d}/**/*Tests*.swift", recursive=True)
# Normalizar paths
import os
test_files = [os.path.relpath(f, REPO_ROOT) for f in test_files]
# Eliminar duplicados
unique_test_files = list(dict.fromkeys(test_files))

# Mapeo producción <-> test (convención y CU)
prod_files = [f[0] for f in files if f[1] > 0 and is_included(f[0])]
cu_map = {}
for tf in test_files:
    cu_map[tf] = []
    try:
        with open(tf, encoding="utf-8") as f:
            for line in f:
                m = re.search(r'//\s*CU:\s*(.+)', line)
                if m:
                    cu_map[tf].append(m.group(1).strip())
    except Exception:
        pass

test_map = {}
for pf in prod_files:
    base = Path(pf).stem.replace("+Server", "")
    # Coincidencia flexible por nombre
    related_tests = [tf for tf in test_files if base in Path(tf).stem or base in tf]
    # Por CU
    related_tests += [tf for tf, cu_list in cu_map.items() if any(base in cu for cu in cu_list)]
    # BONUS: busca si la clase base aparece en el contenido del test
    for tf in test_files:
        try:
            with open(tf, encoding="utf-8") as f:
                content = f.read()
                if base in content:
                    related_tests.append(tf)
        except Exception:
            pass
    test_map[pf] = sorted(set(Path(t).name for t in related_tests))

files_with_coverage = [f for f in files if f[1] > 0 and is_included(f[0])]
files_with_coverage += [(f, None) for f in unique_test_files if f not in [fwc[0] for fwc in files_with_coverage]]
files_with_coverage.sort(key=lambda x: (-1 if x[1] is None else -x[1]))
files_with_coverage_min = sorted([f for f in files_with_coverage if f[1] is not None], key=lambda x: x[1])

def is_production_file(path):
    name = Path(path).name
    return not re.search(r'Tests(\+.*)?\.swift$', name)

prod_files_with_coverage = [f for f in files_with_coverage if is_production_file(f[0])]

# Top 5 mayor y menor cobertura
top5 = prod_files_with_coverage[:5]
bottom5 = sorted([f for f in prod_files_with_coverage if f[1] is not None], key=lambda x: x[1])[:5]

# Helper para enlaces relativos en markdown/html
def rel_link(abs_path):
    try:
        return abs_path.relative_to(REPO_ROOT)
    except ValueError:
        return abs_path

def md_table(rows, test_map=None):
    out = "| Archivo | Cobertura | Test que lo cubre |\n|---|---|---|\n"
    for name, cov in rows:
        rel = rel_link(Path(name))
        cov_str = f"{cov:.2f}%" if cov is not None else "N/A"
        test_str = ", ".join(test_map.get(name, [])) if test_map else ""
        out += f"| [{rel.name}]({rel}) | {cov_str} | {test_str} |\n"
    return out

def html_table(rows, bars=False, test_map=None):
    out = "<table><tr><th>Archivo</th><th>Cobertura</th>"
    if test_map:
        out += "<th>Test que lo cubre</th>"
    out += ("<th></th>" if bars else "") + "</tr>"
    for name, cov in rows:
        rel = rel_link(Path(name))
        cov_str = f"{cov:.2f}%" if cov is not None else "N/A"
        test_str = ", ".join(test_map.get(name, [])) if test_map else ""
        bar_html = ""
        if bars and cov is not None:
            if cov >= 90:
                color = "green"
            elif cov >= 70:
                color = "yellow"
            else:
                color = "red"
            bar_html = f'''<td class="cov-bar"><div class="bar-bg"><div class="bar-fill {color}" style="width:{cov:.0f}%;"></div><span class="cov-label">{cov:.2f}%</span></div></td>'''
        elif bars:
            bar_html = "<td></td>"
        out += f'<tr><td><a href="{rel}">{rel.name}</a></td><td>{cov_str}</td>'
        if test_map:
            out += f'<td>{test_str}</td>'
        out += f'{bar_html}</tr>'
    out += "</table>"
    return out

with MD_REPORT.open("w") as f:
    f.write("# 📊 Resumen de Cobertura de Código\n\n")
    if total_coverage is not None:
        f.write(f"**Cobertura total:** **{total_coverage:.2f}%**\n\n")
    else:
        f.write("Cobertura total: No detectada\n\n")
    f.write("---\n\n## Archivos con mayor cobertura\n\n")
    f.write(md_table(top5, test_map=test_map))
    f.write("\n## Archivos con menor cobertura (>0%)\n\n")
    f.write(md_table(bottom5, test_map=test_map))
    f.write("\n---\n")
    f.write("### ¿Cómo leer este reporte?\n")
    f.write("- **Cobertura total:** Porcentaje de líneas cubiertas por tests en todo el target.\n")
    f.write("- **Mayor cobertura:** Archivos mejor cubiertos por los tests.\n")
    f.write("- **Menor cobertura:** Archivos con menor cobertura (pero mayor a 0%).\n")
    f.write("\n> Para cobertura por clase o función, revisa el archivo `coverage-report.txt`.\n")

# HTML
with HTML_REPORT.open("w") as f:
    f.write(f"""
<!DOCTYPE html>
<html lang=\"es\">
<head>
  <meta charset=\"UTF-8\">
  <title>Resumen de Cobertura de Código</title>
  <style>
    body {{ font-family: 'Segoe UI', Arial, sans-serif; background: #f8fafc; color: #222; margin: 0; padding: 0; }}
    .container {{ max-width: 800px; margin: 32px auto; background: #fff; border-radius: 12px; box-shadow: 0 2px 16px #0001; padding: 32px; }}
    h1 {{ font-size: 2.2em; margin-bottom: 0.2em; display: flex; align-items: center; }}
    h1 .emoji {{ font-size: 1.2em; margin-right: 0.3em; }}
    .total-cov {{ font-size: 1.4em; font-weight: bold; color: #fff; background: linear-gradient(90deg, #1db954 60%, #ffb300 100%); padding: 8px 24px; border-radius: 24px; display: inline-block; margin-bottom: 18px; }}
    table {{ border-collapse: collapse; width: 100%; margin: 18px 0; }}
    th, td {{ border: none; padding: 10px 12px; text-align: left; }}
    th {{ background: #e3eafc; color: #222; font-weight: 600; border-bottom: 2px solid #b6c7e3; }}
    tr {{ background: #f5f7fa; }}
    tr:nth-child(even) {{ background: #e9f2fb; }}
    td.cov-bar {{ min-width: 180px; }}
    .bar-bg {{ background: #e0e0e0; border-radius: 8px; width: 100%; height: 18px; position: relative; }}
    .bar-fill {{ height: 100%; border-radius: 8px; position: absolute; left: 0; top: 0; }}
    .bar-fill.green {{ background: #1db954; }}
    .bar-fill.yellow {{ background: #ffb300; }}
    .bar-fill.red {{ background: #e53935; }}
    .cov-label {{ position: absolute; left: 50%; top: 0; transform: translateX(-50%); font-size: 0.98em; color: #222; font-weight: bold; }}
    .section-title {{ margin-top: 2.2em; margin-bottom: 0.5em; font-size: 1.15em; color: #1a73e8; }}
    ul {{ margin-top: 0.5em; }}
    .legend {{ margin-top: 2em; font-size: 1.01em; color: #555; }}
    code {{ background: #f3f4f8; color: #1a73e8; padding: 2px 6px; border-radius: 4px; }}
  </style>
</head>
<body>
<div class="container">
  <h1><span class="emoji">📊</span>Resumen de Cobertura de Código</h1>
  <div class="total-cov">Cobertura total: {total_coverage:.2f}%</div>
  <div class="section-title">Archivos con mayor cobertura</div>
  {html_table(top5, bars=True, test_map=test_map)}
  <div class="section-title">Archivos con menor cobertura (&gt;0%)</div>
  {html_table(bottom5, bars=True, test_map=test_map)}
  <div class="legend">
    <h3>¿Cómo leer este reporte?</h3>
    <ul>
      <li><b>Cobertura total:</b> Porcentaje de líneas cubiertas por tests en todo el target.</li>
      <li><b>Mayor cobertura:</b> Archivos mejor cubiertos por los tests.</li>
      <li><b>Menor cobertura:</b> Archivos con menor cobertura (pero mayor a 0%).</li>
    </ul>
    <p>Para cobertura por clase o función, revisa el archivo <code>coverage-report.txt</code>.</p>
  </div>
</div>
</body></html>
""")

# CSV
with CSV_REPORT.open("w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["Archivo", "Cobertura", "Test que lo cubre"])
    for name, cov in files_with_coverage:
        rel = rel_link(Path(name))
        cov_str = f"{cov:.2f}%" if cov is not None else "N/A"
        test_str = ", ".join(test_map.get(name, [])) if 'test_map' in globals() else ""
        writer.writerow([str(rel), cov_str, test_str])

# Integrar resumen en README.md (si existe)
if README.exists():
    with README.open() as f:
        lines = f.readlines()
    # Elimina bloques previos de cobertura
    start = end = None
    for i, line in enumerate(lines):
        if line.strip() == "<!-- COVERAGE-REPORT-START -->":
            start = i
        if line.strip() == "<!-- COVERAGE-REPORT-END -->":
            end = i
            break
    md_block = ["<!-- COVERAGE-REPORT-START -->\n"]
    md_block += [l for l in MD_REPORT.open()]
    md_block.append("<!-- COVERAGE-REPORT-END -->\n")
    if start is not None and end is not None:
        new_lines = lines[:start] + md_block + lines[end+1:]
    else:
        # Añade al final
        new_lines = lines + ["\n"] + md_block
    with README.open("w") as f:
        f.writelines(new_lines)

print(f"Resumen Markdown generado en {MD_REPORT}")
print(f"Resumen HTML generado en {HTML_REPORT}")
print(f"Resumen CSV generado en {CSV_REPORT}")
if README.exists():
    print("Resumen integrado en README.md entre marcas <!-- COVERAGE-REPORT-START --> y <!-- COVERAGE-REPORT-END -->")
