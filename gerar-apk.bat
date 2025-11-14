@echo off
REM 📱 Script Automático de Build APK Android
REM Execute este script no seu computador (Windows)

echo 🚀 OPUS Facilities - Build APK Android
echo ======================================
echo.

REM 1. Build frontend
echo 📦 [1/3] Compilando frontend (Vite)...
call npm run build:android
if errorlevel 1 goto error

REM 2. Sync com Android
echo 🔄 [2/3] Sincronizando com projeto Android...
call npx cap sync android
if errorlevel 1 goto error

REM 3. Gerar APK
echo 🏗️  [3/3] Gerando APK (pode demorar ~2min na primeira vez)...
cd android
call gradlew.bat assembleDebug
if errorlevel 1 goto error
cd ..

REM Verificar APK
set APK_PATH=android\app\build\outputs\apk\debug\app-debug.apk
if exist "%APK_PATH%" (
    echo.
    echo ✅ APK GERADO COM SUCESSO!
    echo ======================================
    echo 📍 Localização: %APK_PATH%
    echo.
    echo 📲 Para instalar no celular:
    echo    adb install %APK_PATH%
    echo.
    echo Ou transfira o arquivo para o celular e instale manualmente.
    goto end
) else (
    echo ❌ Erro: APK não foi gerado!
    goto error
)

:error
echo.
echo ❌ Erro durante o build!
echo Verifique se você tem:
echo   - Node.js instalado (https://nodejs.org/)
echo   - Java JDK 17+ instalado (https://adoptium.net/)
pause
exit /b 1

:end
pause
