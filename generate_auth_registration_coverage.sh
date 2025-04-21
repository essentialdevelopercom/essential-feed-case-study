#!/bin/bash

# Script: generate_auth_registration_coverage.sh
# Uso: ./generate_auth_registration_coverage.sh
# Genera el reporte de cobertura HTML SOLO para los módulos de registro y autenticación.

set -e

# Variables
DERIVED_DATA=~/Library/Developer/Xcode/DerivedData
PROJ_NAME=EssentialFeed
PROJ_ID=$(ls "$DERIVED_DATA" | grep "$PROJ_NAME" | head -n 1)
PROJ_PATH="$DERIVED_DATA/$PROJ_ID"
PROFDATA=$(find "$PROJ_PATH" -name '*.profdata' | sort -r | head -n 1)
BINARY=$(find "$PROJ_PATH/Build/Products/Debug/EssentialFeedTests.xctest/Contents/MacOS" -type f -perm +111 | grep EssentialFeedTests | head -n 1)
OUTPUT_DIR="coverage_auth_registration_html"

# Rutas relativas de los módulos de registro y autenticación (ajusta según tu estructura)
INCLUDE_PATHS=(
  "EssentialFeed/Feed Presentation/UserRegistrationUseCase.swift"
  "EssentialFeed/Feed Presentation/UserLoginUseCase.swift"
  "EssentialFeed/Feed Presentation/UserRegistrationUseCaseTests.swift"
  "EssentialFeed/Feed Presentation/UserLoginUseCaseTests.swift"
  "Security Feature/SecureStorage.swift"
  "Security Feature/Keychain/SystemKeychain.swift"
)

if [ -z "$PROFDATA" ] || [ -z "$BINARY" ]; then
  echo "No se encontró .profdata o binario de tests. Ejecuta primero los tests con cobertura en Xcode."
  exit 1
fi

# Limpia el reporte anterior
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Construye la lista de includes para llvm-cov
INCLUDE_ARGS=""
for path in "${INCLUDE_PATHS[@]}"; do
  INCLUDE_ARGS+="-include $path "
done

# Genera el nuevo HTML solo para los módulos seleccionados
eval xcrun llvm-cov show -instr-profile "$PROFDATA" "$BINARY" $INCLUDE_ARGS -format=html -output-dir "$OUTPUT_DIR"

# Abre el HTML actualizado
defaults write com.apple.finder AppleShowAllFiles YES
open "$OUTPUT_DIR/index.html"
