# Ataque ético controlado — "¿qué es RCE?"

Un demo que el público **sí ve**: una petición web convirtiéndose en comandos
en el servidor. Todo en tu laptop, en un contenedor aislado, contra una app de
juguete vulnerable a propósito.

> **Esto NO es el exploit de PHP2Shell** y no pretende serlo. Es la forma honesta
> y segura de mostrar *qué logra* un RCE, sin repartir un arma funcional para un
> bug que ahorita se explota en millones de servidores. Para la explotación real
> hands-on existe un laboratorio controlado (ver el final).

---

## Por qué así y no "el exploit de verdad"
- El exploit real de PHP2Shell es **corrupción de memoria**: poco confiable en vivo
  (depende de ASLR y del heap) e **invisible** para el público — no se "ve" nada.
- Un `system()` de juguete, en cambio, deja ver el RCE en una línea: entra una
  petición, sale la salida de un comando. El público entiende en 10 segundos.
- Y es **consistente con tu charla**: "el código de prueba ya circula; lo útil es
  saber si estás expuesto y cómo corregirlo".

## Correr el demo
Windows: abre **`ataque-demo.bat`** (hace los pasos con pausas).
Manual (cualquier SO):
```bash
docker run -d --name php2shell-ataque -p 8081:80 -v "$PWD/app":/var/www/html:ro php:8.2-apache
```

## Guion (4 momentos)

### 1 · Uso normal — "un panel interno de diagnóstico"
```bash
curl "http://localhost:8081/diagnostico.php?host=localhost"
```
> "Se ve inofensivo: le das un host y lo diagnostica. Un dev lo escribió en 5 minutos."

### 2 · El ataque — "encadeno un comando"
```bash
curl "http://localhost:8081/diagnostico.php?host=localhost;id"
```
> "Una sola petición web, sin usuario ni contraseña, y ya corro `id` como el usuario
> del servidor. Eso es **ejecución remota de código**."

### 3 · Hasta dónde llega — "leo archivos"
```bash
curl "http://localhost:8081/diagnostico.php?host=localhost;hostname;cat%20/etc/passwd"
```
> **El puente con tu charla:** "PHP2Shell logra EXACTAMENTE esto — correr comandos —
> pero por un **bug de memoria**, no por un `system()` obvio. Por eso ni el WAF ni la
> revisión de código lo atraparon: no hay un patrón 'malo' que buscar."

### 4 · La vista del defensor — "cómo se ve y se detecta el escaneo real"
```bash
grep -i "PHP_SESSION_UPLOAD_PROGRESS" muestra-escaneo.txt
```
> "El indicador de PHP2Shell: un POST multipart con el campo
> `PHP_SESSION_UPLOAD_PROGRESS`, aunque el sitio no suba archivos. Eso es lo que
> buscas en tu WAF, en una captura o en un honeypot." (Conecta con tu slide
> *¿cómo sé si ya entraron?* y la regla SIGMA de CISA.)

### Limpieza
```bash
docker rm -f php2shell-ataque
```

---

## Para quien quiera ver la explotación REAL (hands-on)
OffSec publicó un **laboratorio gratuito de PHP2Shell** en un entorno controlado.
Ese es el lugar correcto para experimentar con el exploit real — no en producción,
no en una red ajena, y no con un arma suelta en tus diapositivas.

## Encuadre ético para decirlo en voz alta (10 segundos)
> "Esto corre en mi laptop, contra una app que yo hice vulnerable a propósito.
> No voy a soltar el exploit de PHP2Shell: es un bug vivo. Lo que les muestro es
> *qué se siente* un RCE, para que entiendan por qué hay que parchar hoy."
