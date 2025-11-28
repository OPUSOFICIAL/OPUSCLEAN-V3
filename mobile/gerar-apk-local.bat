@echo off
REM OPUS Facilities - Build APK Local (Windows)
REM Requer: Node.js 18-20 (NAO use Node 22+), Java JDK 17, Android Studio com SDK

echo.
echo ========================================
echo   OPUS Facilities - Build APK LOCAL
echo ========================================
echo.

REM Verificar Node.js
where node >nul 2>nul
if errorlevel 1 (
    echo [ERRO] Node.js nao encontrado!
    echo Instale em: https://nodejs.org/
    pause
    exit /b 1
)

REM Verificar versao do Node.js
for /f "tokens=1 delims=v" %%i in ('node -v') do set NODE_VERSION=%%i
for /f "tokens=1 delims=." %%i in ('node -v') do set NODE_MAJOR=%%i
echo Versao do Node.js: %NODE_MAJOR%

REM Avisar se Node 22+
echo %NODE_MAJOR% | findstr /r "v22 v23 v24" >nul
if not errorlevel 1 (
    echo.
    echo [ERRO] Voce esta usando Node.js %NODE_MAJOR% que NAO e compativel!
    echo.
    echo O Expo requer Node.js 18 ou 20 LTS.
    echo.
    echo Solucao:
    echo   1. Desinstale o Node.js atual
    echo   2. Instale o Node.js 20 LTS em: https://nodejs.org/
    echo   3. Ou use nvm: nvm install 20 ^&^& nvm use 20
    echo.
    pause
    exit /b 1
)

REM Verificar Java
where java >nul 2>nul
if errorlevel 1 (
    echo [ERRO] Java JDK nao encontrado!
    echo Instale em: https://adoptium.net/
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

echo [1/3] Instalando dependencias...
call npm install
if errorlevel 1 goto error

echo [2/3] Gerando projeto Android nativo...
call npx expo prebuild --platform android
if errorlevel 1 goto error

echo [3/3] Compilando APK...
cd android
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
echo   1. Node.js 18+ instalado
echo   2. Java JDK 17 instalado
echo   3. Android Studio com SDK instalado
echo   4. Variavel ANDROID_HOME configurada
echo.
pause
exit /b 1
