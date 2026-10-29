# Demo PHP2Shell — "De vulnerable a parchado"

Demo reproducible: levanta un sitio real sobre PHP vulnerable y recorre el ciclo de
respuesta **detectar → mitigar → parchar → verificar**. No contiene ningún exploit.

## Qué muestra
- Un sitio real sirviendo PHP 8.2.30 (vulnerable) en `http://localhost:8080`.
- El checker `revisar_php.py` marcándolo como `VULNERABLE`.
- La mitigación temporal aplicada y verificada (es paliativo: no corrige la versión).
- La reconstrucción con una imagen base corregida (8.2.35) y la verificación final.

## Antes de correrlo (con internet)
```bash
docker pull php:8.2.30-apache     # PHP vulnerable (demo)
docker pull php:8.2-apache        # PHP ya parchado de la rama 8.2
```
Confirma la versión parchada: `docker run --rm php:8.2-apache php -v` → 8.2.35 o posterior.

## Pasos

### 1 · Detectar
```bash
docker run -d --name php2shell-demo -p 8080:80 -v "$PWD/www":/var/www/html:ro php:8.2.30-apache
```
Abre `http://localhost:8080` (se ve un sitio normal). Luego:
```bash
python ../revisar_php.py
```
El contenedor aparece como `8.2.30 · VULNERABLE`.

### 2 · Mitigar
Recrea el contenedor montando la mitigación:
```bash
docker rm -f php2shell-demo
docker run -d --name php2shell-demo -p 8080:80 \
  -v "$PWD/www":/var/www/html:ro \
  -v "$PWD/mitigacion/php2shell.ini":/usr/local/etc/php/conf.d/zz-php2shell.ini:ro \
  php:8.2.30-apache
docker exec php2shell-demo php -i | grep session.upload_progress.enabled
```
Queda en `Off` y la página muestra "OFF (mitigado)", pero la versión sigue siendo 8.2.30:
es paliativo, no corrige la CVE-2026-109618.

### 3 · Parchar
```bash
docker rm -f php2shell-demo
docker run -d --name php2shell-demo -p 8080:80 -v "$PWD/www":/var/www/html:ro php:8.2-apache
docker exec php2shell-demo php -v
```
Ahora reporta 8.2.35. En un proyecto real: `docker compose build --pull && docker compose up -d`.

### 4 · Verificar
```bash
python ../revisar_php.py
```
El contenedor aparece como `CORREGIDO`.

### Limpieza
```bash
docker rm -f php2shell-demo
```

## Atajo (Windows)
Ejecuta `correr-demo.bat`: realiza los 4 pasos con pausas.
Equivalente con Compose: `docker compose up -d` usa el `docker-compose.yml` de esta carpeta.

## Si Docker no está disponible
Ejecuta solo `python revisar_php.py` para revisar la máquina y las imágenes locales.

## Explotación real
Para ver la explotación de PHP2Shell en un entorno controlado, usa un laboratorio
dedicado (por ejemplo, el laboratorio público de OffSec). Nunca en producción ni en redes ajenas.
