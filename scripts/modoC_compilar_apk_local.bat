@echo off
:: ============================================================
::  MODO C — APK apuntando al backend local (misma red Wi-Fi)
::  Requisitos: Flutter SDK instalado
::              El movil y el PC en la misma red Wi-Fi
::              El backend corriendo localmente (Docker o modo D)
::
::  Para conocer tu IP local ejecuta: ipconfig
::  Busca "Direccion IPv4" en el adaptador Wi-Fi
:: ============================================================

:: ► Cambia esta IP por la tuya (ipconfig -> Direccion IPv4 del Wi-Fi)
SET IP_LOCAL=192.168.1.200

:: ── Moverse a la raíz del proyecto ──────────────────────────
cd /d "%~dp0.."

echo.
echo [UxiLibris] Compilando APK apuntando a: http://%IP_LOCAL%:8080
echo.

cd frontend_flutter
call flutter pub get
call flutter build apk --release --dart-define=BACKEND_URL=http://%IP_LOCAL%:8080

echo.
echo APK generado en:
echo   frontend_flutter\build\app\outputs\flutter-apk\app-release.apk
echo.
echo Para instalarlo directamente con el movil conectado por USB:
echo   flutter install
echo.
pause