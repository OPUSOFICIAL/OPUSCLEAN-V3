#!/bin/bash
# OPUS Facilities - Build APK Local (Mac/Linux)
# Expo SDK 54 - Requer: Node.js 20+, Java JDK 17, Android Studio com SDK 35

echo ""
echo "========================================"
echo "  OPUS Facilities - Build APK LOCAL"
echo "  Expo SDK 54 | React Native 0.81"
echo "========================================"
echo ""

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "[ERRO] Node.js nao encontrado!"
    echo "Instale em: https://nodejs.org/ (versao 20 LTS)"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'.' -f1 | sed 's/v//')
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "[AVISO] Node.js versao $NODE_VERSION detectada. Recomendado: Node.js 20+"
fi

# Verificar Java
if ! command -v java &> /dev/null; then
    echo "[ERRO] Java JDK nao encontrado!"
    echo "Instale em: https://adoptium.net/ (Temurin 17)"
    exit 1
fi

# Verificar ANDROID_HOME
if [ -z "$ANDROID_HOME" ]; then
    echo "[AVISO] ANDROID_HOME nao configurado."
    echo "Configure a variavel de ambiente ANDROID_HOME apontando para o SDK."
    echo "Exemplo: export ANDROID_HOME=~/Android/Sdk"
fi

echo "[1/4] Limpando arquivos antigos..."
rm -rf node_modules package-lock.json android ios .expo 2>/dev/null

echo "[2/4] Instalando dependencias..."
npm install || exit 1
npx expo install --fix || exit 1

echo "[3/4] Gerando projeto Android nativo (Expo SDK 54)..."
npx expo prebuild --platform android --clean || exit 1

echo "[4/4] Compilando APK..."
cd android
./gradlew clean
./gradlew assembleRelease || exit 1

echo ""
echo "========================================"
echo "  APK GERADO COM SUCESSO!"
echo "========================================"
echo ""
echo "O APK esta em:"
echo "android/app/build/outputs/apk/release/app-release.apk"
echo ""
echo "Copie este arquivo para seu celular e instale."
echo ""
