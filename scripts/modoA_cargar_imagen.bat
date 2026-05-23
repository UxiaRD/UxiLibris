@echo off
:: ============================================================
::  Carga y arranca UxiLibris desde uxilibris-web.tar.gz
::  Requisitos: Docker Desktop corriendo
::  Acceso:     http://localhost
:: ============================================================

cd /d "%~dp0.."

echo.
echo [1/2] Cargando imagen Docker...
echo.
docker load < uxilibris-web.tar.gz
if errorlevel 1 (
    echo [ERROR] No se pudo cargar la imagen. Comprueba que el archivo existe.
    pause & exit /b 1
)

echo.
echo [2/2] Arrancando UxiLibris en http://localhost ...
echo       Ctrl+C para detener.
echo.
docker run --rm -p 80:80 uxilibris-web

pause