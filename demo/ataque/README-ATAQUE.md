# Ataque ético controlado — qué es un RCE

Demostración educativa de qué es la **ejecución remota de código (RCE)**: una petición
web que termina ejecutando comandos en el servidor. Corre en un contenedor local aislado,
contra una app de juguete vulnerable a propósito.

**No es el exploit de PHP2Shell.** Es una ilustración segura del concepto. Para la
explotación real hands-on existen laboratorios controlados dedicados (ver el final).

## Qué muestra
- Un endpoint de "diagnóstico" que concatena la entrada del usuario dentro de `system()`
  (inyección de comandos: un bug clásico).
- Cómo una sola petición web pasa de uso normal a ejecutar comandos en el servidor.
- El indicador con el que se detecta el escaneo real de PHP2Shell.

## Correr
Windows: `ataque-demo.bat` (pasos con pausas).
Manual:
```bash
docker run -d --name php2shell-ataque -p 8081:80 -v "$PWD/app":/var/www/html:ro php:8.2-apache
```

## Pasos

### 1 · Uso normal
```bash
curl "http://localhost:8081/diagnostico.php?host=localhost"
```
Resuelve el host; se ve inofensivo.

### 2 · Inyección de comandos
```bash
curl "http://localhost:8081/diagnostico.php?host=localhost;id"
```
Además del diagnóstico, ejecuta `id` y devuelve `uid=33(www-data)`: comandos corriendo en
el servidor, sin usuario ni contraseña.

### 3 · Alcance
```bash
curl "http://localhost:8081/diagnostico.php?host=localhost;hostname;cat%20/etc/passwd"
```
Lee archivos del servidor. Esto es un RCE. PHP2Shell logra lo mismo —ejecutar comandos—
pero por un **bug de memoria**, no por un `system()` visible: por eso no hay un patrón
"malo" evidente que un WAF o una revisión de código puedan detectar.

### 4 · Detección
```bash
grep -i "PHP_SESSION_UPLOAD_PROGRESS" muestra-escaneo.txt
```
El indicador de PHP2Shell es un POST multipart con el campo `PHP_SESSION_UPLOAD_PROGRESS`,
aunque el sitio no suba archivos. Es lo que se busca en un WAF, una captura o un honeypot.

### Limpieza
```bash
docker rm -f php2shell-ataque
```

## Por qué una app de juguete y no el exploit real
El exploit real de PHP2Shell es corrupción de memoria: poco fiable fuera de un laboratorio
y sin nada visible que mostrar. Una inyección de comandos ilustra el concepto de RCE en una
sola línea, de forma segura y reproducible.

## Explotación real (hands-on)
Para experimentar con el exploit real de PHP2Shell, usa un laboratorio controlado dedicado
(por ejemplo, el laboratorio público de OffSec). Nunca en producción ni en redes ajenas.
