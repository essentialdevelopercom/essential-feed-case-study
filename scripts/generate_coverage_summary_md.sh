#!/bin/bash
# Script para generar un resumen amigable de cobertura en Markdown a partir de coverage-report.json
data_file="coverage-report.json"
output_md="coverage-summary.md"

echo "# 📊 Resumen de Cobertura de Código\n" > "$output_md"

total_coverage=$(jq '.targets[0].lineCoverage' "$data_file" | awk '{printf "%.2f", $1*100}')
target_name=$(jq -r '.targets[0].name' "$data_file")

cat <<EOF >> "$output_md"
**Target:** \`$target_name\`  
**Cobertura total:** **$total_coverage%**

---

## Archivos con mayor cobertura

| Archivo | Cobertura |
|---------|-----------|
EOF

# Top 5 archivos con mayor cobertura
jq -r '.targets[0].files[] | select(.lineCoverage > 0) | "\(.name)\t\(.lineCoverage)"' "$data_file" | \
  awk -F'\t' '{ printf "%s\t%.2f%%\n", $1, $2*100 }' | sort -k2 -r | head -5 | \
  awk -F'\t' '{ printf "| %s | %s |\n", $1, $2 }' >> "$output_md"

cat <<EOF >> "$output_md"

## Archivos con menor cobertura

| Archivo | Cobertura |
|---------|-----------|
EOF

# Top 5 archivos con menor cobertura (excluyendo 0%)
jq -r '.targets[0].files[] | select(.lineCoverage > 0) | "\(.name)\t\(.lineCoverage)"' "$data_file" | \
  awk -F'\t' '{ printf "%s\t%.2f%%\n", $1, $2*100 }' | sort -k2 | head -5 | \
  awk -F'\t' '{ printf "| %s | %s |\n", $1, $2 }' >> "$output_md"

cat <<EOF >> "$output_md"

---
### ¿Cómo leer este reporte?
- **Cobertura total:** Porcentaje de líneas cubiertas por tests en el target principal.
- **Mayor cobertura:** Archivos mejor cubiertos por los tests.
- **Menor cobertura:** Archivos con menor cobertura (pero mayor a 0%).

> Para cobertura por clase o función, revisa el archivo `coverage-report.txt` o explora el JSON.
EOF

echo "Resumen Markdown generado en $output_md"
