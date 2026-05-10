@echo off
:: ============================================================
::  MODO A — Compilar e instalar APK actualizada en el móvil
::  Requisitos: Flutter SDK + ADB instalados, móvil conectado
::              por USB con depuración USB activada
::  Resultado:  APK instalada/actualizada directamente en el móvil
:: ============================================================

:: ► URL del servicio en Render
SET RENDER_URL=https://uxilibris-backend.onrender.com

:: ── Moverse a la raíz del proyecto ──────────────────────────
cd /d "%~dp0.."

echo.
echo [UxiLibris] Compilando APK apuntando a: %RENDER_URL%
echo.

cd frontend_flutter
call flutter pub get
call flutter build apk --release --dart-define=BACKEND_URL=%RENDER_URL%

if errorlevel 1 (
    echo.
    echo [ERROR] La compilacion fallo. Revisa los errores anteriores.
    echo.
    pause
    exit /b 1
)

echo.
echo [UxiLibris] Instalando APK en el movil...
echo.

adb install -r build\app\outputs\flutter-apk\app-release.apk

if errorlevel 1 (
    echo.
    echo [ERROR] No se pudo instalar la APK.
    echo   - Comprueba que el movil esta conectado por USB
    echo   - Activa la depuracion USB en Ajustes ^> Opciones de desarrollador
    echo   - Ejecuta "adb devices" para verificar que el movil se detecta
    echo.
) else (
    echo.
    echo [OK] APK actualizada correctamente en el movil.
    echo.
)

pause