#!/bin/bash
# OPUS Facilities - Script de Build APK (Mac/Linux)

echo ""
echo "========================================"
echo "  OPUS Facilities - Build APK Android"
echo "========================================"
echo ""

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "[ERRO] Node.js nao encontrado!"
    echo "Instale em: https://nodejs.org/"
    exit 1
fi

# Verificar npm
if ! command -v npm &> /dev/null; then
    echo "[ERRO] npm nao encontrado!"
    exit 1
fi

echo "[1/4] Instalando dependencias..."
npm install || exit 1

echo "[2/4] Instalando EAS CLI..."
npm install -g eas-cli || exit 1

echo "[3/4] Verificando login Expo..."
if ! eas whoami &> /dev/null; then
    echo ""
    echo "Voce precisa fazer login no Expo."
    echo "Acesse https://expo.dev/signup para criar uma conta gratuita."
    echo ""
    eas login || exit 1
fi

echo "[4/4] Gerando APK na nuvem..."
echo "Isso pode levar 5-15 minutos..."
echo ""
eas build --platform android --profile apk || exit 1

echo ""
echo "========================================"
echo "  APK GERADO COM SUCESSO!"
echo "========================================"
echo ""
echo "O link para download do APK foi exibido acima."
echo "Copie o link e abra no navegador para baixar."
echo ""
