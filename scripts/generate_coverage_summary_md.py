import os
import sys
import csv
import argparse
import datetime
import re

def main():
    parser = argparse.ArgumentParser(description='Genera resumen de cobertura en Markdown, HTML y CSV.')
    parser.add_argument('--report', type=str, default='./coverage-reports/coverage-report.txt', help='Ruta al archivo coverage-report.txt')
    parser.add_argument('--md', type=str, default='./coverage-reports/coverage-summary.md', help='Ruta de salida Markdown')
    parser.add_argument('--html', type=str, default='./coverage-reports/coverage-summary.html', help='Ruta de salida HTML')
    parser.add_argument('--csv', type=str, default='./coverage-reports/coverage-summary.csv', help='Ruta de salida CSV')
    args = parser.parse_args()

    report = args.report
    md_report = args.md
    html_report = args.html
    csv_report = args.csv

    if not os.path.exists(report):
        print(f'ERROR: No existe el archivo de cobertura: {report}\nAsegúrate de ejecutar primero generate_coverage_report.sh y que los tests hayan pasado.')
        sys.exit(1)

    # Expresiones regulares para extraer datos
    file_line_re = re.compile(r"^\s*(/.+\.swift)\s+(\d+\.\d+)% \(\d+/\d+\)")
    total_re = re.compile(r"^\s*EssentialFeed\.framework\s+(\d+\.\d+)%")

    files = []
    total_coverage = None

    with open(report) as f:
        for line in f:
            m = file_line_re.match(line)
            if m:
                files.append((m.group(1), float(m.group(2))))
            mt = total_re.match(line)
            if mt:
                total_coverage = float(mt.group(1))

    print("Archivos procesados:", files)
    print("Cobertura total:", total_coverage)

    # Markdown
    with open(md_report, "w") as f:
        f.write(f"# Cobertura de código\n\nCobertura total: {total_coverage if total_coverage is not None else 'N/A'}%\n\n")
        f.write("| Archivo | Cobertura (%) |\n|---------|---------------|\n")
        for path, cov in files:
            f.write(f"| `{path}` | {cov:.2f} |\n")

    # HTML con CSS externo y tabla simple, rutas relativas
    def relative_path(path):
        # Acorta la ruta para mostrar solo desde el directorio que contiene el xcodeproj
        # Busca el primer directorio que contenga un .xcodeproj en el repo
        repo_root = os.getcwd()
        xcodeproj_dir = None
        for root_dir, dirs, files in os.walk(repo_root):
            for d in dirs:
                if d.endswith('.xcodeproj'):
                    xcodeproj_dir = os.path.dirname(os.path.join(root_dir, d))
                    break
            if xcodeproj_dir:
                break
        if xcodeproj_dir:
            try:
                rel = os.path.relpath(path, xcodeproj_dir)
                return rel
            except:
                pass
        # Fallback: ruta relativa desde el repo
        try:
            rel = os.path.relpath(path, repo_root)
            return rel
        except:
            return os.path.basename(path)

    # --- NUEVO BLOQUE: Parsear coverage-report.txt y construir el diccionario de coberturas ---
    coverage_txt = os.path.join(os.path.dirname(__file__), '../coverage-reports/coverage-report.txt')
    coverage_data = {}
    with open(coverage_txt, 'r') as covf:
        for line in covf:
            m = re.match(r"\s*(/.+\.swift)\s+([0-9.]+)% \((\d+)/(\d+)\)", line)
            if m:
                path = m.group(1).strip()
                pct = float(m.group(2))
                num = int(m.group(3))
                den = int(m.group(4))
                coverage_data[path] = {'pct': pct, 'num': num, 'den': den}
    # --- PARSE LCOV ---
    lcov_path = os.path.join(os.getcwd(), 'coverage.lcov')
    coverage_data = {}
    current_file = None
    with open(lcov_path) as lcov:
        for line in lcov:
            line = line.strip()
            if line.startswith('SF:'):
                current_file = line[3:]
                if current_file not in coverage_data:
                    coverage_data[current_file] = {'functions': [0, 0], 'lines': [0, 0]}
            elif line.startswith('FNF:'):
                coverage_data[current_file]['functions'][1] = int(line[4:])
            elif line.startswith('FNH:'):
                coverage_data[current_file]['functions'][0] = int(line[4:])
            elif line.startswith('LF:'):
                coverage_data[current_file]['lines'][1] = int(line[3:])
            elif line.startswith('LH:'):
                coverage_data[current_file]['lines'][0] = int(line[3:])
    # --- FIN PARSE LCOV ---

    with open(html_report, "w") as f:
        f.write(f"""<!doctype html><html><head><meta name='viewport' content='width=device-width,initial-scale=1'><meta charset='UTF-8'>
<style>
body {{ background: #181818; color: #eee; font-family: 'SF Mono', 'Menlo', 'Consolas', monospace; }}
table {{ border-collapse: collapse; width: 100%; font-size: 14px; margin-bottom: 0.5em; }}
th, td {{ border: 1px solid #444; padding: 6px 10px; }}
th {{ background: #232323; color: #fff; position: sticky; top: 0; z-index: 2; }}
tr.light-row {{ background: #191c1f; }}
tr.alt-row {{ background: #22252a; }}
tr:hover {{ background: #2c333a; }}
.column-entry-green {{ background: #1e4620; color: #b6ffb6; }}
.column-entry-yellow {{ background: #4c4300; color: #ffe066; }}
.column-entry-red {{ background: #4d2323; color: #ffb3b3; }}
.column-entry-gray {{ background: #333; color: #aaa; }}
pre {{ margin: 0; font-family: inherit; }}
a {{ color: #b3e5fc; text-decoration: underline; }}
.totals-row {{ font-weight: bold; border-top: 2px solid #888; background: #222; }}
</style>
<script src='control.js'></script></head><body><h2 style='margin-bottom:0.2em;'>Coverage Report</h2><div style='font-size:13px;color:#ccc;margin-bottom:1em;'>Created: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}</div><p style='margin:0 0 1em 0;'><b>Total: {total_coverage:.2f}%</b></p><div class='centered'><table><tr><th title='Relative path to source file'>Filename</th><th title='Percentage and count of functions covered by tests'>Function Coverage</th><th title='Percentage and count of lines covered by tests'>Line Coverage</th><th title='Percentage and count of regions covered by tests'>Region Coverage</th><th title='Branches covered by tests (not available)'>Branch Coverage</th></tr>""")

        # Calcular totales reales (media ponderada)
        total_funcs = sum(d['functions'][1] for d in coverage_data.values())
        total_funcs_cov = sum(d['functions'][0] for d in coverage_data.values())
        total_lines = sum(d['lines'][1] for d in coverage_data.values())
        total_lines_cov = sum(d['lines'][0] for d in coverage_data.values())
        total_func_pct = (100.0 * total_funcs_cov / total_funcs) if total_funcs else 0.0
        total_line_pct = (100.0 * total_lines_cov / total_lines) if total_lines else 0.0
        for i, path in enumerate(coverage_data):
            data = coverage_data[path]
            rel_path = relative_path(path)
            rel_path_clean = rel_path.replace('../', '').replace('EssentialFeed/EssentialFeed/', '').replace('EssentialFeed/', '').replace('//', '/').lstrip('/')
            link = os.path.relpath(path, os.path.join(os.getcwd(), 'coverage_html_latest'))
            def format_cov(val, num, den):
                return f"{val:.2f}% ({num}/{den})"
            def css_class(val):
                if val == '-' or val.startswith('-'):
                    return 'column-entry-gray'
                try:
                    v = float(val.split('%')[0].replace(',', '.'))
                except:
                    return 'column-entry-gray'
                if v >= 95:
                    return 'column-entry-green'
                elif v >= 80:
                    return 'column-entry-yellow'
                else:
                    return 'column-entry-red'
            # Function Coverage
            fn_cov = data['functions']
            if fn_cov[1]:
                fn_pct = 100.0 * fn_cov[0] / fn_cov[1]
                function_str = format_cov(fn_pct, fn_cov[0], fn_cov[1])
            else:
                function_str = '-'
            # Line Coverage
            ln_cov = data['lines']
            if ln_cov[1]:
                ln_pct = 100.0 * ln_cov[0] / ln_cov[1]
                line_str = format_cov(ln_pct, ln_cov[0], ln_cov[1])
            else:
                line_str = '-'
            # Region y Branch Coverage no disponibles
            region_str = '-'
            branch_str = '-'
            row_class = 'alt-row' if i % 2 else 'light-row'
            f.write(f"<tr class='{row_class}'>"
                    f"<td style='border:1px solid #555;padding:4px 8px;background:#181818;'><pre style='margin:0;'><a href='{link}' style='color:#b3e5fc;text-decoration:underline;'>{rel_path_clean}</a></pre></td>"
                    f"<td class='{css_class(function_str)}' style='border:1px solid #555;padding:4px 8px;'><pre style='margin:0;' title='Functions: {fn_cov[0]} of {fn_cov[1]} covered'>{function_str}</pre></td>"
                    f"<td class='{css_class(line_str)}' style='border:1px solid #555;padding:4px 8px;'><pre style='margin:0;' title='Lines: {ln_cov[0]} of {ln_cov[1]} covered'>{line_str}</pre></td>"
                    f"<td class='column-entry-gray' style='border:1px solid #555;padding:4px 8px;'><pre style='margin:0;' title='Region coverage not available'>-</pre></td>"
                    f"<td class='column-entry-gray' style='border:1px solid #555;padding:4px 8px;'><pre style='margin:0;' title='Branch coverage not available'>-</pre></td></tr>")
        # Fila Totals real
        f.write(f"<tr class='totals-row'><td>Totals</td><td>{total_func_pct:.2f}% ({total_funcs_cov}/{total_funcs})</td><td>{total_line_pct:.2f}% ({total_lines_cov}/{total_lines})</td><td>-</td><td>-</td></tr></table></div>\n")
        # Pie de página tipo llvm-cov
        f.write("""
<pre style='margin:12px 0 0 0;padding:8px 0 0 0;font-family:monospace;font-size:13px;color:#fff;background:#222;text-align:left;border:none;'>Generated by generate_coverage_summary_md.py</pre>
</body></html>""")

    # CSV
    with open(csv_report, "w", newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["Archivo", "Cobertura (%)"])
        for path, cov in files:
            writer.writerow([path, f"{cov:.2f}"])

    print(f"[OK] coverage-summary.md, coverage-summary.html y coverage-summary.csv generados en {os.path.dirname(md_report)}")

if __name__ == "__main__":
    main()