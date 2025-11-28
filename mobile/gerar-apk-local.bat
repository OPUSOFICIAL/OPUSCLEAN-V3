@echo off
REM OPUS Facilities - Build APK Local (Windows)
REM Expo SDK 54 - Requer: Node.js 20+, Java JDK 17, Android Studio com SDK 35

echo.
echo ========================================
echo   OPUS Facilities - Build APK LOCAL
echo   Expo SDK 54 ^| React Native 0.81
echo ========================================
echo.

REM Verificar Node.js
where node >nul 2>nul
if errorlevel 1 (
    echo [ERRO] Node.js nao encontrado!
    echo Instale em: https://nodejs.org/ (versao 20 LTS)
    pause
    exit /b 1
)

REM Verificar versao do Node.js
for /f "tokens=1 delims=." %%i in ('node -v') do set NODE_MAJOR=%%i
echo Versao do Node.js: %NODE_MAJOR%

REM Avisar se Node menor que 20
echo %NODE_MAJOR% | findstr /r "v16 v17 v18" >nul
if not errorlevel 1 (
    echo.
    echo [AVISO] Voce esta usando Node.js %NODE_MAJOR%.
    echo Expo SDK 54 recomenda Node.js 20+
    echo.
)

REM Verificar Java
where java >nul 2>nul
if errorlevel 1 (
    echo [ERRO] Java JDK nao encontrado!
    echo Instale em: https://adoptium.net/ (Temurin 17)
    pause
    exit /b 1
)

REM Verificar ANDROID_HOME
if "%ANDROID_HOME%"=="" (
    echo [AVISO] ANDROID_HOME nao configurado.
    echo Configure a variavel de ambiente ANDROID_HOME apontando para o SDK.
    echo Exemplo: C:\Users\SeuUsuario\AppData\Local\Android\Sdk
    pause
)

echo [1/4] Limpando arquivos antigos...
rmdir /s /q node_modules 2>nul
rmdir /s /q android 2>nul
rmdir /s /q ios 2>nul
rmdir /s /q .expo 2>nul
del package-lock.json 2>nul

echo [2/4] Instalando dependencias...
call npm install
if errorlevel 1 goto error
call npx expo install --fix
if errorlevel 1 goto error

echo [3/4] Gerando projeto Android nativo (Expo SDK 54)...
call npx expo prebuild --platform android --clean
if errorlevel 1 goto error

echo [4/4] Compilando APK...
cd android
call gradlew.bat clean
call gradlew.bat assembleRelease
if errorlevel 1 goto error

echo.
echo ========================================
echo   APK GERADO COM SUCESSO!
echo ========================================
echo.
echo O APK esta em:
echo android\app\build\outputs\apk\release\app-release.apk
echo.
echo Copie este arquivo para seu celular e instale.
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
echo   1. Node.js 20+ instalado
echo   2. Java JDK 17 instalado
echo   3. Android Studio com SDK 35 instalado
echo   4. Variavel ANDROID_HOME configurada
echo.
echo Dica: Tente rodar cada comando manualmente para ver o erro.
echo.
pause
exit /b 1
