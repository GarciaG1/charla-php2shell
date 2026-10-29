@echo off
title Demo PHP2Shell - detectar, mitigar, parchar, verificar
cd /d "%~dp0"
set PYTHONIOENCODING=utf-8
set NAME=php2shell-demo
set VIEJA=php:8.2.30-apache
set NUEVA=php:8.2-apache

where docker >nul 2>&1 || (echo  No encuentro Docker. Abre Docker Desktop y vuelve a intentar. & pause & exit /b)
docker info >nul 2>&1 || (echo  Docker no responde. Abre Docker Desktop y espera a que inicie. & pause & exit /b)

cls
echo.
echo   DEMO PHP2Shell - de vulnerable a parchado, en vivo
echo   ---------------------------------------------------
echo   Sin exploits: solo detectar, mitigar, parchar y verificar.
echo.
echo   Usara las imagenes:  %VIEJA%  (vulnerable)  y  %NUEVA%  (parchada)
echo   Descargalas antes si no las tienes:  docker pull %VIEJA%  ^&^&  docker pull %NUEVA%
echo.
pause

:: ---------- PASO 1 : DETECTAR ----------
cls
echo.
echo   === PASO 1 de 4 - DETECTAR : levanto un sitio con PHP viejo ===
echo.
docker rm -f %NAME% >nul 2>&1
docker run -d --name %NAME% -p 8080:80 -v "%cd%\www":/var/www/html:ro %VIEJA% >nul
echo   Sitio arriba en http://localhost:8080  (se ve normal)
start "" http://localhost:8080
echo.
echo   $ python ..\revisar_php.py
python ..\revisar_php.py
echo.
echo   ^>^> Mi laptop esta al dia, pero el contenedor dice VULNERABLE.
echo.
pause

:: ---------- PASO 2 : MITIGAR ----------
cls
echo.
echo   === PASO 2 de 4 - MITIGAR : hoy no puedo actualizar ===
echo.
docker rm -f %NAME% >nul 2>&1
docker run -d --name %NAME% -p 8080:80 -v "%cd%\www":/var/www/html:ro -v "%cd%\mitigacion\php2shell.ini":/usr/local/etc/php/conf.d/zz-php2shell.ini:ro %VIEJA% >nul
echo   $ docker exec %NAME% php -i ^| findstr session.upload_progress.enabled
docker exec %NAME% php -i | findstr /i upload_progress.enabled
echo.
echo   Refresca http://localhost:8080  -^>  ahora dice OFF (mitigado)
echo   ^>^> Pero la version sigue siendo vieja. Es un curita, no la cura.
echo.
pause

:: ---------- PASO 3 : PARCHAR ----------
cls
echo.
echo   === PASO 3 de 4 - PARCHAR : reconstruyo con la base corregida ===
echo.
docker rm -f %NAME% >nul 2>&1
echo   $ docker pull %NUEVA%
docker pull %NUEVA%
docker run -d --name %NAME% -p 8080:80 -v "%cd%\www":/var/www/html:ro %NUEVA% >nul
echo.
echo   $ docker exec %NAME% php -v
docker exec %NAME% php -v
echo.
echo   ^>^> No parche el host: reconstrui el contenedor. Cada imagen trae su propio PHP.
echo.
pause

:: ---------- PASO 4 : VERIFICAR ----------
cls
echo.
echo   === PASO 4 de 4 - VERIFICAR : quedo? ===
echo.
echo   $ python ..\revisar_php.py
python ..\revisar_php.py
echo.
echo   ^>^> El contenedor ahora dice CORREGIDO. Esa es toda la historia en 4 comandos.
echo.
pause

:: ---------- LIMPIEZA ----------
cls
echo.
choice /c SN /m "  Borro el contenedor del demo"
if errorlevel 2 goto fin
docker rm -f %NAME% >nul 2>&1
echo   Listo, contenedor borrado.
:fin
echo.
pause
