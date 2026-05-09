@echo off
:: ============================================================
::  MODO B — Docker local (presentacion en navegador)
::  Requisitos: Docker Desktop corriendo + Flutter SDK instalado
::  Acceso:     http://localhost  (app)
::              http://localhost:8080/api  (backend)
::
::  Este script compila el frontend web y levanta todos los servicios.
::  Si el frontend ya esta compilado y no hay cambios en el codigo,
::  puedes saltar la compilacion ejecutando modoB_docker_solo_levantar.bat
:: ============================================================

cd /d "%~dp0.."

echo.
echo [1/2] Compilando frontend web Flutter...
echo.
cd frontend_flutter
call flutter pub get
call flutter build web --release
cd ..

echo.
echo [2/2] Levantando servicios Docker (BD + backend + nginx)...
echo       Primera vez: puede tardar 5-10 min descargando imagenes.
echo.
docker compose up --build

pause