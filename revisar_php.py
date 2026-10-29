#!/usr/bin/env python3
"""
revisar_php.py — ¿Mi PHP está expuesto a PHP2Shell (CVE-2026-109618 / CVE-2026-109619)?

Solo LEE versiones y configuración. No modifica nada.

Revisa:
  1. El PHP instalado en esta máquina (php -v / php -i).
  2. Los contenedores Docker que están corriendo (cada uno trae su propia copia de PHP).
  3. Con --imagenes, también las imágenes Docker locales.

Uso:
  python revisar_php.py
  python revisar_php.py --imagenes

Versiones corregidas (aviso del 21 de octubre de 2026): 8.5.12, 8.4.27, 8.3.36 y 8.2.35.
PHP 8.1 y anteriores ya no reciben parches oficiales.

Ojo: las distribuciones Linux (Ubuntu, Debian, RHEL…) suelen corregir sin cambiar el número
de versión. Si tu PHP viene del gestor de paquetes, confirma con el aviso de seguridad de tu distro.
"""
from __future__ import annotations

import re
import shutil
import subprocess
import sys

CORREGIDAS = {(8, 5): (8, 5, 12), (8, 4): (8, 4, 27), (8, 3): (8, 3, 36), (8, 2): (8, 2, 35)}
LEER_CONFIG = ("echo PHP_VERSION, '|', php_sapi_name(), '|', "
               "var_export((bool) ini_get('session.upload_progress.enabled'), true);")


def correr(cmd: list[str], timeout: int = 25) -> str | None:
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return r.stdout.strip() if r.returncode == 0 else None
    except (OSError, subprocess.TimeoutExpired):
        return None


def veredicto(version: str) -> tuple[str, str]:
    m = re.match(r"(\d+)\.(\d+)\.(\d+)", version)
    if not m:
        return "DESCONOCIDO", "No pude leer la versión."
    v = tuple(int(x) for x in m.groups())
    if v[:2] in CORREGIDAS:
        fix = CORREGIDAS[v[:2]]
        if v >= fix:
            return "CORREGIDO", f"{version} ya incluye el parche."
        nota = " (si es paquete de tu distro, confirma su aviso: puede estar parchado)" if re.search(
            r"ubuntu|deb|el\d|fc\d", version, re.I) else ""
        return "VULNERABLE", f"Actualiza a {'.'.join(map(str, fix))} o posterior{nota}."
    if v[:2] > max(CORREGIDAS):
        return "REVISAR", "Versión más nueva que el aviso: confirma en php.net."
    return "SIN SOPORTE", "Rama sin parches oficiales: migra a 8.2+ o pide el backport a tu proveedor."


def leer(cmd_base: list[str]) -> dict | None:
    salida = correr(cmd_base + ["-r", LEER_CONFIG])
    if not salida or "|" not in salida:
        return None
    version, sapi, upload = [x.strip() for x in salida.split("|")]
    return {"version": version, "sapi": sapi, "upload_progress": upload == "true"}


# Si no hay comando "php" (algunas imágenes solo traen php-fpm), busca otro binario de PHP.
SONDA = ("for b in php-fpm php-fpm8.5 php-fpm8.4 php-fpm8.3 php-fpm8.2 php-fpm8.1 php-fpm8.0 php-fpm7.4 "
         "php8.5 php8.4 php8.3 php8.2 php8.1; do command -v $b >/dev/null 2>&1 && { $b -v 2>/dev/null | head -1; exit 0; }; done; exit 1")


def leer_respaldo(cmd_shell: list[str]) -> dict | None:
    salida = correr(cmd_shell + ["-c", SONDA])
    m = re.search(r"PHP (\d+\.\d+\.\d+\S*)", salida or "")
    return {"version": m.group(1), "sapi": "fpm", "upload_progress": None} if m else None


def fila(donde: str, info: dict | None) -> list[str]:
    if not info:
        return [donde, "—", "sin PHP", "—", ""]
    estado, accion = veredicto(info["version"])
    mitig = ("sin revisar" if info["upload_progress"] is None
             else "desactivado (bien)" if not info["upload_progress"] else "ACTIVADO")
    return [donde, info["version"], estado, mitig, accion]


def main() -> int:
    filas = []

    # 1 · esta máquina
    php = shutil.which("php")
    filas.append(fila("Esta máquina", leer([php]) if php else None))

    # 2 · contenedores corriendo / 3 · imágenes
    if shutil.which("docker") and correr(["docker", "info", "--format", "{{.ServerVersion}}"]):
        for nombre in (correr(["docker", "ps", "--format", "{{.Names}}"]) or "").splitlines():
            info = leer(["docker", "exec", nombre, "php"]) or leer_respaldo(["docker", "exec", nombre, "sh"])
            filas.append(fila(f"Contenedor {nombre}", info))
        if "--imagenes" in sys.argv:
            for img in (correr(["docker", "images", "--format", "{{.Repository}}:{{.Tag}}"]) or "").splitlines():
                if img.endswith(":<none>"):
                    continue
                info = (leer(["docker", "run", "--rm", "--entrypoint", "php", img])
                        or leer_respaldo(["docker", "run", "--rm", "--entrypoint", "sh", img]))
                filas.append(fila(f"Imagen {img}", info))
    else:
        filas.append(["Docker", "—", "no disponible", "—", "Abre Docker Desktop para revisar contenedores."])

    titulos = ["Dónde", "Versión", "Estado", "session.upload_progress", "Qué hacer"]
    anchos = [max(len(str(f[i])) for f in filas + [titulos]) for i in range(4)]
    print("\nPHP2Shell · CVE-2026-109618 / CVE-2026-109619 · revisión local\n")
    print("  ".join(t.ljust(anchos[i]) for i, t in enumerate(titulos[:4])) + "  " + titulos[4])
    print("  ".join("-" * a for a in anchos) + "  " + "-" * 9)
    for f in filas:
        print("  ".join(str(f[i]).ljust(anchos[i]) for i in range(4)) + "  " + f[4])
    vulnerables = sum(1 for f in filas if f[2] in ("VULNERABLE", "SIN SOPORTE"))
    print(f"\n{vulnerables} instalación(es) por atender." if vulnerables else "\nNada por atender en lo revisado.")
    print("Mitigación temporal (no sustituye al parche): session.upload_progress.enabled=0 y reiniciar los workers.\n")
    return 1 if vulnerables else 0


if __name__ == "__main__":
    sys.exit(main())
