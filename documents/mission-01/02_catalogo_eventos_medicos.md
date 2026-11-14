# Catálogo de Eventos Médicos

## Principios de clasificación

- **No se inventan criterios clínicos ni umbrales médicos**. Los eventos y sus firmas fisiológicas se basan en literatura aeroespacial y fisiología extrema, pero **los umbrales numéricos, duratas y magnitudes son hipótesis de simulación** para el MVP.
- **Diferencia clara**: *Hipótesis de simulación* (parámetros del generador sintético) vs *Evidencia médica validada* (protocolos NASA/ESA/Roscosmos reales).
- **Evento general (M1)**: El modelo predice "evento médico inminente" (binario). El tipo se registra como metadata para análisis post-hoc y Misión 2.
- **Limitaciones de observabilidad**: Sensores del traje limitados (ver sensor-map.md); no hay ECG de 12 derivaciones, gasometría arterial, imagen, ni laboratorio.

---

## 1. Eventos Cardiovasculares

| Evento específico | Descripción | Variables fisiológicas relacionadas | Información contextual necesaria | Señales previas (hipótesis simulación) | Limitaciones de observabilidad |
|-------------------|-------------|-------------------------------------|----------------------------------|----------------------------------------|-------------------------------|
| **Arritmia significativa** | Fibrilación auricular, taquicardia ventricular, bradicardia severa | FC (hr_bpm), variabilidad FC (HRV derivable), SpO2, RR | Historial cardíaco previo, medicación, carga de trabajo actual | FC irregular (derivable de serie temporal), SpO2 caída leve, RR compensatoria | Sin ECG → no se clasifica tipo de arritmia; FC del oxímetro puede tener artefactos de movimiento |
| **Isquemia / SCA** | Síndrome coronario agudo | FC, SpO2, RR, temp central, EMG (dolor torácico → tensión) | Factores de riesgo CV, edad, misión previa | FC ↑ sostenida, SpO2 ↓ leve, RR ↑, posible EMG ↑ torácico | Dolor subjetivo no medido; síntomas atípicos en microgravedad |
| **Insuficiencia cardíaca aguda** | Descompensación aguda | FC, SpO2, RR, temp, variabilidad FC | Historia CV, fluidos, carga | FC ↑, SpO2 ↓ progresiva, RR ↑↑, fatiga (EMG) | Similar a estrés por esfuerzo intenso (negativo difícil) |
| **Shock distributivo** | Séptico, anafiláctico, neurogénico | FC ↑↑, SpO2 ↓, RR ↑↑, temp variable | Infección previa, alergias, trauma | Hipotensión no medida; taquicardia compensatoria, piel fría (skin_temp ↓) | Sin PA invasiva; skin_temp proxy imperfecto |

---

## 2. Eventos Respiratorios

| Evento específico | Descripción | Variables fisiológicas relacionadas | Información contextual necesaria | Señales previas (hipótesis simulación) | Limitaciones de observabilidad |
|-------------------|-------------|-------------------------------------|----------------------------------|----------------------------------------|-------------------------------|
| **Hipoxia / Hipercapnia** | Fallo sistema soporte vital, fuga traje, CO2 scrubber saturado | SpO2 (spo2_pct), RR (resp_rate_bpm), θ/β EEG (eeg_theta_beta_ratio), α EEG (eeg_alpha_uv2), FC | Presión traje, O2/CO2 parciales, duración EVA | SpO2 ↓ rampa, RR ↑ compensatoria, θ/β ↑ (hipoxia cerebral), α ↓, FC ↑ | SpO2 del dedo → retraso vs arterial; EEG ruido movimiento |
| **Edema pulmonar agudo** | Por sobrecarga de fluidos, hipoxia severa | RR, SpO2, FC, variabilidad RR | Balance hídrico, meds, gravedad | RR ↑↑ patrón irregular, SpO2 ↓↓, FC ↑, posible θ/β ↑ | Sin auscultación, Rx, BNP |
| **Broncoespasmo / Asma** | Reactividad vías aéreas | RR, SpO2, FC, EMG accesorios (derivable) | Alergias, exposición irritantes | RR ↑ con patrón obstructivo, SpO2 ↓ tardía | Sin espirometría, capnografía |
| **Neumotórax a tensión** | Trauma, barotrauma | RR ↑↑, SpO2 ↓↓, FC ↑↑, asimetría EMG torácica | Trauma reciente, cambios presión | Inicio súbito, deterioro rápido minutos | Sin RX, ecografía, PA pleural |

---

## 3. Eventos Neurológicos

| Evento específico | Descripción | Variables fisiológicas relacionadas | Información contextual necesaria | Señales previas (hipótesis simulación) | Limitaciones de observabilidad |
|-------------------|-------------|-------------------------------------|----------------------------------|----------------------------------------|-------------------------------|
| **Síncope / Presíncope** | Hipoperfusión cerebral aguda | FC, SpO2, RR, θ/β EEG, α EEG, temp | Descondicionamiento ortostático, fluidos | FC ↑ compensatoria luego ↓ brusca, θ/β ↑, α ↓, mareo no medido | Sin PA continua, NIRS cerebral |
| **Evento cerebrovascular** | Ictus isquémico/hemorrágico | Asimetría EEG (hemisférico), FC, RR, EMG focal | Factores riesgo CV, edad, radiación | Asimetría θ/β o α hemisférica, déficit motor (EMG asimétrico) | EEG 2 canales (frontales) → resolución espacial nula |
| **Convulsión** | Actividad epiléptica | EEG θ/β ↑↑, α ↓↓, EMG rms ↑↑ generalizado | Historia neurológica, meds, hipoxia previa | Patrón rítmico EEG/EMG, post-ictal: fatiga EMG mdf ↓ | EEG limitado; artefacto movimiento imita |
| **Deterioro cognitivo agudo** | Fatiga severa, hipoxia, hipertemia | θ/β ↑ progresivo, α ↓, tiempo reacción (no medido), errores tarea | Carga trabajo, sueño, CO2 | θ/β rampa >30 min, α ↓, variabilidad FC ↓ | Sin test cognitivo estandarizado en traje |

---

## 4. Eventos Sistémicos

| Evento específico | Descripción | Variables fisiológicas relacionadas | Información contextual necesaria | Señales previas (hipótesis simulación) | Limitaciones de observabilidad |
|-------------------|-------------|-------------------------------------|----------------------------------|----------------------------------------|-------------------------------|
| **Estrés térmico / Hipertermia maligna** | Fallo regulación térmica traje, esfuerzo extremo | Temp central (core_temp_c), temp piel (skin_temp_c), FC, RR, SpO2 | Temp ambiente, capa 7 traje, hidratación, aclimatación | Core ↑ rampa 0.5-1.5°C/30min, skin ↑, FC ↑ compensatoria, RR ↑ | Core_temp proxy (esofágico/rectal no factible); skin variable |
| **Hipotermia** | Fuga térmica, fallo calefacción | Core ↓, skin ↓↓, FC ↓ (bradicardia), RR ↓, EMG rigidez | Exposición prolongada, traje mojado | Core ↓ progresiva, temblor (EMG rms ↑, mdf ↓) | Similar a fatiga muscular |
| **Sepsis / SIRS** | Infección sistémica | FC ↑, RR ↑, temp ↑/↓, SpO2 ↓, θ/β ↑ | Herida, inmunosupresión, catéter | Patrón inespecífico; qSOFA proxy: FC>130, RR>22, θ/β ↑ | Sin lactato, PCR, cultivos, PA |
| **Síndrome de descompresión** | Burbujas N2 tras despresurización rápida | Dolor articular (EMG focal), neuro (EEG), cutáneo (skin_temp) | Perfil descompresión, tiempo prebreathe | Dolor no medido; posible EMG focal, EEG difuso | Sin imagen, Doppler precordial |

---

## 5. Eventos Físicos / Trauma / Ambientales

| Evento específico | Descripción | Variables fisiológicas relacionadas | Información contextual necesaria | Señales previas (hipótesis simulación) | Limitaciones de observabilidad |
|-------------------|-------------|-------------------------------------|----------------------------------|----------------------------------------|-------------------------------|
| **Fatiga muscular severa / Rabdomiólisis** | Esfuerzo extremo prolongado, trauma por presión traje | EMG mdf ↓ (fatiga), rms ↑ (reclutamiento), CK no medido, core ↑, FC ↑ | Ajuste traje, ergonomía, carga trabajo, hidratación | mdf ↓ rampa >20 min, rms ↑, core ↑ leve, FC ↑ | Sin CK, mioglobina, fuerza dinámica |
| **Lesión por presión / Trauma tisular** | Puntos de presión traje, heridas | EMG focal, skin_temp local, FC/RR respuesta dolor | Ajuste traje, duración EVA, historial lesión | EMG asimétrico, skin_temp focal ↑/↓, FC/RR reactivas | Sin imagen, presión interfacial |
| **Exposición a radiación aguda (SPE)** | Evento de partículas solares | Tasa dosis (rad_dose_rate_usv_h) ↑↑ sostenida, dosis acumulada (rad_cum_dose_msv), FC ↑, θ/β ↑ | Clima espacial, blindaje, ubicación | Tasa dosis ×5-12 sostenida >30 min, FC ↑ leve, θ/β ↑ | Dosímetro traje = tasa puntual; sin espectro, órgano diana |
| **Fallo sistema soporte vital (traje)** | Fuga O2, CO2, energía, comunicaciones | SpO2 ↓, RR ↑, FC ↑, θ/β ↑, rad (si blindaje perdido), EMG (esfuerzo reparación) | Telemetría traje (presión, baterías), checklists | Múltiples señales desviadas simultáneas; patrón "sistema" no "fisiológico" | Diagnóstico diferencial con evento médico primario |

---

## 6. Resumen para el MVP (Misión 1)

| Evento tipo (simulador) | Categoría principal | Frecuencia simulada | Prioridad MVP |
|-------------------------|---------------------|---------------------|---------------|
| `hipoxia_hipercapnia` | Respiratorio | ~20% eventos | Alta (firma clara multi-sensor) |
| `estres_termico` | Sistémico | ~20% eventos | Alta (temp core/skin + FC/RR) |
| `estres_cardiaco` | Cardiovascular | ~20% eventos | Alta (FC irregular + SpO2) |
| `fatiga_lesion_muscular` | Físico | ~20% eventos | Media (EMG mdf/rms sutiles) |
| `exposicion_radiacion` | Ambiental | ~20% eventos | Alta (rad_dose_rate claro) |

**Nota**: En M1 el modelo aprende "evento general" (binario). Los 5 tipos se usan para:
- Análisis de recall por tipo (detectar cuáles falla el modelo)
- Generación de hipótesis de causa en decision-support
- Base para M2 (clasificación multiclase)

---

## 7. Limitaciones de observabilidad — Resumen transversal

| Sensor | Qué mide | Qué NO mide (brecha) |
|--------|----------|----------------------|
| Sensor corporal + oxímetro | FC, SpO2, RR, temp core/skin | PA invasiva, gasometría, débito cardíaco, llenado capilar |
| EEG (2 ch frontales) | θ/β ratio, α power, calidad | Localización focal, convulsión no generalizada, sueño profundo |
| EMG (superficial) | RMS amplitud, MDF frecuencia | Fuerza real, fatiga central vs periférica, lesión muscular específica |
| Radiación | Tasa dosis µSv/h, acumulada mSv | Espectro energético, dosis equivalente órgano, neutrones |

**Implicación para modelado**: El modelo aprende **patrones proxy**, no patofisiología directa. La validación clínica real requerirá correlación con gold standard (ECG, gasometría, imagen, laboratorio) en análogos terrestres.

---

*Documento generado como parte de MISIÓN 01 — Definición del Problema Predictivo*