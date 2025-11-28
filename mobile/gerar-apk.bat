@echo off
REM OPUS Facilities - Script de Build APK
REM Execute este script no seu computador (Windows)

echo.
echo ========================================
echo   OPUS Facilities - Build APK Android
echo ========================================
echo.

REM Verificar se Node.js esta instalado
where node >nul 2>nul
if errorlevel 1 (
    echo [ERRO] Node.js nao encontrado!
    echo Instale em: https://nodejs.org/
    pause
    exit /b 1
)

REM Verificar se npm esta instalado
where npm >nul 2>nul
if errorlevel 1 (
    echo [ERRO] npm nao encontrado!
    pause
    exit /b 1
)

echo [1/4] Instalando dependencias...
call npm install
if errorlevel 1 goto error

echo [2/4] Instalando EAS CLI...
call npm install -g eas-cli
if errorlevel 1 goto error

echo [3/4] Verificando login Expo...
call eas whoami >nul 2>nul
if errorlevel 1 (
    echo.
    echo Voce precisa fazer login no Expo.
    echo Acesse https://expo.dev/signup para criar uma conta gratuita.
    echo.
    call eas login
    if errorlevel 1 goto error
)

echo [4/4] Gerando APK na nuvem...
echo Isso pode levar 5-15 minutos...
echo.
call eas build --platform android --profile apk
if errorlevel 1 goto error

echo.
echo ========================================
echo   APK GERADO COM SUCESSO!
echo ========================================
echo.
echo O link para download do APK foi exibido acima.
echo Copie o link e abra no navegador para baixar.
echo.
pause
exit /b 0

:error
echo.
echo ========================================
echo   ERRO DURANTE O BUILD
echo ========================================
echo.
echo Verifique:
echo   1. Conexao com a internet
echo   2. Node.js 18+ instalado
echo   3. Conta Expo criada e logada
echo.
pause
exit /b 1
