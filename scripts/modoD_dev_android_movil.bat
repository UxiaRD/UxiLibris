@echo off
:: ============================================================
::  MODO D — Frontend Flutter en movil fisico (USB)
::  Requisitos: Movil conectado por USB con depuracion activada,
::              Flutter SDK instalado,
::              El backend arrancado desde IntelliJ (localhost:8080)
::              El movil y el PC en la misma red Wi-Fi
::
::  IMPORTANTE: Cambia IP_LOCAL por la IP de tu PC en el Wi-Fi.
::  Para verla: ipconfig -> Direccion IPv4 del adaptador Wi-Fi
:: ============================================================

:: ► Cambia esta IP por la tuya si ha cambiado
SET IP_LOCAL=192.168.1.200

cd /d "%~dp0.."

echo.
echo [UxiLibris] Arrancando Flutter en movil fisico...
echo   Backend: http://%IP_LOCAL%:8080  (IntelliJ)
echo.

cd frontend_flutter
call flutter run --dart-define=BACKEND_URL=http://%IP_LOCAL%:8080

pause