@echo off
:: ============================================================
::  MODO A — APK apuntando al backend en Render (nube)
::  Requisitos: Flutter SDK instalado
::  Resultado:  frontend_flutter\build\app\outputs\flutter-apk\app-release.apk
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

echo.
echo APK generado en:
echo   frontend_flutter\build\app\outputs\flutter-apk\app-release.apk
echo.
echo Para instalarlo directamente con el movil conectado por USB:
echo   flutter install
echo.
pause