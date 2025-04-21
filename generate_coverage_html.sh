#!/bin/bash

# Script: generate_coverage_html.sh
# Uso: ./generate_coverage_html.sh
# Genera el reporte de cobertura HTML actualizado y lo abre automáticamente.

set -e

# Variables
DERIVED_DATA=~/Library/Developer/Xcode/DerivedData
PROJ_NAME=EssentialFeed
PROJ_ID=$(ls "$DERIVED_DATA" | grep "$PROJ_NAME" | head -n 1)
PROJ_PATH="$DERIVED_DATA/$PROJ_ID"
PROFDATA=$(find "$PROJ_PATH" -name '*.profdata' | sort -r | head -n 1)
BINARY=$(find "$PROJ_PATH/Build/Products/Debug/EssentialFeedTests.xctest/Contents/MacOS" -type f -perm +111 | grep EssentialFeedTests | head -n 1)
OUTPUT_DIR="coverage_html_latest"

if [ -z "$PROFDATA" ] || [ -z "$BINARY" ]; then
  echo "No se encontró .profdata o binario de tests. Ejecuta primero los tests con cobertura en Xcode."
  exit 1
fi

# Limpia el reporte anterior
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Genera el nuevo HTML
xcrun llvm-cov show -instr-profile "$PROFDATA" "$BINARY" -format=html -output-dir "$OUTPUT_DIR"

# Abre el HTML actualizado
defaults write com.apple.finder AppleShowAllFiles YES
open "$OUTPUT_DIR/index.html"
