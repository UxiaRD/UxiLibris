@echo off
:: ============================================================
::  Genera uxilibris-web.tar.gz listo para llevar a cualquier
::  maquina con Docker. No necesita Flutter ni el proyecto.
::  Resultado: uxilibris-web.tar.gz (aprox. 15-25 MB)
:: ============================================================

SET RENDER_URL=https://uxilibris-backend.onrender.com

cd /d "%~dp0.."

echo.
echo [1/3] Compilando frontend web apuntando a: %RENDER_URL%
echo.
cd frontend_flutter
call flutter pub get
call flutter build web --release --dart-define=BACKEND_URL=%RENDER_URL%
if errorlevel 1 (
    echo [ERROR] Fallo la compilacion Flutter.
    pause & exit /b 1
)
cd ..

echo.
echo [2/3] Construyendo imagen Docker...
echo.
docker build -f Dockerfile.presentacion -t uxilibris-web .
if errorlevel 1 (
    echo [ERROR] Fallo la construccion de la imagen Docker.
    pause & exit /b 1
)

echo.
echo [3/3] Exportando imagen a uxilibris-web.tar.gz ...
echo.
docker save uxilibris-web | gzip > uxilibris-web.tar.gz

echo.
echo [OK] Archivo generado: uxilibris-web.tar.gz
echo      Llevalo a la presentacion junto con modoA_cargar_imagen.bat
echo.
pause