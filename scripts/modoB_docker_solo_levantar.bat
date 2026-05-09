@echo off
:: ============================================================
::  MODO B — Levantar Docker SIN recompilar el frontend
::  Usa esto cuando el frontend ya esta compilado (build/web existe)
::  y solo quieres reiniciar los contenedores rapidamente.
:: ============================================================

cd /d "%~dp0.."

echo.
echo [UxiLibris] Levantando servicios Docker sin recompilar...
echo.
docker compose up

pause