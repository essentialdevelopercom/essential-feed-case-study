#!/bin/bash
# generate_coverage_report.sh
# Script para ejecutar tests en el simulador iPhone 16 Pro, generar y guardar el reporte de cobertura

set -e

# Configuración
derived_data=~/Library/Developer/Xcode/DerivedData
target_scheme="EssentialFeed"
simulator_name="iPhone 16 Pro"
ios_version="18.4"
report_dir="coverage-reports"
mkdir -p "$report_dir"
report_file="$report_dir/coverage-report.txt"

# 1. Ejecutar tests con cobertura en el simulador preferido
echo "Ejecutando tests en el simulador $simulator_name ($ios_version)..."
# 1.1. Detectar todas las clases de test relevantes en ambas carpetas
only_testing_flags=""
for testfile in $(find EssentialFeed/EssentialFeedTests -type f -name '*Tests*.swift'); do
  classname=$(basename "$testfile" .swift)
  # Solo incluir clases cuyo nombre contiene 'Tests' y NO helpers como 'Spy'
  if [[ "$classname" == *Tests* ]] && [[ "$classname" != *Spy* ]]; then
    only_testing_flags+=" -only-testing:EssentialFeedTests/$classname"
  fi
done

echo "Ejecutando tests con flags: $only_testing_flags"

# 1.2. Ejecutar tests solo de las clases detectadas
xcodebuild \
  -scheme "$target_scheme" \
  -project EssentialFeed/EssentialFeed.xcodeproj \
  -destination "platform=iOS Simulator,name=$simulator_name,OS=$ios_version" \
  -enableCodeCoverage YES \
  $only_testing_flags \
  test || { echo "Fallo la ejecución de tests"; exit 1; }

# 2. Buscar el archivo .xcresult más reciente (robusto ante nombres y espacios)
xcresult=$(find $derived_data -type d -name '*.xcresult' -print0 | xargs -0 ls -1td 2>/dev/null | head -1)
echo "XCRESULT path: $xcresult"
if [[ -z "$xcresult" || ! -d "$xcresult" ]]; then
  echo "ERROR: No se encontró ningún archivo .xcresult válido."
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
