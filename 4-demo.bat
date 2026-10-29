@echo off
title Demo PHP2Shell
cd /d "%~dp0"
cls
echo.
echo  === PASO 1 de 4 - Que PHP tengo en esta maquina? ===
echo.
echo  $ php -v
php -v
echo.
pause
cls
echo.
echo  === PASO 2 de 4 - Revision: esta maquina y los contenedores corriendo ===
echo.
echo  $ python revisar_php.py
set PYTHONIOENCODING=utf-8
python revisar_php.py
echo.
pause
cls
echo.
echo  === PASO 3 de 4 - Una imagen de Docker que tenia guardada ===
echo.
echo  $ docker run --rm php:8.2-apache php -v
docker image inspect php:8.2-apache >nul 2>&1
if errorlevel 1 (echo  [no tengo la imagen php:8.2-apache en esta maquina]) else (docker run --rm php:8.2-apache php -v)
echo.
echo  El servidor ya esta actualizado, pero esta imagen trae su propio PHP viejo.
echo.
pause
cls
echo.
echo  === PASO 4 de 4 - La imagen oficial corregida ===
echo.
echo  $ docker run --rm php:8.2.35-apache php -v
docker image inspect php:8.2.35-apache >nul 2>&1
if errorlevel 1 (echo  [falta descargarla antes de la charla: docker pull php:8.2.35-apache]) else (docker run --rm php:8.2.35-apache php -v)
echo.
echo  En contenedores: reconstruir con la imagen base corregida y volver a desplegar.
echo.
pause
cls
echo.
echo  === EXTRA - Revisar TODAS las imagenes (tarda cerca de 80 segundos) ===
echo.
choice /c SN /m "  Lo corro"
if errorlevel 2 goto fin
python revisar_php.py --imagenes
echo.
pause
:fin
