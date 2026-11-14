# Diseño del Dataset Sintético

## 1. Parámetros Generales de Generación

| Parámetro | Valor | Justificación |
|-----------|-------|---------------|
| **Número de astronautas** | 50 (AST001–AST050) | Suficiente para split 60/20/20 (30/10/10) con variabilidad inter-individuo |
| **Sesiones por astronauta** | 3 EVA (S1, S2, S3) | Repetibilidad intra-sujeto; 150 sesiones totales |
| **Duración por sesión** | 480 minutos (8 horas) | EVA estándar; 72,000 min/astronauta; 3.6M filas totales @ 1 min |
| **Frecuencia de muestreo** | 1 minuto | Requerido para dinámica rápida (ver especificación temporal) |
| **Probabilidad de evento por sesión** | 0.35 (35%) | **Alta a propósito** → ~52 eventos totales para poder estadístico; prevalencia real ~5% |
| **Horizonte predictivo** | 30 minutos | MVP alineado con skills |
| **Semilla aleatoria** | 42 (reproducible) | Fijada para reproducibilidad; cambiar para nuevos experimentos |

**Total estimado**: 50 × 3 × 480 = **72,000 filas de telemetría** + **~52 eventos** inyectados

## 2. Arquitectura del Generador (Basado en `simulate_telemetry.py`)

### 2.1 Perfil Fisiológico Individual (Baseline por Astronauta)

Cada astronauta `i` recibe parámetros fijos muestreados una vez:

```python
def make_astronaut(rng):
    return {
        "hr_rest": rng.uniform(55, 75),        # FC reposo
        "hr_gain": rng.uniform(0.8, 1.2),      # Sensibilidad FC a carga
        "spo2": rng.uniform(96.5, 98.8),       # SpO2 basal
        "resp": rng.uniform(12, 16),           # RR basal
        "core": rng.uniform(36.6, 37.1),       # Temp central basal
        "skin": rng.uniform(33.0, 34.8),       # Temp piel basal
        "tb": rng.uniform(1.2, 2.0),           # θ/β basal
        "alpha": rng.uniform(9, 12),           # α power basal
        "emg_rms": rng.uniform(35, 55),        # EMG RMS basal
        "emg_mdf": rng.uniform(80, 100),       # EMG MDF basal
        "rad": rng.uniform(14, 24),            # Radiación fondo µSv/h
    }
```

**Variabilidad inter-individuo**: Cada astronauta tiene su "normal" distinto → **features delta respecto a baseline individual son esenciales**.

### 2.2 Perfil de Carga de Trabajo (Latente, Común a Todos)

```python
def workload_profile(n_minutes, rng):
    w = np.zeros(n)
    # Tramos de actividad sostenida (20-60 min)
    i = 0
    while i < n:
        length = rng.integers(20, 60)
        w[i:i+length] = rng.choice([0.15, 0.4, 0.6, 0.8], p=[0.2, 0.3, 0.3, 0.2])
        i += length
    # Ráfagas de esfuerzo intenso BENIGNO (negativos difíciles) - 2-4 por EVA
    for _ in range(rng.integers(2, 5)):
        s = rng.integers(30, n-15)
        w[s:s+rng.integers(5, 12)] = 0.97
    # Suavizado + ruido AR(1)
    w = convolve(w, ones(6)/6, mode='same')
    w = clip(w + ar1(n, 0.9, 0.02, rng), 0, 1)
    return w
```

**Clave**: Carga de trabajo mueve TODAS las señales de forma **benigna** (FC↑, RR↑, temp↑, EMG↑, θ/β↑, α↓). El modelo debe distinguir esto de patología.

### 2.3 Fatiga Acumulada (Latente)

```python
fatigue = clip(cumsum(w) / (0.5 * n), 0, 1.2)
```
- Afecta: EMG MDF↓, EEG α↓, θ/β↑, temp core↑ leve
- Progresiva durante la EVA; no se reinicia entre tramos

### 2.4 Señales Fisiológicas (Modelo Generativo por Señal)

Para cada minuto `t`, cada señal = `baseline + f(carga, fatiga) + ruido AR(1) + ruido medición`:

| Señal | Ecuación Base (sin evento) | Ruido AR(1) | Ruido Medición |
|-------|----------------------------|-------------|----------------|
| `hr_bpm` | `hr_rest + 55 * w * hr_gain` | ρ=0.85, σ=1.5 | N(0, 1.0) |
| `spo2_pct` | `spo2 - 0.8 * w` | ρ=0.8, σ=0.15 | N(0, 0.2) |
| `resp_rate_bpm` | `resp + 9 * w` | ρ=0.8, σ=0.4 | N(0, 0.4) |
| `core_temp_c` | `core + 0.5 * EWM(w, 90)` | ρ=0.95, σ=0.02 | N(0, 0.03) |
| `skin_temp_c` | `skin + 1.0 * EWM(w, 40)` | ρ=0.95, σ=0.05 | N(0, 0.06) |
| `eeg_theta_beta` | `tb + 0.4*fatigue + 0.1*w` | ρ=0.9, σ=0.04 | N(0, 0.05) |
| `eeg_alpha_uv2` | `alpha - 1.5*w - 0.8*fatigue` | ρ=0.9, σ=0.2 | N(0, 0.3) |
| `emg_rms_uv` | `emg_rms * (1 + 1.5*w)` | ρ=0.7, σ=3 | N(0, 3) |
| `emg_mdf_hz` | `emg_mdf - 8*fatigue` | ρ=0.8, σ=1.2 | N(0, 1.5) |
| `rad_dose_rate` | `clip(rad + AR1, 0.5, ∞)` | ρ=0.95, σ=0.8 | N(0, 0.4) |

`EWM` = Exponential Weighted Moving Average (memoria térmica)

### 2.5 Inyección de Eventos Médicos

```python
if rng.random() < event_prob (0.35):
    et = rng.choice(5 tipos)           # Uniforme entre 5 tipos
    sev = rng.uniform(0.5, 1.0)        # Severidad 0.5-1.0
    onset = rng.integers(90, n-40)     # Onset entre min 90 y 440 (evita edges)
    pre_len = rng.integers(20, 46)     # Precursor 20-45 min (RAMPA GRADUAL)
    dur = rng.integers(15, 31)         # Duración 15-30 min
    recovery = 20 min                  # Buffer post-evento fijo
```

**Rampa precursora** (clave para predicción):
```
r[t] = 0                                    para t < onset - pre_len
r[t] = ((t - (onset-pre_len)) / pre_len)^1.5  para onset-pre_len ≤ t < onset  (convexo: acelera)
r[t] = 1.0                                  para onset ≤ t < onset+dur
r[t] = linear decay 1→0                     para 20 min post-evento
```

**Efecto por tipo de evento** (multiplicado por `sev * r[t]`):

| Evento | Señales afectadas (dirección) |
|--------|------------------------------|
| `hipoxia_hipercapnia` | SpO2↓7, RR↑8, θ/β↑0.9, α↓3, FC↑14 |
| `estres_termico` | Core↑1.6, Skin↑2.5, FC↑25, RR↑4 |
| `estres_cardiaco` | FC↑35 + irregularidad (ruido ×6), SpO2↓2, RR↑3 |
| `fatiga_lesion_muscular` | EMG MDF↓25, EMG RMS↑50%, FC↑8, Core↑0.3 |
| `exposicion_radiacion` | Rad rate ×(1+12), FC↑10, θ/β↑0.4 |

### 2.6 Artefactos y Pérdidas de Señal (Realismo)

| Artefacto | Frecuencia | Duración | Efecto |
|-----------|------------|----------|--------|
| **EEG baja calidad** | Poisson(n×0.02/4) ráfagas | 1-4 min | θ/β ×2-4, α ×0.3-0.6, quality 0.1-0.35 |
| **Picos EMG aislados** | 1% minutos | 1 min | RMS ×2-4 |
| **Pérdida señal por grupo** | Poisson(n×0.003) por grupo | 1-8 min | NaN en todas las señales del grupo |
| Grupos: oximetría (FC,SpO2,RR), temp (core,skin), EEG (θ/β,α,quality), EMG (RMS,MDF) | | | |

### 2.7 Dosis Acumulada de Radiación

```python
rad_cum_dose_msv = cumsum(clip(rad_dose_rate, 0, ∞) / 60) / 1000  # µSv/h → mSv/min → mSv
```
Monótona creciente durante la sesión; reinicio por sesión.

## 3. Esquema de Salidas del Generador

### 3.1 `telemetry.csv` (Lo que "llegaría" del traje — SIN etiquetas)

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `astronaut_id` | string | AST001–AST050 |
| `session_id` | string | AST001-S1, AST001-S2, AST001-S3 |
| `minute` | int | 0–479 |
| `timestamp` | datetime | UTC absoluto (base 2030-01-01 + offset) |
| `hr_bpm` | float | NaN si pérdida señal |
| `spo2_pct` | float | NaN si pérdida señal |
| `resp_rate_bpm` | float | NaN si pérdida señal |
| `core_temp_c` | float | NaN si pérdida señal |
| `skin_temp_c` | float | NaN si pérdida señal |
| `eeg_theta_beta_ratio` | float | NaN si pérdida señal o quality<0.4 |
| `eeg_alpha_uv2` | float | NaN si pérdida señal o quality<0.4 |
| `eeg_quality` | float | 0–1 |
| `emg_rms_uv` | float | NaN si pérdida señal |
| `emg_mdf_hz` | float | NaN si pérdida señal |
| `rad_dose_rate_usv_h` | float | >0.1 |
| `rad_cum_dose_msv` | float | Monótona |

### 3.2 `events.csv` (Verdad terreno — Registro médico posterior)

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `astronaut_id` | string | |
| `session_id` | string | |
| `event_type` | string | 5 tipos |
| `severity` | float | 0.5–1.0 |
| `precursor_start_min` | int | onset - pre_len |
| `onset_min` | int | Inicio clínico |
| `end_min` | int | onset + dur |

### 3.3 `data_dictionary.md` (Documentación automática)

Generado por el simulador con sensor, unidad, nota por columna.

## 4. Mecanismos de Generación de Patrones Fisiológicos

| Patrón | Implementación en Generador |
|--------|----------------------------|
| **Comportamiento habitual** | Carga de trabajo `w(t)` + fatiga acumulada + ruido AR(1) → variabilidad realista |
| **Variaciones individuales** | Parámetros `make_astronaut()` únicos por astronauta (baseline, ganancias, ruido) |
| **Cambios progresivos** | Fatiga `cumsum(w)` → deriva lenta EMG MDF↓, EEG α↓, θ/β↑, temp↑; EWM térmico |
| **Alteraciones repentinas** | Ráfagas `w=0.97` (esfuerzo intenso benigno); picos EMG; artefactos EEG |
| **Recuperación** | Post-evento: rampa lineal 20 min; fin de tramo carga → `w` decae; fatiga no recupera fully |
| **Eventos sin señales previas detectables** | **NO implementado en v1**: todos los eventos tienen precursor 20-45 min. Para M4: añadir `pre_len=0` (onset súbito) y evaluar recall=0 esperado. |

## 5. Reglas de Generación Documentadas (Para Reproducibilidad)

1. **Semilla global fija** (`--seed 42`) → resultados idénticos en cada ejecución
2. **Astronautas independientes**: `rng` se avanza secuencialmente; no hay correlación cruzada
3. **Sesiones independientes dentro de astronauta**: Nuevo `workload_profile`, nueva fatiga, nuevo ruido; solo parámetros astronauta persisten
4. **Eventos mutuamente excluyentes por sesión**: Máximo 1 evento por EVA (simplificación M1)
5. **Precursor siempre convexo** (`^1.5`): Empieza lento, acelera cerca del onset → detectable
6. **Severidad multiplica amplitud** pero no cambia forma temporal
7. **Radiación fondo**: AR(1) estable; evento = multiplicación sostenida ×5-12
8. **NaN = pérdida real de señal**: No imputado en telemetry.csv; imputación (ffill≤5) en build_features

## 6. Limitaciones Conocidas del Conjunto Sintético

| Limitación | Impacto | Mitigación / Nota |
|------------|---------|-------------------|
| **Prevalencia artificial 35%** vs real <5% | Métricas (precision, FPR) no trasladables; umbrales calibrados en val no sirven en real | Declarar explícitamente; re-calibrar umbrales con prevalencia real en M5 |
| **Un evento por sesión** | No aprende comorbilidad / eventos múltiples | M2/M4: simular múltiples eventos por sesión |
| **Precursor siempre presente (20-45 min)** | Modelo aprende que "siempre hay señal previa"; fallará en onset súbito real | M4: añadir fracción `pre_len=0` |
| **Tipos de evento balanceados** (uniforme) | Distribución real sesgada (hipoxia/thermal más frecuentes) | Ajustar `rng.choice` con pesos realistas en M2 |
| **Severidad uniforme 0.5-1.0** | No captura eventos leves/subclínicos | Añadir `sev ~ Beta(2,5)` sesgado a leve |
| **Sin deriva longitudinal** (entre EVAs) | Baseline fijo por sesión; no envejece / adapta | M3: baseline adaptativo, historial multi-sesión |
| **Sensores perfectamente sincronizados** (1 min) | Real: latencias, desalineación, frecuencias distintas | M4: simular timestamps irregulares |
| **Ruido gaussiano + AR(1)** | Real: ruido no gaussiano, outliers heavy-tailed | Validar con datos análogos terrestres (NEEMO, HERA, Antarctica) |
| **50 astronautas simulados** | Diversidad limitada vs población real | Aumentar N; variar rangos `make_astronaut` |

## 7. Especificación de Ejecución (Reproducible)

```bash
# Directorio de salida
mkdir -p mission1_output/data

# Generación (usa script del skill astro-telemetry-simulator)
python scripts/simulate_telemetry.py \
    --out mission1_output/data \
    --astronauts 50 \
    --sessions 3 \
    --minutes 480 \
    --event-prob 0.35 \
    --seed 42

# Salidas esperadas:
# mission1_output/data/telemetry.csv     (~72,000 filas)
# mission1_output/data/events.csv        (~52 filas)
# mission1_output/data/data_dictionary.md
```

**Verificación post-generación**:
```python
tele = pd.read_csv("mission1_output/data/telemetry.csv")
ev = pd.read_csv("mission1_output/data/events.csv")
assert len(tele) == 50 * 3 * 480
assert tele.session_id.nunique() == 150
assert tele.astronaut_id.nunique() == 50
assert set(ev.event_type.unique()) == {"hipoxia_hipercapnia","estres_termico","estres_cardiaco","fatiga_lesion_muscular","exposicion_radiacion"}
assert ev.severity.between(0.5, 1.0).all()
assert ev.precursor_start_min.between(45, 435).all()  # onset-pre_len ≥ 0
```

---

*Documento generado como parte de MISIÓN 01 — Definición del Problema Predictivo*