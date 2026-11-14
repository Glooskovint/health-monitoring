# Especificación Temporal del Problema Predictivo

## 1. Configuración Inicial (Parámetros de la Misión)

| Parámetro | Valor | Justificación / Nota |
|-----------|-------|----------------------|
| **Ventana histórica (lookback)** | 24 horas (96 períodos @ 15 min) | Contexto fisiológico suficiente para detectar desviaciones de baseline; cubre ciclos sueño/vigilia |
| **Horizonte predictivo (H)** | 24 horas (96 períodos @ 15 min) | **NOTA**: Los skills existentes usan **30 minutos @ 1 min**. 24h es muy largo para predicción aguda EVA; se recomienda alinear con skills: **H = 30 min, freq = 1 min** para MVP. Este doc documenta ambas opciones. |
| **Frecuencia de observación** | 15 minutos | **NOTA**: Skills usan **1 minuto**. 15 min pierde dinámica rápida (hipoxia, arritmia). Recomendación: **1 min** para MVP, agregar 15 min como feature derivada (m15). |
| **Unidad de análisis** | Astronauta × instante de evaluación (t) | Cada fila = un astronauta en un minuto t de una sesión EVA |
| **Duración sesión EVA** | 480 minutos (8 horas) | Estándar NASA EVA; 90 días = ~270 sesiones por astronauta si diarias (irrealista) |
| **Período total simulación** | 90 días | Para M1: 40 astronautas × 3 EVA = 120 sesiones. 90 días es para M5 (datos longitudinales reales) |

## 2. Estructura Temporal Recomendada para MVP (Alineada con Skills)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ESTRUCTURA TEMPORAL MVP (SKILLS)                         │
├─────────────────────────────────────────────────────────────────────────────┤
│  Frecuencia base:          1 minuto                                         │
│  Horizonte predictivo (H): 30 minutos                                       │
│  Baseline individual:      Primeros 30 min de cada sesión (descartados)     │
│  Ventanas derivadas:       m5 (5 min), m15 (15 min), sd15, slope15          │
│  Unidad de análisis:       (astronaut_id, session_id, minute)               │
│  Split temporal:           Por ASTRONAUTA (no por filas ni tiempo mezclado) │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Razones para 1 min / 30 min**:
- Hipoxia significativa: SpO2 cae 5-10% en 10-20 min → 15 min pierde la dinámica
- Arritmia: cambios en segundos-minutos
- Estrés térmico: core_temp rampa ~0.5-1°C/30min → detectable en 1 min
- Fatiga EMG: mdf ↓ progresivo en 20-40 min
- Radiación: tasa dosis ×5-12 sostenida >30 min

## 3. Construcción de Observaciones (Sin Fuga Temporal)

### 3.1 Definición formal de la observación en t

Para cada astronauta `a`, sesión `s`, minuto `t`:

```
X(a,s,t) = { todas las variables derivadas computadas SOLO con datos ≤ t }
y(a,s,t) = 1  si ∃ evento e: e.session_id = s ∧ e.onset_min ∈ (t, t+H]
         = 0  en caso contrario
in_event(a,s,t) = 1  si ∃ evento e: e.session_id = s ∧ t ∈ [e.onset_min, e.end_min + 20]
                = 0  en caso contrario
```

### 3.2 Variables derivadas — Cómputo causal (solo pasado)

Para cada señal cruda `x` (hr, spo2, resp, core, skin, tb, alpha, emg_rms, emg_mdf, rad_rate):

| Feature | Fórmula causal (solo datos ≤ t) | Parámetros |
|---------|----------------------------------|------------|
| `x_delta(t)` | `x(t) - baseline_x` | `baseline_x = median(x[0:30])` (primeros 30 min sesión) |
| `x_m5(t)` | `mean(x_delta[t-4:t])` | `min_periods=3` (requiere ≥3 puntos) |
| `x_m15(t)` | `mean(x_delta[t-14:t])` | `min_periods=8` |
| `x_sd15(t)` | `std(x[t-14:t])` | `min_periods=8`, señal cruda (no delta) |
| `x_slope15(t)` | `(x_m5(t) - x_m5(t-15)) / 15` | Diferencia finita hacia atrás |

**Regla estricta**: Ninguna feature en `t` usa `x(t+1)` o posterior. `rolling()` de pandas con `min_periods` y sin `center=True` garantiza causalidad.

### 3.3 Baseline individual

- Calculada **por sesión** (no global, no por astronauta agregado)
- Primeros 30 minutos de cada EVA = período de "estabilización / baseline"
- Esos 30 min se **descartan del dataset de modelado** (no hay baseline previa en tiempo real)
- Baseline = mediana robusta (resistente a outliers iniciales)

### 3.4 Exclusión de filas `in_event`

```
Filas de ENTRENAMIENTO/VALIDACIÓN/TEST = { (a,s,t) : in_event(a,s,t) = 0 }
```

**Por qué**: Si `in_event=1`, el evento YA OCURRIÓ. Predecirlo sería **detección**, no predicción. Incluirlas infla métricas artificialmente (data leakage del futuro conocido).

## 4. Problemas Temporales y Soluciones

| Problema | Descripción | Solución en MVP |
|----------|-------------|-----------------|
| **Mediciones faltantes (NaN)** | Pérdidas de señal por grupos (1-8 min): oximetría, temp, EEG, EMG | Forward fill ≤5 min (`ffill(limit=5)`); huecos >5 min → NaN propagado a features derivadas; modelo (HistGradientBoosting) maneja NaN nativamente |
| **Desfases temporales** | Sensores con latencias distintas (SpO2 ~30 seg retraso vs FC) | Frecuencia 1 min absorbe desfases <1 min; no alineación sub-minuto en MVP |
| **Datos irregulares** | Timestamp no exactamente cada 60 seg | `minute` = entero secuencial 0,1,2...; `timestamp` para referencia absoluta; asumir muestreo regular 1 min |
| **Artefactos EEG** | Ráfagas 1-4 min con quality <0.4 | Enmascarar: `x[t] = NaN` para EEG si `eeg_quality[t] < 0.4`; luego ffill ≤5 min |
| **Picos EMG aislados** | Artefactos movimiento 1-2 min, amplitud ×2-4 | Suavizado por ventanas móviles (m5, m15); no eliminar filas |
| **Deriva basal lenta** | Baseline cambia durante EVA (8h) | Features `delta` respecto a baseline fijo (primeros 30 min); `m15`/`slope15` capturan deriva; M3: baseline adaptativo |
| **Fin de sesión** | Últimos minutos sin ventana completa m15 | `min_periods` permite cálculo con menos datos; no padding artificial |

## 5. Esquema de Particionado Temporal (Split por Astronauta)

```
┌────────────────────────────────────────────────────────────────────┐
│                    SPLIT POR ASTRONAUTA (NO ALEATORIO)             │
├────────────────────────────────────────────────────────────────────┤
│  Entrenamiento:  60% astronautas únicos (ej. 24/40)                │
│  Validación:     20% astronautas únicos (ej. 8/40)                 │
│  Test:           20% astronautas únicos (ej. 8/40)                 │
│                                                                        │
│  CLAVE: Todos los minutos de un astronauta van al MISMO conjunto.  │
│  Evita: Minutos vecinos (casi idénticos) en train y test → AUC     │
│         inflado, fallo en astronauta nuevo.                        │
└────────────────────────────────────────────────────────────────────┘
```

**Implementación** (ver `train_model.py`):
```python
astronautas = sorted(df.astronaut_id.unique())
rng.shuffle(astronautas)
n = len(astronautas)
train_astros = astronautas[:int(0.6*n)]
val_astros   = astronautas[int(0.6*n):int(0.8*n)]
test_astros  = astronautas[int(0.8*n):]
```

## 6. Evaluación en Astronautas "Unseen" (Generalización)

- **Test set** = astronautas NUNCA vistos en train/val
- Métricas reportadas **solo en test** (una sola mirada)
- Umbrales de alerta (vigilancia/alerta/crítico) elegidos **en validación** por tasa de falsas alarmas objetivo
- **Evaluación adicional**: "Leave-one-astronaut-out" (LOAO) para estimar variabilidad inter-individuo

## 7. Resumen de Decisiones Clave

| Decisión | Valor MVP | Alternativa documentada (Misión params) |
|----------|-----------|------------------------------------------|
| Frecuencia | **1 min** | 15 min (parámetro misión) |
| Horizonte | **30 min** | 24 h (parámetro misión) |
| Baseline | Primeros 30 min/sesión | 24 h ventana histórica |
| Features | Delta + m5/m15/sd15/slope15 por señal | Solo valores crudos + rolling means |
| Split | Por astronauta (60/20/20) | Temporal (primeros 60 días train...) |
| Target | Binario: evento en (t, t+30] | Multiclase 6 etiquetas |

**Recomendación**: Usar configuración **Skills (1 min / 30 min)** para MVP. Los parámetros de la misión (15 min / 24 h) son para fases posteriores con datos reales y objetivos operativos distintos.

---

*Documento generado como parte de MISIÓN 01 — Definición del Problema Predictivo*