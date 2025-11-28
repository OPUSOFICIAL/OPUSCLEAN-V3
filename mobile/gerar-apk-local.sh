#!/bin/bash
# OPUS Facilities - Build APK Local (Mac/Linux)
# Requer: Node.js 18+, Java JDK 17, Android Studio com SDK

echo ""
echo "========================================"
echo "  OPUS Facilities - Build APK LOCAL"
echo "========================================"
echo ""

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "[ERRO] Node.js nao encontrado!"
    echo "Instale em: https://nodejs.org/"
    exit 1
fi

# Verificar Java
if ! command -v java &> /dev/null; then
    echo "[ERRO] Java JDK nao encontrado!"
    echo "Instale em: https://adoptium.net/"
    exit 1
fi

# Verificar ANDROID_HOME
if [ -z "$ANDROID_HOME" ]; then
    echo "[AVISO] ANDROID_HOME nao configurado."
    echo "Configure a variavel de ambiente ANDROID_HOME apontando para o SDK."
    echo "Exemplo: export ANDROID_HOME=~/Android/Sdk"
fi

echo "[1/3] Instalando dependencias..."
npm install || exit 1

echo "[2/3] Gerando projeto Android nativo..."
npx expo prebuild --platform android || exit 1

echo "[3/3] Compilando APK..."
cd android
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
