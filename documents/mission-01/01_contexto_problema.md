# Contexto del Problema Predictivo

## 1. Problema que queremos resolver

Durante actividades extravehiculares (EVA) en misiones espaciales, los astronautas están expuestos a riesgos médicos que pueden desarrollarse progresivamente (hipoxia, estrés térmico, eventos cardiovasculares, fatiga muscular severa, exposición a radiación). La telemetría actual del traje proporciona datos en tiempo real, pero **no anticipa** la aparición de eventos médicos con suficiente tiempo para actuar.

El problema central: **transformar flujos continuos de datos fisiológicos y ambientales en alertas accionables con anticipación clínicamente útil (≥ 15-30 minutos)**, minimizando falsas alarmas que erosionan la confianza del sistema.

## 2. Propósito del sistema

Desarrollar un **sistema experimental de inteligencia predictiva** que:

- Ingiera telemetría multimodal del traje (EEG, EMG, sensor corporal, oxímetro, radiación)
- Detecte desviaciones sutiles respecto a la línea base **individual** de cada astronauta
- Prediga la probabilidad de un evento médico en los próximos **30 minutos** (horizonte MVP)
- Genere alertas graduadas (vigilancia / alerta / crítico) con explicación fisiológica, hipótesis de causa y acciones recomendadas
- Sirva como soporte a la decisión para la tripulación y el médico de vuelo (no reemplazo)

## 3. Usuarios finales

| Usuario | Rol | Necesidad |
|---------|-----|-----------|
| **Astronauta (EVA)** | Ejecutor de la misión | Alertas claras, accionables, sin jerga diagnóstica; confirmación verbal antes de escalar |
| **Médico de vuelo (Flight Surgeon)** | Autoridad médica remota | Resumen ejecutivo: nivel, señales desviadas (en σ), causa probable, acción ya tomada, ventana de actuación |
| **Control de misión** | Supervisión operativa | Visibilidad de estado de alerta por astronauta, tendencias de riesgo, falsas alarmas |
| **Investigador / Analista** | Mejora del sistema | Acceso a datos etiquetados, métricas por evento, importance features, casos edge |

## 4. Valor agregado de la predicción

| Nivel | Sin predicción | Con predicción (MVP) |
|-------|----------------|----------------------|
| **Detección** | Evento ya ocurrido → reacción tardía | Evento anticipado 15-30 min → acción preventiva |
| **Información** | Valor instantáneo vs umbral fijo | Desviación vs línea base individual + trayectoria temporal |
| **Decisión** | "Algo está mal" | "Patrón compatible con hipoxia: SpO2 -2.3σ, RR +1.8σ, θ/β +2.1σ → verificar traje, reducir esfuerzo, preparar retorno" |
| **Confianza** | Alarmas de umbral fijo = muchas falsas | Umbrales calibrados por tasa de falsas alarmas objetivo (≤1/sesión en nivel alerta) |

**Clave**: El valor no está en el "riesgo 62%", sino en la **cadena completa**: detectar → clasificar → explicar → hipótesis → acción → escalar → aprender.

## 5. Limitaciones del sistema (MVP)

| Limitación | Impacto | Mitigación |
|------------|---------|------------|
| **Datos simulados** | Prevalencia artificial (~35% sesiones con evento vs <5% real), patrones sintéticos | Declarar explícitamente; no extrapolar métricas a operación real |
| **Evento general (binario)** | No distingue tipo de evento en M1 | Misión 2: clasificación multiclase |
| **Sin personalización longitudinal** | Línea base fija (primeros 30 min) | Misión 3: baseline adaptativo, modelos por individuo |
| **Sin robustez a fallos de sensor** | Artefacto = posible falsa alarma | Misión 4: detección sensor roto vs emergencia real |
| **Tamaño de muestra pequeño** | ~44 eventos totales, ~10 en test | Reportar n/N, intervalos amplios, no solo % |
| **Horizonte fijo 30 min** | No optimizado por tipo de evento | Evaluar horizontes variables en M2 |
| **No sustituye criterio médico** | Descargo obligatorio en cada alerta | Lenguaje operativo, no diagnóstico; "verificar sensor primero" |

## 6. Diferencia: Monitoreo vs Detección vs Predicción

| Concepto | Definición | Ejemplo en este sistema | Horizonte |
|----------|------------|-------------------------|-----------|
| **Monitoreo** | Observación continua de variables fisiológicas en tiempo real | Dashboard muestra FC=112, SpO2=96%, Temp=37.2°C actualizados cada minuto | Tiempo real (t=0) |
| **Detección de anomalías** | Identificación de valores fuera de rango o patrones inusuales **en el momento actual** | "SpO2 cayó a 88% hace 2 min" → umbral fijo 90% disparado | t=0 (reactivo) |
| **Predicción de eventos médicos** | Estimación de la **probabilidad futura** de un evento clínico basado en desviaciones progresivas previas al onset | "En los últimos 20 min: SpO2 -1.5σ, RR +1.2σ, θ/β +1.8σ → riesgo 68% de hipoxia en próximos 30 min" | t + H (proactivo, H=30 min MVP) |

**Distinción crítica para el modelado**:
- **Detección**: usa información hasta t para etiquetar t (y(t) = 1 si evento activo en t)
- **Predicción**: usa información hasta t para etiquetar t+H (y(t) = 1 si onset ∈ (t, t+H])
- **Fuga temporal**: usar datos de (t, t+H] para predecir t+H invalida la predicción → **excluir filas `in_event` del entrenamiento**

---

*Documento generado como parte de MISIÓN 01 — Definición del Problema Predictivo*