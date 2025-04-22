#!/bin/bash
# generate_coverage_report.sh
# Script profesional para generar reporte de cobertura en macOS
# 1. Elimina el bundle anterior
# 2. Ejecuta tests con cobertura y genera bundle en ./coverage-reports/ci_macOS.xcresult
# 3. Extrae el reporte con xccov a coverage-report.txt
# 4. Ejecuta el script de resumen Markdown/HTML/CSV
# 5. Mensajes claros de error/success

set -e

scheme="CI_macOS"
project="EssentialFeed/EssentialFeed.xcodeproj"
destination="platform=macOS"
coverage_dir="coverage-reports"
result_bundle="$coverage_dir/ci_macOS.xcresult"
report_txt="$coverage_dir/coverage-report.txt"

# Asegura que el directorio de cobertura existe
mkdir -p "$coverage_dir"

# Elimina el bundle anterior si existe
if [ -d "$result_bundle" ]; then
  echo "[INFO] Eliminando bundle anterior $result_bundle"
  rm -rf "$result_bundle"
fi

# Ejecuta tests y genera el bundle
xcodebuild \
  -scheme "$scheme" \
  -project "$project" \
  -destination "$destination" \
  -enableCodeCoverage YES \
  -resultBundlePath "$result_bundle" \
  test

# Extrae el reporte de cobertura
if xcrun xccov view --report "$result_bundle" > "$report_txt"; then
  if [ -s "$report_txt" ]; then
    echo "\n[OK] Cobertura generada en $report_txt"
  else
    echo "[ERROR] El reporte de cobertura está vacío."
    exit 1
  fi
else
  echo "[ERROR] Fallo al extraer cobertura con xccov."
  exit 1
fi
ls -lh "$xcresult"
echo "Archivo de resultados: $xcresult"

# 3. Mostrar salida de xcodebuild para debug
echo "Salida de xcodebuild (resumen de tests ejecutados):"
if ls $derived_data/EssentialFeed-*/Logs/Test/*.xcresult/TestSummaries.plist 1> /dev/null 2>&1; then
  cat $derived_data/EssentialFeed-*/Logs/Test/*.xcresult/TestSummaries.plist | head -40
else
  echo "No se pudo leer el resumen de tests (TestSummaries.plist no encontrado)"
fi

# 4. Generar el reporte de cobertura

# Debug: mostrar el comando y su salida en consola
echo "DEBUG: xcrun xccov view --report \"$xcresult\""
xcrun xccov view --report "$xcresult"

echo "Generando reporte de cobertura..."
xcrun xccov view --report "$xcresult" > "$report_file"
echo "Reporte guardado en $report_file"
ls -lh "$report_file"

echo "\nResumen de cobertura:"
head -15 "$report_file"

# 5. Generar reporte JSON de cobertura con debug y validación
json_report_file="$report_dir/coverage-report.json"
echo "DEBUG: xcrun xccov view --json \"$xcresult\""
xcrun xccov view --json "$xcresult" > "$json_report_file"
ls -lh "$json_report_file"
if [[ ! -s "$json_report_file" ]]; then
  echo "ERROR: coverage-report.json está vacío o no se pudo generar. Puede que tu versión de Xcode no soporte este flag."
else
  echo "Reporte JSON guardado en $json_report_file"
fi

# 6. Generar resumen visual (Markdown, HTML, CSV, README)
python3 scripts/generate_coverage_summary_md.py
