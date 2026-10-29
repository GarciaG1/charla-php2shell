<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Panel de red — demo</title>
<style>
  body{background:#070a14;color:#f1f4fc;font-family:system-ui,sans-serif;display:grid;place-items:center;height:100vh;margin:0}
  .card{text-align:center;padding:40px 48px;border:1px solid rgba(255,255,255,.12);border-radius:20px;background:#0f1628;max-width:460px}
  h1{margin:0 0 6px;font-size:24px}
  small{color:#6b7796;display:block;margin-bottom:18px}
  input{width:220px;background:#04070e;border:1px solid rgba(255,255,255,.15);border-radius:8px;padding:10px 12px;color:#f1f4fc;font-family:monospace}
  a.btn{display:inline-block;margin-top:14px;background:#ff2e83;color:#fff;text-decoration:none;padding:10px 18px;border-radius:8px;font-weight:600}
  .warn{margin-top:20px;font-size:12px;color:#ffc24d}
</style></head>
<body>
  <div class="card">
    <h1>🛠️ Panel de red — Diagnóstico</h1>
    <small>Herramienta interna para revisar conectividad.</small>
    <form action="diagnostico.php" method="get">
      <input name="host" value="localhost" aria-label="host">
      <br><a class="btn" href="diagnostico.php?host=localhost">Diagnosticar</a>
    </form>
    <div class="warn">⚠ Demo educativa: este endpoint es vulnerable a propósito.</div>
  </div>
</body></html>
