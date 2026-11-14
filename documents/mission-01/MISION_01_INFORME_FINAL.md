# MISIÓN 01 — INFORME FINAL
## Definición del Problema Predictivo para Monitoreo de Salud de Astronautas

---

## 1. Resumen Ejecutivo

Esta misión establece las **bases conceptuales, estadísticas y técnicas** para construir un modelo predictivo de eventos médicos durante actividades extravehiculares (EVA). Se define un problema de **predicción binaria a 30 minutos** (evento médico general: sí/no) usando telemetría multimodal del traje (10 sensores, 1 min), con evaluación operativa centrada en **recall de evento, anticipación mediana y falsas alarmas por sesión**. El diseño evita rigurosamente la fuga temporal mediante split por astronauta, exclusión de filas `in_event`, y features causales. El dataset sintético (50 astronautas × 3 EVA × 480 min) se generará con patrones fisiológicos realistas, precursores graduales, y artefactos reales. Los criterios de aceptación exigen superar una regla de umbrales fijos con ≥15 min anticipación y ≤1 falsa alarma/sesión en nivel "alerta".

---

## 2. Problema Definido

| Aspecto | Definición |
|---------|------------|
| **Problema central** | Anticipar eventos médicos agudos durante EVA con ≥15-30 min de antelación usando solo telemetría del traje |
| **Tipo de predicción** | Binaria: `y(t)=1` si onset de cualquier evento médico ∈ `(t, t+30min]` |
| **Horizonte (H)** | 30 minutos (MVP); 24h documentado como alternativa para fases posteriores |
| **Frecuencia** | 1 minuto (MVP); 15 min documentado como alternativa |
| **Unidad de análisis** | (astronauta, sesión, minuto) |
| **Valor agregado** | No solo "riesgo 62%": cadena detectar → clasificar → explicar (desviaciones en σ) → hipótesis fisiológica → acción recomendada → escalar a médico vuelo → aprender |

**Diferencia clave**: **Predicción** (usa `t` para predecir `t+H`) ≠ **Detección** (usa `t` para etiquetar `t`). Filas dentro de evento (`in_event=1`) se excluyen del entrenamiento.

---

## 3. Alcance del MVP (Misión 1)

| Dentro del Alcance | Fuera del Alcance (Misiones Futuras) |
|--------------------|--------------------------------------|
| Modelo binario: evento general sí/no | Clasificación multiclase por tipo (M2) |
| Datos simulados (prevalencia 35%) | Datos reales / semirreales (M5) |
| Baseline fija (primeros 30 min/sesión) | Baseline adaptativa longitudinal (M3) |
| Sensores perfectos (con artefactos simulados) | Robustez a fallos de sensor (M4) |
| 5 tipos de evento inyectados (metadata) | Comorbilidad / eventos múltiples simultáneos |
| Evaluación por evento (recall, anticipación, FA) | Tablero centro de control, retroalimentación desenlaces (M6) |
| Horizonte fijo 30 min | Horizontes variables por tipo |

---

## 4. Decisiones Metodológicas Clave

| Decisión | Opción Elegida | Justificación |
|----------|----------------|---------------|
| **Split de datos** | Por astronauta (60/20/20) | Evita autocorrelación minutos vecinos; generaliza a astronauta nuevo |
| **Target** | Binario general + `event_type` metadata | M1 aprende "algo va mal"; M2 aprende "qué va mal" |
| **Baseline** | Individual por sesión (mediana min 0-29) | Fisiología varía enormemente entre personas; población no sirve |
| **Features** | Delta + m5/m15/sd15/slope15 por señal | Captura nivel, tendencia, variabilidad, aceleración; causal |
| **Calibración** | Platt scaling en validación | "Riesgo 40%" debe ser interpretable operativamente |
| **Umbrales** | Por tasa FA objetivo en validación (vigilancia≤2, alerta≤1, crítico≤0.25 FA/ses) | Operativamente significativos; evitan "alert fatigue" |
| **Evaluación primaria** | Nivel-evento: recall n/N, anticipación med, FA/sesión | AUC no captura utilidad operativa |
| **Baseline comparación** | Regla umbrales fijos (SpO2<93, Core>37.9, HR>150, Rad>100, EMG_MDF<60) | Si ML no supera regla simple, no justifica complejidad |

---

## 5. Supuestos Explícitos

1. **Datos simulados**: Prevalencia 35% vs real <5%; métricas no trasladables directamente
2. **Un evento por sesión**: Simplificación; real puede tener múltiples/comorbilidad
3. **Precursor siempre presente** (20-45 min convexo): Modelo aprende que "hay señal previa"; onset súbito real no detectado
4. **Tipos balanceados uniformemente**: Distribución real sesgada
5. **Sensores sincronizados 1 min**: Real tiene latencias, frecuencias distintas
6. **Ruido gaussiano + AR(1)**: Real tiene colas pesadas, outliers no gaussianos
7. **50 astronautas simulados**: Diversidad limitada vs población real
8. **Sin deriva longitudinal entre EVAs**: Baseline reinicia cada sesión
9. **Registro de eventos completo** (en simulación): En real, ausencia de registro ≠ ausencia de evento
10. **Modelo binario suficiente para M1**: Valor está en alerta accionable, no en diagnóstico

---

## 6. Riesgos y Limitaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| **Fuga temporal no detectada** | Media | Crítico (métricas infladas, fallo en producción) | Auditoría código: split por astronauta, exclusión `in_event`, rolling causal, baseline primeros 30min |
| **Modelo memoriza patrones simulados simples** | Media | Alto (no generaliza a real) | Precursores convexos variables, negativos difíciles (esfuerzo intenso), artefactos, pérdidas señal |
| **Recall bajo en tipo específico** (ej. fatiga muscular) | Alta | Medio | Reportar `n/N` honesto; analizar causas; priorizar en M2 |
| **Falsas alarmas > objetivo en test** | Media | Alto | Umbrales fijos en val; si falla en test → reportar honestamente, no ajustar objetivo |
| **Tamaño test pequeño (~10 eventos)** | Cierta | Medio | Reportar `n/N` + intervalos Wilson; no conclusiones estadísticas fuertes |
| **Calibración pobre** | Baja | Medio | Platt en val; reliability diagram en test; Brier score |
| **Baseline fija inadecuada para EVA larga** | Media | Medio | M3: baseline adaptativa; features m15/slope15 capturan deriva parcial |

---

## 7. Dependencias para la Siguiente Misión (Misión 2: Generación de Dataset)

| Entregable M1 | Uso en M2 |
|---------------|-----------|
| `06_diseno_dataset_sintetico.md` | Especificación completa para `simulate_telemetry.py` (parámetros, ecuaciones, salidas) |
| `03_diccionario_variables.csv` | Definición de columnas telemetry.csv + features derivadas en build_features |
| `05_esquema_etiquetado.md` | Lógica exacta para construir `y, in_event, event_type` desde events.csv |
| `04_especificacion_temporal.md` | Parámetros: H=30min, freq=1min, baseline=30min, split por astronauta |
| `02_catalogo_eventos_medicos.md` | 5 tipos de evento a inyectar con firmas fisiológicas |
| `07_criterios_evaluacion.md` | Métricas, splits, baseline comparison para validar dataset generado |

---

## 8. Recomendación de Próximos Pasos

### Inmediato (Misión 2): Generar Dataset Sintético
```bash
# 1. Ejecutar simulador con parámetros M1
python scripts/simulate_telemetry.py \
    --out mission1_output/data \
    --astronauts 50 --sessions 3 --minutes 480 \
    --event-prob 0.35 --seed 42

# 2. Auditoría calidad (EDA)
python scripts/eda_quality.py --data mission1_output/data --out mission1_output/reports

# 3. Construir features + etiquetas
python scripts/build_features.py \
    --data mission1_output/data \
    --out mission1_output/features.csv \
    --horizon 30 --baseline-min 30

# 4. Verificar: prevalencia y, balance clases, no fuga temporal
```

### Corto Plazo (Misión 3): Entrenar y Evaluar MVP
```bash
# 5. Entrenar modelo + calibrar + elegir umbrales
python scripts/train_model.py \
    --features mission1_output/features.csv \
    --events mission1_output/data/events.csv \
    --out mission1_output/model

# 6. Generar reportes de alerta (3 sesiones: acierto, fallo/tardío, sin evento)
python scripts/generate_alert_report.py \
    --bundle mission1_output/model/model_bundle.joblib \
    --features mission1_output/features.csv \
    --session AST###-S# \
    --events mission1_output/data/events.csv \
    --out mission1_output/alerts/AST###-S#.md
```

### Decisión Crítica Post-M1
> **Si el modelo supera baseline** (recall ↑ y/o FA ↓, anticipación ≥15 min): → **Misión 2: Clasificar tipo de evento (multiclase)** con más casos por tipo.
>
> **Si falla en tipo específico** (ej. fatiga muscular 1/2): → **Primero ampliar simulador** con más casos de ese tipo, mejorar features EMG, antes de multiclase.
>
> **Si baseline gana**: → Revisar features (¿fuga? ¿señales insuficientes?); simplificar a regla experta + ML solo para casos difíciles.

---

## 9. Checklist de Completitud MISIÓN 01

- [x] **Problema predictivo definido** (binario, H=30min, 1min, unit=astronauta×minuto)
- [x] **Eventos médicos clasificados** (5 categorías × eventos específicos, variables, contexto, señales previas, limitaciones)
- [x] **Variables documentadas** (72 columnas en CSV: 10 crudas + 50 derivadas + 6 ID/temporal + 6 target/metadata, clasificación A-F, indispensables)
- [x] **Estructura temporal definida** (baseline 30min, features causales, split por astronauta, exclusión in_event)
- [x] **Etiquetas construibles sin fuga** (y=1 si onset∈(t,t+H], in_event excluye entrenamiento, distinción confirmado/simulado/no observado/desconocido)
- [x] **Dataset sintético especificado** (50 astros, 3 EVA, 480min, perfiles individuales, carga/descanso, variabilidad, ruido, eventos con precursores, reglas generativas documentadas)
- [x] **Criterios de evaluación definidos** (primarias: recall n/N, anticipación med, FA/sesión por nivel; secundarias: ROC/PR-AUC, calibración; split por astronauta; baseline comparison obligatorio)
- [x] **Limitaciones documentadas** (en cada entregable + resumen aquí: simulación, prevalencia, precursor siempre presente, un evento/sesión, sensores ideales, N pequeño)

---

## 10. Validación Requerida

**Antes de iniciar Misión 2, se solicita validación de:**

1. **Horizonte/Frecuencia**: ¿Confirmar **30 min / 1 min** (skills) vs 24h / 15min (parámetros misión original)?
2. **Alcance target**: ¿Confirmar **binario general + metadata tipo** para M1 (multiclase en M2)?
3. **Parámetros simulador**: ¿50 astros × 3 EVA × 480 min × 0.35 event_prob? ¿Ajustar N o prevalencia?
4. **Umbrales FA objetivo**: ¿Vigilancia ≤2, Alerta ≤1, Crítico ≤0.25 FA/sesión (8h)?
5. **Criterios aceptación**: ¿Recall > baseline, anticipación ≥15 min, FA alerta ≤1/sesión?

---

**Firma metodológica**: Este informe establece un marco riguroso, honesto con limitaciones, y alineado con mejores prácticas de ML operacional (split por sujeto, evaluación por evento, calibración, baseline comparison, no data leakage). Los 7 documentos técnicos anexos proveen especificaciones reproducibles para la ejecución inmediata de Misiones 2-3.

---

*MISIÓN 01 COMPLETADA — Listo para validación y continuación*