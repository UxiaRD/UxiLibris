@echo off
:: ============================================================
::  MODO B — Parar los servicios Docker
::
::  Opcion 1 (conserva datos de la BD):
::    docker compose down          <- lo que hace este script
::
::  Opcion 2 (borra tambien los datos de la BD):
::    docker compose down -v       <- descomenta la linea de abajo
:: ============================================================

cd /d "%~dp0.."

echo.
echo [UxiLibris] Parando servicios Docker...
echo.
docker compose down
:: docker compose down -v

echo.
echo Servicios parados. Los datos de la base de datos se han conservado.
echo.
pause