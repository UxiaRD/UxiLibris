@echo off
:: ============================================================
::  MODO D — Frontend Flutter en emulador Android (AVD)
::  Requisitos: Android Studio con un AVD arrancado,
::              Flutter SDK instalado,
::              El backend arrancado desde IntelliJ (localhost:8080)
::
::  IMPORTANTE: Este script es para el EMULADOR (AVD), no para
::  un movil fisico conectado por USB.
::  Para movil fisico usa: modoD_dev_android_movil.bat
::
::  10.0.2.2 es la IP que el emulador usa para llegar al localhost
::  del ordenador anfitrion.
:: ============================================================

cd /d "%~dp0.."

echo.
echo [UxiLibris] Arrancando Flutter en emulador Android...
echo   Backend: http://localhost:8080  (IntelliJ)
echo   IP emulador: 10.0.2.2:8080
echo.

cd frontend_flutter
call flutter run --dart-define=BACKEND_URL=http://10.0.2.2:8080

pause