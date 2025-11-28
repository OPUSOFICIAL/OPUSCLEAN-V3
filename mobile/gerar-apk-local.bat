@echo off
REM OPUS Facilities - Build APK Local (Windows)
REM Requer: Node.js 18+, Java JDK 17, Android Studio com SDK

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
