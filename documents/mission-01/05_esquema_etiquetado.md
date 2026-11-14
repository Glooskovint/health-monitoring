# Esquema de Etiquetado

## 1. Conjunto de Etiquetas Propuesto

| Código | Etiqueta | Descripción | Tipo |
|--------|----------|-------------|------|
| 0 | `NO_EVENT` | Sin evento médico en el horizonte predictivo | Negativo |
| 1 | `CARDIOVASCULAR` | Evento cardiovascular (arritmia, isquemia, IC aguda, shock) | Positivo - Multiclase |
| 2 | `RESPIRATORY` | Evento respiratorio (hipoxia/hipercapnia, edema pulmonar, broncoespasmo, neumotórax) | Positivo - Multiclase |
| 3 | `NEUROLOGICAL` | Evento neurológico (síncope, ICTUS, convulsión, deterioro cognitivo) | Positivo - Multiclase |
| 4 | `SYSTEMIC` | Evento sistémico (estrés térmico, hipotermia, sepsis, síndrome descompresión) | Positivo - Multiclase |
| 5 | `PHYSICAL` | Evento físico/trauma/ambiental (fatiga muscular, lesión presión, radiación aguda, fallo traje) | Positivo - Multiclase |

**Total**: 6 etiquetas (1 negativa + 5 positivas por categoría)

## 2. Decisión: Multiclase vs Multietiqueta

### Análisis

| Criterio | Multiclase (una etiqueta por muestra) | Multietiqueta (múltiples etiquetas por muestra) |
|----------|----------------------------------------|-------------------------------------------------|
| **Realidad clínica** | Un onset tiene una causa principal | Posible comorbilidad (ej. hipoxia → arritmia) |
| **Datos simulados (M1)** | Un evento por sesión, tipo único inyectado | No aplica (generador inyecta 1 tipo por sesión) |
| **Complejidad modelo** | 1 cabeza salida (6 logits) | 5 cabezas binarias o 1 cabeza 31 combinaciones |
| **Tamaño muestra** | ~44 eventos totales → ~7-9 por clase | Muy escaso para combinaciones raras |
| **Evaluación operativa** | Recall por tipo = n/N por clase | Recall por etiqueta + subset accuracy |
| **Roadmap skills** | M1: Binario general; M2: Multiclase 5 tipos | No contemplado |

### Decisión para MVP (Misión 1)

**MODELO BINARIO GENERAL** (`y ∈ {0, 1}`):
- Target: `y(t) = 1` si **cualquier** evento médico tiene onset en `(t, t+H]`
- `event_type` se registra como **metadata** (columna auxiliar) para:
  - Análisis de recall por tipo post-entrenamiento
  - Generación de hipótesis en decision-support
  - Base para Misión 2 (multiclase)

**Misión 2**: Modelo multiclase `y ∈ {0,1,2,3,4,5}` (NO_EVENT + 5 tipos)
- Requiere más eventos por tipo (simular más sesiones o sobremuestrear)
- Evaluación: recall por clase, matriz confusión 6×6

**Multietiqueta**: No recomendado hasta tener evidencia de comorbilidad simultánea en datos reales y muestra suficiente.

## 3. Regla de Construcción de Etiquetas (Desde `events.csv`)

### 3.1 Definición formal

Para cada observación `(astronaut_id, session_id, minute=t)`:

```
Sea E(s) = { eventos e : e.session_id = s }
Sea H = horizonte predictivo (30 min MVP)

y(t) = 1  si ∃ e ∈ E(s) : e.onset_min ∈ (t, t+H]
     = 0  en caso contrario

event_type(t) = e.event_type  si y(t)=1 y ∃ único e con onset en (t, t+H]
              = "multiple"     si y(t)=1 y ∃ múltiples e (raro en simulación)
              = ""             si y(t)=0

in_event(t) = 1  si ∃ e ∈ E(s) : t ∈ [e.onset_min, e.end_min + 20]
            = 0  en caso contrario
```

### 3.2 Algoritmo de etiquetado (pseudocódigo)

```python
# Inputs: df_telemetry (con minute), df_events (onset_min, end_min, event_type)
# Output: df con columnas y, in_event, event_type

df["y"] = 0
df["in_event"] = 0
df["event_type"] = ""

for evento in df_events.itertuples():
    mask_session = df["session_id"] == evento.session_id
    mask_y = mask_session & (df["minute"] >= evento.onset_min - H) & (df["minute"] < evento.onset_min)
    mask_in = mask_session & (df["minute"] >= evento.onset_min) & (df["minute"] < evento.end_min + 20)
    
    df.loc[mask_y, "y"] = 1
    df.loc[mask_y, "event_type"] = evento.event_type  # Sobrescribe si múltiples (orden arbitrario)
    df.loc[mask_in, "in_event"] = 1
```

### 3.3 Ejemplo visual

```
Tiempo ──────────────────────────────────────────────────────────────────▶
        │         │                    │                    │
        t-60      t-30 (H=30)         onset_min            end_min+20
        │         │                    │                    │
        │◄───────┤                    │                    │
        │  y=1   │                    │   in_event=1       │
        │        │                    │                    │
        │◄────────────────────────────┤                    │
        │     y=1 (cualquier t       │                    │
        │     con onset en (t,t+30]) │                    │
```

- **Ventana y=1**: 30 min antes del onset (preparatoria)
- **Zona in_event=1**: Desde onset hasta 20 min post-evento (excluida de entrenamiento)
- **Gap de 20 min post-evento**: Período de recuperación; fisiología aún alterada

## 4. Distinción de Tipos de Evento (Metadatos de Calidad)

| Categoría | Definición | Uso en modelado |
|-----------|------------|-----------------|
| **Evento confirmado** | Registrado en `events.csv` con onset verificado (simulación: ground truth inyectado) | Entrenamiento y evaluación principal |
| **Evento simulado** | Generado por el simulador con parámetros conocidos (tipo, severidad, precursor_len, duration) | Análisis de recall por tipo, debugging, curación de datos |
| **Evento no observado** | Ausencia de registro en `events.csv` para esa sesión | **NO equivale a "no ocurrió"** → `y=0` pero con incertidumbre |
| **Información desconocida/insuficiente** | Sesión con gaps >50% datos, sensores críticos fallados, duración <30 min | Marcar como `data_quality=insufficient`; excluir de train/val/test o peso reducido |

### Regla crítica: **Ausencia de registro ≠ Evidencia de ausencia**

```python
# INCORRECTO (asume completitud del registro):
y = 0  # porque no hay evento en events.csv

# CORRECTO (reconoce limitación):
y = 0  # basado en registro disponible
data_quality_flag = "complete" if sesión_completa else "partial"
# En evaluación: reportar "eventos no observados posibles" como limitación
```

En simulación: el generador **inyecta** eventos con probabilidad `event_prob=0.35`. Sesiones sin evento inyectado son verdaderos negativos (por diseño del simulador). En datos reales: **nunca se asume completitud**.

## 5. Manejo de Casos Edge

| Caso | Regla |
|------|-------|
| **Múltiples eventos en una sesión** (raro en sim, posible en real) | `y=1` si **cualquier** onset ∈ (t, t+H]; `event_type` = primer onset en ventana; flag `multiple_events=1` |
| **Evento con precursor muy largo** (>H) | `y=1` solo en últimos H min antes de onset; precursores más antiguos → `y=0` (fuera de horizonte) |
| **Evento que empieza antes de t=0** (onset < 30 min baseline) | Sesión descartada o `in_event=1` desde minuto 0; no usable para predicción |
| **Sesión sin baseline completo** (<30 min antes de primer onset) | Descartar sesión; insuficiente para calcular features delta |
| **Evento tipo "desconocido" no en catálogo** | `event_type="other"`; `y=1`; analizar post-hoc para ampliar catálogo |

## 6. Esquema de Columnas de Etiquetado en Dataset Final

| Columna | Tipo | Valores | Descripción |
|---------|------|---------|-------------|
| `y` | int | 0, 1 | Target binario principal (M1) |
| `in_event` | int | 0, 1 | Flag exclusión entrenamiento (1 = dentro de evento + buffer) |
| `event_type` | string | "", "hipoxia_hipercapnia", "estres_termico", "estres_cardiaco", "fatiga_lesion_muscular", "exposicion_radiacion", "multiple", "other" | Tipo de evento si y=1; metadata para M2 y análisis |
| `onset_min` | int | -1 o minuto | Minuto de onset del evento que causó y=1 (para cálculo anticipación) |
| `event_severity` | float | 0.0-1.0 o NaN | Severidad inyectada (solo simulación) |
| `data_quality` | string | "complete", "partial", "insufficient" | Calidad de la sesión para pesos/evaluación |

## 7. Validación del Esquema (Checks Automáticos)

```python
def validate_labels(df, events, H=30):
    checks = []
    
    # 1. Consistencia y=1 ↔ onset en (t, t+H]
    for _, ev in events.iterrows():
        mask = (df.session_id == ev.session_id) & (df.minute >= ev.onset_min - H) & (df.minute < ev.onset_min)
        assert df.loc[mask, "y"].all() == 1, "Faltan y=1 en ventana predictiva"
    
    # 2. in_event=1 → y=0 (mutuamente excluyentes en ventana)
    # Nota: in_event empieza en onset; y=1 termina en onset-1 → no overlap
    overlap = df[(df.y == 1) & (df.in_event == 1)]
    assert len(overlap) == 0, "Overlap y=1 e in_event=1"
    
    # 3. Sesiones sin evento → y=0 siempre
    sess_with_events = set(events.session_id)
    sess_no_event = df[~df.session_id.isin(sess_with_events)].session_id.unique()
    for s in sess_no_event:
        assert df[df.session_id == s].y.sum() == 0, f"y=1 en sesión sin evento {s}"
    
    # 4. event_type no vacío solo si y=1
    assert df[(df.y == 0) & (df.event_type != "")].empty, "event_type sin y=1"
    
    # 5. Baseline: primeros 30 min no tienen features delta (se descartan)
    # Verificado en build_features: df = df[df.minute >= 30]
    
    return checks
```

---

*Documento generado como parte de MISIÓN 01 — Definición del Problema Predictivo*