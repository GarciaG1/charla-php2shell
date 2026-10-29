<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Mi sitio — demo PHP2Shell</title>
<style>
  body{background:#070a14;color:#f1f4fc;font-family:system-ui,sans-serif;display:grid;place-items:center;height:100vh;margin:0}
  .card{text-align:center;padding:40px 48px;border:1px solid rgba(255,255,255,.12);border-radius:20px;background:#0f1628}
  h1{margin:0 0 6px;font-size:28px}
  .v{font-family:"JetBrains Mono",Consolas,monospace;font-size:20px;color:#ff2e83;margin-top:14px}
  .up{font-family:"JetBrains Mono",Consolas,monospace;font-size:13px;color:#43e08f;margin-top:10px}
  small{color:#6b7796}
</style></head>
<body>
  <div class="card">
    <h1>Mi sitio de siempre 🛍️</h1>
    <small>Un sitio normal, atendiendo peticiones por el puerto 80.</small>
    <div class="v">PHP <?= PHP_VERSION ?> · <?= php_sapi_name() ?></div>
    <div class="up">session.upload_progress.enabled =
      <?= ini_get('session.upload_progress.enabled') ? 'ON (riesgo)' : 'OFF (mitigado)' ?></div>
  </div>
</body></html>
