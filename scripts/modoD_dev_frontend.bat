@echo off
:: ============================================================
::  MODO D — Arrancar el frontend web en local para desarrollo
::  Requisitos: Flutter SDK instalado
::              El backend debe estar corriendo (modoD_dev_backend.bat)
::
::  Abre la app en Chrome conectada a http://localhost:8080/api
::  Hot reload activo: guarda un fichero .dart para ver los cambios.
:: ============================================================

cd /d "%~dp0.."

echo.
echo [UxiLibris] Arrancando frontend Flutter en Chrome...
echo   Conectado a: http://localhost:8080/api
echo   Hot reload: pulsa 'r' en esta ventana para recargar
echo.
cd frontend_flutter
call flutter run -d chrome
pause