@echo off
echo ============================================
echo   Acelera Facilities - Build APK Windows
echo ============================================
echo.

REM Verificar se estamos em um caminho curto
set "CURRENT_PATH=%CD%"
call :strlen CURRENT_PATH PATH_LEN

if %PATH_LEN% GTR 50 (
    echo ERRO: Caminho muito longo!
    echo Atual: %CD%
    echo.
    echo O caminho deve ter menos de 50 caracteres.
    echo.
    echo SOLUCAO:
    echo 1. Crie a pasta C:\AceleraApp
    echo 2. Copie a pasta 'mobile' para C:\AceleraApp\mobile
    echo 3. Abra o terminal em C:\AceleraApp\mobile
    echo 4. Execute este script novamente
    echo.
    pause
    exit /b 1
)

echo Caminho OK: %CD%
echo.

REM Limpar build anterior
echo [1/5] Limpando build anterior...
if exist node_modules rmdir /s /q node_modules
if exist android rmdir /s /q android
if exist .expo rmdir /s /q .expo
if exist package-lock.json del package-lock.json

REM Instalar dependencias
echo [2/5] Instalando dependencias...
call npm install
if errorlevel 1 goto :error

REM Corrigir versoes
echo [3/5] Corrigindo versoes Expo...
call npx expo install --fix
if errorlevel 1 goto :error

REM Gerar projeto Android
echo [4/5] Gerando projeto Android nativo...
call npx expo prebuild --platform android --clean
if errorlevel 1 goto :error

REM Compilar APK
echo [5/5] Compilando APK Release...
cd android
call .\gradlew.bat clean
call .\gradlew.bat assembleRelease
if errorlevel 1 goto :error

cd ..

echo.
echo ============================================
echo   BUILD CONCLUIDO COM SUCESSO!
echo ============================================
echo.
echo APK gerado em:
echo android\app\build\outputs\apk\release\app-release.apk
echo.
pause
exit /b 0

:error
echo.
echo ============================================
echo   ERRO NO BUILD!
echo ============================================
echo Verifique os erros acima e tente novamente.
pause
exit /b 1

:strlen <stringVar> <resultVar>
setlocal enabledelayedexpansion
set "s=!%~1!#"
set "len=0"
for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
    if "!s:~%%P,1!" NEQ "" ( 
        set /a "len+=%%P"
        set "s=!s:~%%P!"
    )
)
endlocal & set "%~2=%len%"
exit /b
