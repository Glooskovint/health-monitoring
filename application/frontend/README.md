# Orbital / frontend

React + Vite. Únicamente datos ficticios. El diseño sigue `public/DESIGN.md`.

```powershell
npm.cmd install
npm.cmd run dev
```

Abrir http://localhost:3000. No requiere backend en modo demo (predeterminado).

- Acceso: `control@orbital.demo` / `Orbital2026!`.
- `/login`, `/`, `/dashboard`, `/astronautas/:id`, `/alertas`.
- Sesión local de ocho horas, restaurada al recargar. Cerrar sesión elimina la sesión; sincronización entre pestañas y expiración automática.
- Las rutas protegidas son una simulación de UI, no una frontera de seguridad. Nunca usar credenciales ni información médica reales.
- Tres operaciones y ocho astronautas en `src/mocks/catalog.js`.
- `src/mocks/api.js` devuelve mediciones, predicciones y alertas con los campos del contrato `documents/api-contract.md`. Los reconocimientos se guardan localmente; no hay escrituras al backend en modo mock.
- El contrato no define login, operaciones ni catálogo de astronautas. Se simulan explícitamente; el `patient_id` del contrato es el ID del astronauta.
- Para conectar las rutas de telemetría existentes: `VITE_DATA_MODE=api` y opcionalmente `VITE_API_BASE_URL`. El catálogo sigue siendo ficticio: debe mapearse a IDs del backend. No hay fallback silencioso; errores de API se muestran con reintento. La autenticación real requiere definir e integrar un contrato de login; no se generan JWT ficticios.
- Actualización por REST cada 30 segundos. Mocks deterministas en intervalos de diez minutos; no se simulan señales en vivo ni WebSockets.
- Gauges, semáforos y riesgo son demostrativos. Cobertura significa disponibilidad de datos mock, no conectividad de dispositivos reales.
- Fuentes de Google Fonts con alternativas locales; las funciones operan sin descargar fuentes.

```powershell
npm.cmd run build
node --test src/mocks/api.test.js
```

Para desplegar, configurar el servidor para devolver `index.html` en rutas de cliente.
