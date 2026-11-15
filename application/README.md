# Prototipo local · Health Monitoring

Panel React + Vite y servidor de demostración Node (sin dependencias adicionales).
Requiere Node 22 o posterior. Ejecutar desde `application` en dos terminales:

```powershell
node backend/server.mjs
```

```powershell
cd frontend
npm.cmd install
npm.cmd run dev
```

Abrir http://localhost:3000. Vite reenvía `/api` y `/health` a `127.0.0.1:8000`.
Los datos de muestra están únicamente en `../infrastructure/data/sample/monitoring-demo.json`.
Las mediciones se generan en memoria a partir de esas semillas. Los cambios se pierden al reiniciar.

## Alcance

- Selección y búsqueda de pacientes, cinco signos vitales, historial de 1h/6h/24h/7d y exportación CSV.
- Riesgo ficticio, alertas con reconocimiento y estado real de disponibilidad de los servicios del prototipo.
- Rutas REST y campos de respuesta del contrato en `../documents/api-contract.md`, incluyendo creación de mediciones, paginación, filtros de tiempo y tendencias de riesgo.
- Única extensión: `GET /api/demo/patients`, exclusivamente para descubrir los pacientes ficticios; el contrato no define una ruta de listado de pacientes.

## Límites explícitos

Es un adaptador de demostración temporal; la arquitectura objetivo sigue siendo FastAPI y PostgreSQL.
Solo escucha en loopback. No tiene autenticación JWT, autorización, limitación de peticiones, almacenamiento persistente ni modelo de ML.
El usuario que reconoce alertas es una identidad fija de demostración, sin sesión real.
No implementa los WebSockets del contrato: la interfaz consulta REST cada cinco segundos.
Los datos no cambian espontáneamente; una nueva medición puede enviarse con el POST documentado.
Los estados de DB, Redis y ML se muestran como no disponibles, nunca como servicios sanos simulados.
Los umbrales son valores de demostración, sin configuración clínica ni escalamiento.
No usar con datos reales ni para decisiones clínicas y no exponerlo a una red pública.

## Validación

```powershell
node --test backend/server.test.mjs
cd frontend
npm.cmd run build
```

El Dockerfile existente corresponde al backend Python previsto; no se utiliza para este adaptador Node.
