# PHP2Shell — demos y guía de parcheo

Herramientas educativas y reproducibles sobre **PHP2Shell**
(CVE-2026-109618 / CVE-2026-109619): una guía de parcheo paso a paso y demos en vivo.

Todo es HTML y scripts autocontenidos. Para los demos en vivo necesitas Docker y Python.

## Guía de parcheo

`guia-parcheo.html` (ábrela en el navegador, o `5-guia.bat` en Windows): cómo actualizar
PHP correctamente por **sistema operativo** (Debian/Ubuntu, RHEL/Rocky/Alma, Fedora,
openSUSE, Arch, Alpine, FreeBSD, macOS, Windows) y por **servidor web**
(Apache+mod_php, PHP-FPM, Nginx, LiteSpeed, Caddy, FrankenPHP, IIS), más contenedores,
paneles, mitigación temporal y verificación.

## Demos

- **`revisar_php.py`** — checker de solo lectura: revisa la versión de PHP de esta
  máquina, de los contenedores en ejecución y, con `--imagenes`, de tus imágenes
  Docker. No modifica nada.
- **`demo/`** — ciclo de remediación **detectar → mitigar → parchar → verificar** sobre
  un contenedor real (ver `demo/DEMO.md`).
- **`demo/ataque/`** — demostración **ética y controlada** de qué es un RCE, con una app
  de juguete vulnerable a propósito. **No es el exploit de PHP2Shell**; para la
  explotación real hands-on existen laboratorios controlados dedicados
  (ver `demo/ataque/README-ATAQUE.md`).

### Lanzadores (Windows)

| Lanzador | Qué hace |
|---|---|
| `4-demo.bat` | Demo rápido de detección |
| `5-guia.bat` | Abre la guía de parcheo |
| `6-demo-lab.bat` | Demo en vivo: vulnerable → parchado |
| `8-ataque-etico.bat` | Ataque ético controlado: una petición web → RCE |

En Linux/macOS, abre `guia-parcheo.html` en el navegador y usa los comandos de
`demo/DEMO.md` y `demo/ataque/README-ATAQUE.md`.

## Aviso

Material educativo. Los avisos de seguridad cambian día a día: valida siempre contra
el aviso oficial de tu distribución antes de actuar.
