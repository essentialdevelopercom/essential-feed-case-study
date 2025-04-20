#!/bin/bash

# 1. Cierra el simulador para evitar conflictos de estado
osascript -e 'tell application "Simulator" to quit'

# 2. Limpia DerivedData solo del proyecto actual
rm -rf ~/Library/Developer/Xcode/DerivedData/EssentialFeed-*

# 3. Abre el simulador correcto (esto fuerza el entorno y permisos)
xcrun simctl boot "iPhone 16 Pro" || true

# 4. Espera a que el simulador esté listo
xcrun simctl bootstatus "iPhone 16 Pro" -b

# 5. Ejecuta los tests con cobertura en el simulador correcto
cd EssentialFeed
xcodebuild \
  -scheme EssentialFeed \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.4' \
  -enableCodeCoverage YES \
  test
cd ..

# 6. Vuelve a cerrar el simulador si lo deseas (opcional)
# osascript -e 'tell application "Simulator" to quit'
