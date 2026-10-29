<?php
/*  ================================================================
    DEMO ÉTICA — endpoint DELIBERADAMENTE vulnerable (inyección de comandos)
    ----------------------------------------------------------------
    NO es el exploit de PHP2Shell. NO usar en producción NUNCA.
    Sirve para que el público VEA qué es RCE: una petición web que
    termina ejecutando comandos en el servidor.

    El bug es un clásico: un dev quiso hacer una "herramienta de
    diagnóstico" y metió la entrada del usuario directo en system().
    ================================================================ */

header('Content-Type: text/plain; charset=utf-8');
$host = $_GET['host'] ?? '';

if ($host === '') {
    echo "Herramienta de diagnóstico de red\n";
    echo "Uso: ?host=8.8.8.8\n";
    exit;
}

echo "# Diagnóstico de: {$host}\n";
echo str_repeat('-', 40) . "\n";

//  <<< LA LÍNEA VULNERABLE >>>
//  $host entra sin validar ni escapar. Un ';' o un '&&' encadena comandos.
system("echo Resolviendo... && getent hosts " . $host);
