# Demo PHP2Shell — "De vulnerable a parchado, en vivo"

Un demo **honesto y replicable**: levantamos un sitio real sobre PHP vulnerable y
recorremos el ciclo que todos harán el lunes — **detectar → mitigar → parchar → verificar**.

**No hay ningún exploit aquí.** No se muestra cómo atacar: se muestra cómo *responder*.
Eso es lo que tiene valor para la audiencia y lo que pueden repetir sin riesgo.
Si alguien quiere ver una explotación real, hay un laboratorio controlado de OffSec
(ver el final); pero el poder del demo está en el ciclo de remediación.

---

## Por qué este demo sí aporta
- **Es real, no teatro:** el `php -v` cambia de verdad, el checker pasa de `VULNERABLE` a `CORREGIDO`.
- **Lo pueden replicar:** son 4 comandos de Docker; cualquiera lo hace en su laptop.
- **Refuerza el mensaje de la charla:** el host puede estar al día y el contenedor no —
  cada imagen trae su propio PHP.
- **Muestra la diferencia curita vs. cura:** la mitigación apaga una luz, pero la versión sigue vieja.

## Antes de la charla (pre-stage, con internet)
Descarga las dos imágenes para no depender de la red en vivo:

```bash
docker pull php:8.2.30-apache     # la vieja, vulnerable (demo)
docker pull php:8.2-apache        # la más reciente de la rama 8.2 (ya parchada)
```

> Confirma que `php:8.2-apache` ya trae 8.2.35 o posterior: `docker run --rm php:8.2-apache php -v`.
> Si no, usa el tag exacto `php:8.2.35-apache`.

---

## Guion del demo (4 pasos)

### Paso 1 · Detectar — "tengo un sitio y no sé qué PHP trae"
```bash
docker run -d --name php2shell-demo -p 8080:80 -v "$PWD/www":/var/www/html:ro php:8.2.30-apache
```
Abre **http://localhost:8080** → se ve un sitio normal. Luego:
```bash
python ../revisar_php.py
```
> **Di:** "Mi laptop está al día, pero miren el contenedor: `8.2.30 · VULNERABLE`.
> Un sitio que se ve perfecto puede estar corriendo PHP viejo."

### Paso 2 · Mitigar — "hoy no puedo actualizar, ¿qué hago mientras?"
Recrea el contenedor montando la mitigación:
```bash
docker rm -f php2shell-demo
docker run -d --name php2shell-demo -p 8080:80 \
  -v "$PWD/www":/var/www/html:ro \
  -v "$PWD/mitigacion/php2shell.ini":/usr/local/etc/php/conf.d/zz-php2shell.ini:ro \
  php:8.2.30-apache
docker exec php2shell-demo php -i | grep session.upload_progress.enabled
```
Refresca el navegador → ahora dice **OFF (mitigado)**.
> **Di:** "Cerré una puerta (la 109619), pero la versión sigue siendo 8.2.30.
> Es un curita: para la 109618 no sirve. Esto me compra horas, no me arregla el problema."

### Paso 3 · Parchar — "ahora sí, la solución de verdad"
```bash
docker rm -f php2shell-demo
docker run -d --name php2shell-demo -p 8080:80 -v "$PWD/www":/var/www/html:ro php:8.2-apache
docker exec php2shell-demo php -v
```
> **Di:** "Reconstruí con la imagen base corregida. No parché el host: reconstruí el contenedor.
> Ahora corre una versión parchada." (En un proyecto real: `docker compose build --pull && up -d`.)

### Paso 4 · Verificar — "¿quedó?"
```bash
python ../revisar_php.py
```
> **Cierre:** "El contenedor ahora dice `CORREGIDO`. El host no cambió; el contenedor sí.
> Esa es toda la historia de PHP2Shell en cuatro comandos."

### Limpieza
```bash
docker rm -f php2shell-demo
```

---

## Atajo para Windows
En lugar de escribir los comandos, corre **`correr-demo.bat`**: hace los 4 pasos con pausas.
(Equivalente con Compose: `docker compose up -d` usa el `docker-compose.yml` de esta carpeta.)

## Plan B (sin Docker en vivo)
Si la red o Docker fallan, no improvises: ten una **grabación** de los 4 pasos, o corre solo
`python revisar_php.py` sobre tu laptop (ya muestra tus imágenes reales). El mensaje es el mismo.

## Para quien quiera ver la explotación real
OffSec publicó un **laboratorio gratuito de PHP2Shell** en un entorno controlado. Es el lugar
correcto para experimentar con el ataque — no en producción y no en este demo.
