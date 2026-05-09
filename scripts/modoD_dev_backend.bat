@echo off
:: ============================================================
::  MODO D — Arrancar el backend en local para desarrollo
::  Requisitos: Java 21 instalado, MySQL corriendo en localhost:3306
::              Base de datos UxiLibrisDB creada (o createDatabaseIfNotExists=true)
::
::  El backend arranca en: http://localhost:8080/api
::  Deja esta ventana abierta mientras desarrollas.
:: ============================================================

cd /d "%~dp0.."

echo.
echo [UxiLibris] Arrancando backend Spring Boot en local...
echo   Acceso: http://localhost:8080/api
echo.
cd backend_spring\uxilibris-backend
call mvnw.cmd spring-boot:run
pause