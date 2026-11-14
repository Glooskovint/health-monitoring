# Criterios de Evaluación del Modelo Predictivo

## 1. Principios Rectores

| Principio | Implementación |
|-----------|----------------|
| **Evaluación operativa > métricas académicas** | Recall de evento, anticipación, falsas alarmas/sesión son primarias; ROC-AUC/PR-AUC son secundarias |
| **Nivel de evento, no de minuto** | Un evento = "detectado" si hubo ≥1 alerta útil en ventana [onset-60min, onset) |
| **Comparación obligatoria vs baseline simple** | Si el modelo no supera regla de umbrales fijos, no justifica su complejidad |
| **Umbrales elegidos en validación, test intocado** | Test se mira UNA sola vez al final |
| **Honestidad con tamaño de muestra** | Reportar `n/N` (ej. 10/11) no solo %; avisar intervalos amplios |
| **Datos simulados = resultados de prototipo** | Declarar en cada reporte; no extrapolar a operación real |

## 2. Métricas Primarias (Nivel de Evento — Lo que Importa en Operación)

### 2.1 Definiciones Operativas

| Concepto | Definición Formal |
|----------|-------------------|
| **Evento detectado (hit)** | ∃ alerta disparada en `[onset_min - USEFUL_WINDOW, onset_min)` donde `USEFUL_WINDOW = 60 min` |
| **Anticipación** | `onset_min - primer_minuto_alerta_útil` (minutos) |
| **Falsa alarma** | Alerta disparada en sesión SIN evento, O en `[onset_min, end_min+20)` (dentro de evento = detección tardía, no predicción), O >60 min antes del onset |
| **Alerta dispara** | `MIN_CONSEC = 3` minutos consecutivos con `risk ≥ umbral` |
| **Rearme** | `REARM = 10` minutos con `risk < umbral` para permitir nueva alerta |

### 2.2 Métricas por Nivel de Alerta

| Nivel | Umbral de riesgo | Falsas alarmas objetivo/sesión (8h) | Uso operativo |
|-------|------------------|--------------------------------------|---------------|
| 🟢 **Verde** | `< vigilancia` | N/A | Monitoreo normal |
| 🟡 **Vigilancia** | `≥ vigilancia` | **≤ 2** | Confirmar sensores, avisar control, sin cambiar tarea |
| 🟠 **Alerta** | `≥ alerta` | **≤ 1** | Reducir carga, notificar médico vuelo, preparar retorno |
| 🔴 **Crítico** | `≥ crítico` | **≤ 0.25** | Suspender tarea, retorno a esclusa, activar protocolo médico |

### 2.3 Tabla de Resultados Requerida (Por Nivel, En Test)

| Métrica | Vigilancia | Alerta | Crítico |
|---------|------------|--------|---------|
| **Eventos totales en test (N)** | N | N | N |
| **Eventos detectados (n)** | n | n | n |
| **Recall de evento (n/N)** | n/N | n/N | n/N |
| **Anticipación mediana (min)** | med | med | med |
| **Falsas alarmas / sesión (8h)** | fa/ses | fa/ses | fa/ses |
| **Recall por tipo de evento** | `tipo: n/N` | `tipo: n/N` | `tipo: n/N` |

**Formato de reporte obligatorio**: `n/N` + mediana + fa/sesión. Ejemplo: *"Alerta: 10/11 eventos detectados, anticipación mediana 18 min, 0.8 falsas alarmas/sesión"*

### 2.4 Criterios de Aceptación Mínimos (MVP)

| Criterio | Umbral Mínimo | Justificación |
|----------|---------------|---------------|
| **Recall de evento (nivel Alerta)** | > Baseline fijo | Debe superar regla simple |
| **Anticipación mediana (nivel Alerta)** | **≥ 15 min** | Tiempo mínimo para actuar (retorno a esclusa ~15-20 min) |
| **Falsas alarmas (nivel Alerta)** | **≤ 1 por sesión de 8h** | >1 erosiona confianza; tripulación ignora alertas |
| **Sin fuga temporal** | Verificado | Split por astronauta, exclusión `in_event`, features causales |
| **Calibración** | Brier score / reliability plot | "Riesgo 40%" debe significar ~40% frecuencia empírica |

## 3. Métricas Secundarias (Nivel de Minuto — Comparación de Modelos)

| Métrica | Fórmula | Uso |
|---------|---------|-----|
| **ROC-AUC** | `sklearn.metrics.roc_auc_score(y_true, y_score)` | Separación general; engañosa con desbalance extremo |
| **PR-AUC (Average Precision)** | `sklearn.metrics.average_precision_score(y_true, y_score)` | **Más honesta con eventos raros**; comparar con prevalencia (línea de azar) |
| **Precision @ Recall fijo** | Precision cuando recall=0.8, 0.9 | Trade-off operativo |
| **Brier Score** | `mean((y_pred - y_true)^2)` | Calibración probabilística |
| **Curva de calibración (Reliability)** | Bin predicciones vs frecuencia observada | Verificar que `risk=0.3` → ~30% eventos |

## 4. Estrategia de Separación de Datos (Crítico: Sin Fuga)

### 4.1 Split por Astronauta (Obligatorio)

```
┌─────────────────────────────────────────────────────────────────────┐
│  SPLIT POR ASTRONAUTA (NO aleatorio por filas, NO temporal mezclado)│
├─────────────────────────────────────────────────────────────────────┤
│  Entrenamiento:  60% astronautas únicos (ej. 30/50)                 │
│  Validación:     20% astronautas únicos (ej. 10/50)                 │
│  Test:           20% astronautas únicos (ej. 10/50)                 │
│                                                                       │
│  TODOS los minutos de un astronauta van al MISMO conjunto.          │
│  Evita: Minutos vecinos (autocorrelación ~0.9) en train y test →    │
│         AUC inflado, fallo catastrófico en astronauta nuevo.        │
└─────────────────────────────────────────────────────────────────────┘
```

**Implementación** (ver `train_model.py`):
```python
astronautas = sorted(df.astronaut_id.unique())
rng.shuffle(astronautas)
n = len(astronautas)
train_astros = astronautas[:int(0.6*n)]
val_astros   = astronautas[int(0.6*n):int(0.8*n)]
test_astros  = astronautas[int(0.8*n):]

train = df[df.astronaut_id.isin(train_astros)]
val   = df[df.astronaut_id.isin(val_astros)]
test  = df[df.astronaut_id.isin(test_astros)]
```

### 4.2 Exclusión de Filas `in_event` (Obligatorio)

```python
# Solo filas FUERA de evento son elegibles para entrenar/evaluar
train_use = train[train.in_event == 0]
val_use   = val[val.in_event == 0]
test_use  = test[test.in_event == 0]
```

**Por qué**: `in_event=1` = evento YA OCURRIÓ. Predecirlo es **detección**, no predicción. Incluirlas = data leakage del futuro conocido.

### 4.3 Evaluación Adicional: Astronautas "Unseen" (Generalización)

- **Test set ya son astronautas unseen** (nunca vistos en train/val)
- **Leave-One-Astronaut-Out (LOAO)**: Re-entrenar 50 veces, cada vez dejando 1 astronauta como test
- Reportar: media ± DE de recall, anticipación, fa/sesión across LOAO
- Identificar astronautas "difíciles" (outliers) para análisis de subpoblación

## 5. Baseline de Comparación (Regla de Umbrales Fijos)

**Regla simple que un ingeniero implementaría sin ML** (ver `train_model.py::rule_baseline`):

```python
def rule_baseline(df):
    return ((df["spo2_pct"] < 93) |           # Hipoxia umbral clínico
            (df["core_temp_c"] > 37.9) |      # Hipertermia
            (df["hr_bpm"] > 150) |            # Taquicardia severa
            (df["rad_dose_rate_usv_h"] > 100) | # Radiación alta
            (df["emg_mdf_hz"] < 60)).astype(float)  # Fatiga muscular severa
```

**Evaluación idéntica**: Mismas métricas nivel-evento, mismos umbrales (0.5 binario), mismo split.

**Criterio**: Modelo ML debe mejorar **al menos en uno**: recall de evento ↑, O fa/sesión ↓, O anticipación ↑. Si no, **no justifica complejidad**.

## 6. Calibración de Probabilidades (Platt Scaling)

1. Entrenar modelo en `train_use` → `predict_proba` en `val_use`
2. Ajustar regresión logística (Platt) sobre logits de validación:
   ```python
   platt = LogisticRegression(C=1e6).fit(logit(p_val).reshape(-1,1), y_val)
   risk = sigmoid(platt.coef_ * logit(p) + platt.intercept_)
   ```
3. Aplicar calibración a train/val/test
4. **Verificar**: Reliability diagram en test; Brier score

**Por qué**: "Riesgo 62%" debe ser interpretable operativamente. Sin calibración, scores de GBM no son probabilidades.

## 7. Selección de Umbrales Operativos (En Validación)

```python
# Objetivos de falsas alarmas por sesión de 8h (480 min)
FA_TARGETS = {"vigilancia": 2.0, "alerta": 1.0, "critico": 0.25}

# Búsqueda en validación: umbral más bajo que cumple objetivo (maximiza recall)
for nivel, target in FA_TARGETS.items():
    for thr in sorted_candidate_thresholds:
        fa = false_alarms_per_session(val, thr)
        if fa <= target:
            threshold[nivel] = thr
            break
```

**Regla**: Umbrales fijos **una vez elegidos en validación** → evaluar en test **sin re-optimizar**.

## 8. Análisis de Importancia de Variables (Explicabilidad)

| Método | Implementación | Uso |
|--------|----------------|-----|
| **Permutation Importance** | `sklearn.inspection.permutation_importance` en validación (scoring=average_precision, n_repeats=3) | Qué features degradan rendimiento al permutar |
| **SHAP values** (opcional M2) | `shap.TreeExplainer` | Contribución por predicción individual |
| **Feature stats para alertas** | `mean, std` de cada feature en train (para calcular z-scores en decision-support) | Explicar alertas: "HR +2.3σ, SpO2 -1.8σ" |

**Reporte**: Top 10-15 variables con importancia media ± DE; verificar sentido fisiológico.

## 9. Reporte de Evaluación Estructurado (`model_report.md`)

### Secciones Obligatorias

1. **Resumen Ejecutivo** (3-4 líneas): Qué se predice, con qué datos, qué tan bien, qué falta
2. **Datos**: Tamaño, prevalencia, problemas calidad, decisiones limpieza
3. **Modelo y Objetivo**: Definición y, horizonte, variables, split, calibración
4. **Resultados**: 
   - Tabla modelo vs baseline por nivel (recall n/N, anticipación med, fa/sesión)
   - ROC-AUC, PR-AUC (vs prevalencia)
   - Recall por tipo de evento
   - Curva PR, feature importance, timeline ejemplo
5. **Qué señales pesan más** y sentido fisiológico
6. **Limitaciones y Riesgos**: Simulación, muestra pequeña, prevalencia artificial, tipos con pocos casos
7. **Siguientes Pasos** (ver roadmap)

### Formato de Tabla de Resultados (Ejemplo)

| Nivel | Modelo: n/N (recall) | Modelo: ant. med (min) | Modelo: fa/ses | Baseline: n/N | Baseline: ant. med | Baseline: fa/ses |
|-------|---------------------|------------------------|----------------|---------------|-------------------|------------------|
| Vigilancia | 11/11 (1.000) | 28 | 1.8 | 9/11 (0.818) | 22 | 2.1 |
| **Alerta** | **10/11 (0.909)** | **18** | **0.8** | 7/11 (0.636) | 12 | 1.5 |
| Crítico | 8/11 (0.727) | 8 | 0.2 | 5/11 (0.455) | 5 | 0.3 |

**Recall por tipo (nivel Alerta)**:
- hipoxia_hipercapnia: 3/3
- estres_termico: 2/2
- estres_cardiaco: 2/2
- fatiga_lesion_muscular: 1/2  ← **FALLO: investigar**
- exposicion_radiacion: 2/2

## 10. Manejo de Casos Problemáticos (Honestidad Metodológica)

| Situación | Acción Requerida |
|-----------|------------------|
| **Recall bajo en un tipo** (ej. fatiga 1/2) | Reportar `1/2` explícitamente; NO ocultar. Analizar: ¿sensor con gaps? ¿deriva sutil? Documentar como hallazgo para M2 |
| **Falsas alarmas altas** | Subir umbral, aumentar `MIN_CONSEC`, añadir features tendencia más larga; NO cambiar objetivo fa/sesión |
| **Métrica "demasiado buena"** (AUC>0.99, recall=1.0, fa=0) | **Sospecha de fuga**: ¿alguna feature usa evento? ¿split por filas? ¿baseline calculada con todo? Auditar inmediatamente |
| **Test muy pequeño** (~10 eventos) | Reportar `n/N` + intervalo Wilson 95%; no concluir significancia estadística |
| **Baseline supera al modelo** | Modelo no justificado; reportar honestamente; simplificar o revisar features |

## 11. Checklist de Validación Pre-Entrega

- [ ] Split por astronauta verificado (no overlap de IDs entre train/val/test)
- [ ] Filas `in_event=1` excluidas de train/val/test
- [ ] Features causales: ninguna usa `t+1` o posterior (rolling sin center, min_periods)
- [ ] Baseline individual: primeros 30 min/sesión descartados
- [ ] Calibración Platt en validación, aplicada a test
- [ ] Umbrales elegidos en validación por fa/sesión objetivo
- [ ] Métricas nivel-evento (n/N, anticipación, fa/sesión) en test
- [ ] Baseline fijo evaluado idénticamente
- [ ] Recall por tipo reportado `n/N`
- [ ] Limitaciones declaradas (simulación, N pequeño, prevalencia artificial)
- [ ] No métricas de éxito arbitrarias sin justificación operativa

---

*Documento generado como parte de MISIÓN 01 — Definición del Problema Predictivo*