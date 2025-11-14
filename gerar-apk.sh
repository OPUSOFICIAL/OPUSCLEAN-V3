#!/bin/bash

# 📱 Script Automático de Build APK Android
# Execute este script no seu computador (Mac/Linux)

set -e  # Para na primeira erro

echo "🚀 OPUS Facilities - Build APK Android"
echo "======================================"
echo ""

# 1. Build frontend
echo "📦 [1/3] Compilando frontend (Vite)..."
npm run build:android

# 2. Sync com Android
echo "🔄 [2/3] Sincronizando com projeto Android..."
npx cap sync android

# 3. Gerar APK
echo "🏗️  [3/3] Gerando APK (pode demorar ~2min na primeira vez)..."
cd android
./gradlew assembleDebug
cd ..

# Localizar APK
APK_PATH="android/app/build/outputs/apk/debug/app-debug.apk"

if [ -f "$APK_PATH" ]; then
    SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo ""
    echo "✅ APK GERADO COM SUCESSO!"
    echo "======================================"
    echo "📍 Localização: $APK_PATH"
    echo "📊 Tamanho: $SIZE"
    echo ""
    echo "📲 Para instalar no celular:"
    echo "   adb install $APK_PATH"
    echo ""
    echo "Ou transfira o arquivo para o celular e instale manualmente."
else
    echo "❌ Erro: APK não foi gerado!"
    exit 1
fi
