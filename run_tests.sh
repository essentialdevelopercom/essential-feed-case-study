#!/bin/bash

# 1. Limpia DerivedData solo del proyecto actual
rm -rf ~/Library/Developer/Xcode/DerivedData/EssentialFeed-*

# 2. Ejecuta los tests con cobertura en macOS
cd EssentialFeed
xcodebuild \
  -scheme EssentialFeed \
  -destination 'platform=macOS' \
  -enableCodeCoverage YES \
  test
cd ..

