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

## Gemelo anatómico 3D

Implementado siguiendo `.claude/skills/3d-design/SKILL.md`. La ruta
`/astronautas/:id` incluye el maniquí con geometrías primitivas locales y
proporción de 7,75 cabezas. No requiere modelos GLTF ni servicios externos.

- `components/digital-twin/humanRig.js`: construye el árbol de grupos Three.js,
  segmentos solapados y anclajes anatómicos; reutiliza geometrías y materiales.
- `rigConfig.js`: proporciones, límites articulares en grados y poses de ejemplo.
- `HumanModel.jsx`: aplica poses al rig sin reconstruir geometrías. Los portales
  de R3F enlazan hotspots con cabeza, torso y muslo para que sigan las poses.
- `HumanCanvas.jsx`: cámara perspectiva, luces, sombras, OrbitControls de 360°,
  DPR limitado, pausa por visibilidad y alternativa si falla WebGL.
- `Hotspot.jsx`, `TelemetryCard.jsx`: resplandor, estados semánticos, interacción
  compartida y pulso crítico por `useFrame`.
- `PoseControls.jsx`: selección por desplegable o raycasting; sliders de tres
  ejes, límites de flexión, poses anatómica/inspección/saludo/paso y wireframe.

El modelo tiene cabeza, mandíbula, nariz, orejas, cuello, tórax, abdomen, pelvis,
hombros, brazos, codos, antebrazos, muñecas, palmas con cinco dedos, muslos,
rodillas, pantorrillas, tobillos, talones y pies. Es un maniquí de volúmenes
superpuestos, no una malla orgánica continua ni una simulación biomecánica.
La pose Paso es una pose estática; no se implementa un ciclo de marcha.

Arrastrar orbita; la rueda ajusta zoom; Cámara restaura la perspectiva inicial.
Pausar detiene órbita y pulso 3D. Se respeta movimiento reducido. Los datos
óseos, inmunológicos y psicológicos permanecen marcados como simulados.
Tailwind añade utilidades sin Preflight para mantener el diseño Orbital.
Three.js se descarga al mostrar el gemelo, no en login/dashboard.

```powershell
npm.cmd run build
npm.cmd run lint
node --test src/components/digital-twin/humanRig.test.js src/mocks/api.test.js
```

Las pruebas verifican proporción, simetría, encadenamiento de articulaciones,
continuidad de segmentos en todas las poses, movimiento independiente,
seguimiento de hotspots y límites articulares. Son pruebas matemáticas sin GPU;
la apariencia y la interacción WebGL requieren revisión en un navegador.
