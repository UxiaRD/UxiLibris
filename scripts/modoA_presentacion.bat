@echo off
:: ============================================================
::  MODO A — Presentacion web (frontend local + backend en Render)
::  Requisitos: Flutter SDK instalado + Docker Desktop corriendo
::  Acceso:     http://localhost
::
::  El frontend se compila apuntando al backend de Render, por lo
::  que los datos son los reales de la base de datos en Neon.
::  No se levanta ni base de datos ni backend local.
:: ============================================================

:: ► URL del servicio en Render
SET RENDER_URL=https://uxilibris-backend.onrender.com

cd /d "%~dp0.."

echo.
echo [1/2] Compilando frontend web apuntando a: %RENDER_URL%
echo.
cd frontend_flutter
call flutter pub get
call flutter build web --release --dart-define=BACKEND_URL=%RENDER_URL%

if errorlevel 1 (
    echo.
    echo [ERROR] La compilacion fallo. Revisa los errores anteriores.
    echo.
    pause
    exit /b 1
)
cd ..

echo.
echo [2/2] Levantando nginx con los datos de Neon...
echo       Primera vez: descarga la imagen de nginx (segundos).
echo.
docker compose -f docker-compose.presentacion.yml up

pause