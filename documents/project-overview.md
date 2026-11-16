# PROYECTO EKEKO 

Sistema Experimental de Inteligencia Predictiva y Monitoreo Biomédico para Actividades Extravehiculares EVA 

## 1. Resumen del proyecto 

EKEKO es un sistema experimental de inteligencia predictiva diseñado para el monitoreo biomédico y la anticipación de emergencias médicas durante Actividades Extravehiculares EVA en misiones espaciales. El sistema ingiere telemetría multimodal proveniente de los sensores del traje espacial, calcula desviaciones respecto a la línea base fisiológica individual de cada astronauta y predice la probabilidad de ocurrencia de un evento médico con una ventana de anticipación de 30 minutos en su versión inicial MVP, generando alertas graduadas con explicación fisiológica, hipótesis de causa y acciones recomendadas. 

## 2. Demostración del proyecto

[EKEKO: Health Monitoring System for Astronauts](https://youtu.be/2jTjGC6FOIc)

## 3. Proyecto: Link 

- Estado de enlace externo: https://github.com/Glooskovint/health-monitoring 

## 4. Detalles del Proyecto 

**Executive Summary (Resumen)** 

### **1. Descripción del proyecto** 

### **1.1. ¿Qué hace?** 

- **Ingesta de telemetría multimodal:** Recopila minuto a minuto señales fisiológicas y ambientales del traje espacial, incluyendo frecuencia cardíaca, saturación de oxígeno, frecuencia respiratoria, temperatura central y de piel, señales electroencefalográficas EEG, electromiográficas EMG y dosis de radiación. 

- **Cálculo de línea base individual:** Establece parámetros estadísticos personalizados de media y desviación estándar en una ventana inicial de 30 minutos para cada astronauta y sesión EVA. 

- **Predicción de riesgo médico:** Estima la probabilidad numérica de riesgo de que ocurra un evento médico en los próximos 30 minutos. 

- **Generación de alertas accionables:** Clasifica el riesgo en tres niveles operativos: vigilancia, alerta y crítico, presentando las variables desviadas en unidades de desviación estándar, la hipótesis de causa probable, una acción recomendada y un flujo de gestión y resolución para la tripulación y el equipo médico. 

### **1.2. ¿Cómo funciona?** 

De acuerdo con la arquitectura general del modelo de datos, el flujo operativo de EKEKO consta de siete etapas secuenciales: 

1. **Astronauta en EVA y Sensores Biométricos:** Captura continua de señales fisiológicas y ambientales del traje espacial. 

2. **Captura de Telemetría y Eventos Médicos Reales:** Almacenamiento de registros minuto a minuto en la tabla TELEMETRY y registro histórico de eventos clínicos ocurridos en la tabla MEDICAL_EVENTS. 

3. **Base de Datos PostgreSQL:** Persistencia estructurada en 12 entidades relacionales: ASTRONAUTS, USERS, SESSIONS, TELEMETRY, BASELINES, EVENT_TYPES, MEDICAL_EVENTS, MODELS, MODEL_METRICS, PREDICTIONS, ALERTS y ALERT_ACTIONS. 

4. **Procesamiento de Datos y Línea Base Individual:** Cálculo de estadísticas de referencia en la tabla BASELINES con la media y desviación estándar por cada variable fisiológica. 

5. **Modelo de Inteligencia Artificial y Predicción de Riesgo:** Evaluación de las desviaciones respecto a la línea base para calcular el puntaje de riesgo en PREDICTIONS, excluyendo los periodos con eventos ya activos durante el entrenamiento para evitar fuga temporal de datos. 

6. **Clasificación del Riesgo y Generación de Alertas:** Emisión de alertas graduadas en la tabla ALERTS vinculadas a un catálogo estandarizado de tipos de eventos en EVENT_TYPES. 

7. **Panel de Control Médico y Registro de Acciones:** Visualización por parte del Médico de Vuelo y Control de Misión en la tabla USERS, quienes ejecutan y documentan acciones en ALERT_ACTIONS bajo los estados abierta, reconocida, resuelta o descartada. 

### **1.3. Innovación y propósito** 

- **Propósito central:** Servir como sistema de soporte a la decisión clínica y operativa, sin reemplazar el criterio médico humano, para prevenir emergencias médicas en el espacio. 

- **Transición de lo reactivo a lo proactivo:** Evoluciona desde alarmas de umbrales fijos instantáneos hacia la predicción de trayectoria temporal con 30 minutos de antelación. 

- **Personalización fisiológica:** Evalúa desviaciones relativas frente a la línea base de cada individuo en lugar de utilizar promedios poblacionales genéricos. 

- **Explicabilidad operativa:** No entrega únicamente un porcentaje de riesgo, sino una cadena completa de valor: detectar, clasificar, explicar las variables desviadas, formular hipótesis de causa, recomendar acciones, escalar y aprender. 

- **Control de fatiga de alertas:** Calibra los umbrales de disparo según una tasa objetivo de falsas alarmas menor o igual a una por sesión en nivel de alerta. 

|**Dimensión**|**Sin predicción tradicional**|**Con EKEKO**|
|---|---|---|
|**Detección**|Evento ya ocurrido con reacción tardía|Evento anticipado entre 15 y 30<br>minutos antes permitiendo acción<br>preventiva|
|**Información**|Valor instantáneo comparado contra<br>umbral fijo|Desviación frente a línea base<br>individual más trayectoria temporal|
|**Decisión**|Notificación genérica indicando que<br>algo está mal|Patrón compatible con hipoxia: SpO2<br>-2.3 desviaciones estándar, frecuencia<br>respiratoria +1.8, relación theta/beta<br>+2.1, verificar traje, reducir esfuerzo y preparar retorno|
|**Confianza**|Alarmas de umbral fijo con múltiples|Umbrales calibrados por tasa de falsas|
|**i**|i  i<br>falsos positivos|alarmas objetivo menor o igual a 1 por|
|i|i<br>sesión en nivel alerta|



### **1.4. Beneficios e impacto** 

- **A. Beneficios tecnológicos y de seguridad humana:** En el ámbito tecnológico, integra telemetría biomédica heterogénea en una arquitectura relacional auditada en PostgreSQL bajo Tercera Forma Normal con trazabilidad completa de modelos, métricas, predicciones y acciones médicas. En seguridad humana, reduce el tiempo de respuesta ante cuadros críticos como hipoxia, hipertermia o exposición a radiación solar aguda, otorgando una ventana de 15 a 30 minutos para ejecutar protocolos de retorno o verificación del traje. Los beneficios ambientales específicos no se encuentran detallados en los documentos. 

- **B. Contribución a misiones espaciales y ODS:** Contribuye directamente a la seguridad y autonomía médica de los astronautas durante Actividades Extravehiculares EVA en misiones espaciales tripuladas. La vinculación explícita con Objetivos de Desarrollo Sostenible ODS no se encuentra especificada en los documentos. 

- **C. Impacto esperado en la comunidad operativa y científica:** Beneficia directamente a cuatro perfiles: los astronautas en EVA reciben alertas claras y accionables sin jerga diagnóstica compleja; los médicos de vuelo obtienen resúmenes ejecutivos con señales desviadas, causa probable y ventana de actuación; el control de misión gana visibilidad global del estado de alerta por tripulante y control de falsas alarmas; y los investigadores acceden a datos etiquetados, métricas por evento e importancia de características para la mejora continua. 

### **1.5. Objetivos y resultados esperados** 

- **Objetivo general:** Desarrollar un sistema experimental en su versión mínima viable Misión 1 capaz de anticipar eventos médicos generales mediante clasificación binaria con un horizonte de 30 minutos a partir de telemetría multimodal simulada. 

- **Misión 1 Fase MVP:** Detección binaria de evento médico inminente con horizonte fijo de 30 minutos, generación de hipótesis posteriores sobre 5 categorías principales con aproximadamente 20 por ciento de frecuencia simulada cada una: hipoxia e hipercapnia, estrés térmico, estrés cardíaco, fatiga o lesión muscular y exposición a radiación, manteniendo una tasa de falsas alarmas menor o igual a una por sesión en nivel alerta. 

- **Misión 2 Clasificación multiclase:** Evolución hacia la clasificación multiclase por tipo de evento específico y evaluación de horizontes de predicción variables. 

- **Misión 3 Personalización longitudinal:** Implementación de líneas base adaptativas y modelos entrenados de forma personalizada por cada individuo. 

- **Misión 4 Robustez de sensores:** Incorporación de algoritmos de detección de fallos o artefactos de sensores para distinguir un sensor averiado de una emergencia médica real. 

### **1.6. Metodología y plan de trabajo** 

La metodología del proyecto se estructura en cuatro etapas técnicas principales, sin especificar fechas de calendario: 

8. **Definición del Problema Predictivo Misión 01:** Delimitación del horizonte de predicción de 30 minutos, prevención de fuga temporal excluyendo registros durante eventos activos en el entrenamiento, y definición de usuarios y limitaciones del sistema. 

9. **Catalogación Clínica y Fisiológica:** Estructuración de 20 eventos médicos distribuidos en 5 grandes sistemas: Cardiovascular, Respiratorio, Neurológico, Sistémico y Físico o Ambiental, identificando señales previas como hipótesis de simulación y brechas de observabilidad. 

10. **Modelado Conceptual, Lógico y Físico de Datos:** Diseño del Modelo Conceptual, Diagrama EntidadRelación DER, Diagrama de Clases UML y esquema SQL en PostgreSQL compuesto por 12 tablas y 3 tipos enumerados. 

11. **Auditoría y Normalización de Base de Datos:** Evaluación de Primera, Segunda y Tercera Forma Normal, análisis de dependencias funcionales y propuesta de mejoras en SQL. 

- **Entregables intermedios documentados:** 



<!-- Start of picture text -->
. “ } vitalis<br>= Monitoreo de pacientes<br>*: 00 00<br><!-- End of picture text -->



<!-- Start of picture text -->
Cc ‘<br>: | Monitoreo de pacientes<br><!-- End of picture text -->



<!-- Start of picture text -->
: | Estado del sistema<br>: 04 61 + omc<br>Be: Servicios e infraestructura<br><!-- End of picture text -->

### **1.7. Metodología y herramientas** 

- **1.7.1. Herramientas y software utilizados:** Motor de base de datos relacional PostgreSQL, con soporte para tipos enumerados ENUM, restricciones UNIQUE, CHECK y almacenamiento semiestructurado JSONB. Para el desarrollo de la interfaz de usuario se utiliza React. Asimismo, se emplean herramientas 

de modelado Entidad-Relación (DER), UML y diseño conceptual para representar la estructura y organización del sistema. 

- **1.7.2. Lenguaje de programación y framework: Se** utiliza Python como lenguaje de programación para el desarrollo del backend y la lógica del sistema, React para el desarrollo del frontend y SQL para la definición y gestión de esquemas relacionales, claves primarias, claves foráneas y consultas a la base de datos. El modelado orientado a objetos se representa mediante UML, utilizando tipos de datos como String, Long, Integer, Decimal, Boolean, Date, DateTime y JSON, así como enumeraciones como UserRole, AlertLevel y AlertStatus. La persistencia de datos se gestiona mediante PostgreSQL. 

- **1.7.3. Hardware y sensores modelados:** El sistema procesa señales de cuatro grupos de sensores biomédicos y ambientales integrados en el traje espacial: 

|**Grupo de Sensor**|**Variables Medidas en Telemetría**|**Brechas y Limitaciones de**<br>**Observabilidad**|
|---|---|---|
|**Sensor corporal y oxímetro de pulso**|Frecuencia cardíaca hr_bpm,<br>saturación de oxígeno spo2_pct,<br>frecuencia respiratoria<br>resp_rate_bpm, temperatura central<br>proxy core_temp_c y temperatura de<br>piel skin_temp_c|Sin presión arterial invasiva, sin ECG<br>de 12 derivaciones, sin gasometría<br>arterial ni débito cardíaco|
|**Electroencefalograma EEG de 2**<br>**canales frontales**|Relación de ondas Theta/Beta<br>eeg_theta_beta_ratio, potencia Alfa<br>eeg_alpha_uv2 y calidad de señal<br>eeg_quality|Resolución espacial nula, sin<br>localización focal ni detección de<br>convulsión no generalizada|
|**Electromiograma superficial EMG**|Amplitud cuadrática media<br>emg_rms_uv y frecuencia mediana<br>emg_mdf_hz|No mide fuerza dinámica real,<br>marcadores bioquímicos como CK ni<br>diferencia fatiga central de periférica|
|**Dosímetro de radiación**|Tasa de dosis instantánea en<br>microsieverts por hora<br>rad_dose_rate_usv_h y dosis<br>acumulada en milisieverts<br>rad_cum_dose_msv|Medición puntual sin espectro<br>energético, sin dosis equivalente por<br>órgano ni medición de neutrones|



### **1.8. Gestión de proyecto** 

 **Cuadro de equipo:** Analaista de datos: Jhon Frontend: Luis Antonio Backend: Luis Guillermo Devops y testing: Angelo 

### **1.9. Localización y ubicación del proyecto** 

- **Ubicación del proyecto:** En un repositorio (GitHub). 

- **Justificación del proyecto:** En el entorno espacial los sensores del traje son limitados y no existen equipos de diagnóstico hospitalario como ecografías, rayos X o laboratorio clínico. Dado que eventos como la hipoxia o el golpe de calor pueden volverse irreversibles en pocos minutos, anticipar estos cuadros entre 15 y 30 minutos antes mediante patrones proxy multimodales resulta vital para la supervivencia de la tripulación. 

### **1.10. Impacto y Beneficios** 

- **Relevancia con misiones espaciales y estándares internacionales:** Los documentos establecen una distinción rigurosa entre las hipótesis de simulación del prototipo y la evidencia médica validada bajo protocolos reales de agencias espaciales como NASA, ESA y Roscosmos. 

- **Alineación estratégica:** EKEKO aborda directamente los riesgos médicos críticos catalogados en la medicina aeroespacial, incluyendo el síndrome de descompresión, la exposición a partículas solares, fallos del sistema de soporte vital del traje como fugas de oxígeno o saturación del depurador de dióxido de carbono, estrés térmico y descondicionamiento cardiovascular. Además, proyecta su validación futura mediante correlación con estándares clínicos de referencia en análogos terrestres. 

### **1.11. Resultados esperados** 

- **Arquitectura de datos normalizada:** Base de datos PostgreSQL de 12 tablas normalizadas capaz de almacenar telemetría minuto a minuto sin duplicidad mediante restricciones de unicidad por sesión y minuto, líneas base individuales y trazabilidad completa de predicciones y alertas. 

- **Desempeño predictivo en fase MVP:** Anticipación de eventos médicos con 30 minutos de antelación manteniendo una tasa controlada de falsas alarmas menor o igual a una por sesión en nivel de alerta sobre un conjunto simulado con aproximadamente 35 por ciento de sesiones con evento y 44 eventos totales. 

- **Soporte clínico interpretable:** Generación automática de hipótesis etiológicas preliminares entre los cinco grupos de eventos del simulador acompañadas de acciones recomendadas verificables por el médico de vuelo. 

### **1.12. Conclusiones y futuras mejoras** 

- **Lecciones aprendidas sobre fuga temporal:** Es indispensable excluir del entrenamiento los registros ocurridos durante un evento médico ya activo para garantizar que el modelo aprenda señales precursoras reales y no se limite a detectar eventos en curso. 

- **Lecciones sobre observabilidad clínica:** Debido a que los sensores del traje miden variables indirectas, el sistema debe incluir un descargo obligatorio indicando que no sustituye el criterio médico y priorizar la verificación de integridad del sensor ante cualquier alerta. 

- **Hallazgos de auditoría relacional:** La evaluación de normalización determinó que la mayoría de las tablas cumplen la Tercera Forma Normal, pero identificó que los campos JSONB cumplen la Primera Forma Normal de forma condicional y que almacenar el identificador de sesión dentro de la tabla ALERTS introduce una dependencia transitiva respecto al identificador de predicción. 

- **Optimizaciones futuras en SQL:** Eliminar la columna redundante session_id de la tabla ALERTS para obtenerla mediante consulta relacional con PREDICTIONS; agregar restricciones de validación como desviación estándar mayor o igual a cero en BASELINES y unicidad por modelo, partición y métrica en MODEL_METRICS; y evaluar la separación de atributos JSONB en tablas hijas si se requiere filtrado individual. 

- **Optimizaciones futuras en Inteligencia Artificial:** Migrar hacia clasificación multiclase por evento específico en Misión 2, desarrollar líneas base adaptativas longitudinales en Misión 3 e incorporar detección automática de fallos de sensores en Misión 4. 

### **1.13. Anexos y Apéndices** 

- **Anexo A:** Diagrama Entidad-Relación DER de 12 tablas con tipos de datos, claves primarias, foráneas y restricciones de unicidad. 



<!-- Start of picture text -->
=a<br>==<br>——- =S=2<br>=e = ————<br>=a Sa SS5 =|<br>ale ai es af<br>SS = = = ==<br>=| === . Se<br>= s==—<br>===}<br>a<br>==i=<br>Paz<br><!-- End of picture text -->

- **Anexo B:** Diagrama de Clases UML con atributos tipados, relaciones de cardinalidad y enumeraciones. 



<!-- Start of picture text -->
—=_<br>oe ———:<br><a<br><!-- End of picture text -->



<!-- Start of picture text -->
ASTRONAUTA,<br>puede estar sacado 3 SESION EVA TPO DE EVENTO MODELO PREDICTIVO<br><!-- End of picture text -->

 **Anexo C:** Modelo Conceptual y Diagrama de Arquitectura General del Modelo de Datos. 

## **5. Uso de IA** 

Durante el desarrollo, diseño arquitectónico, documentación técnica e implementación de EKEKO, se emplearon cuatro herramientas de Inteligencia Artificial con propósitos especializados: 

- **Claude:** Análisis estructural profundo, redacción técnica de documentación del problema predictivo, catalogación clínica de eventos médicos aeroespaciales y diseño conceptual de la arquitectura de datos. 

- **Codex:** Generación, revisión y optimización de código fuente, scripts SQL de creación de tablas en PostgreSQL, definición de restricciones de integridad y lógica de procesamiento de telemetría. 

- **Gemini:** Auditoría de normalización de base de datos en 1FN, 2FN y 3FN, verificación de dependencias funcionales, síntesis de información multimodal y estructuración de informes técnicos ejecutivos. 

- **ChatGPT:** Ideación inicial, apoyo en resolución de consultas técnicas, validación de flujos operativos, refinamiento de textos explicativos y asistencia general durante las fases de desarrollo. 

## **6. Datos de la NASA** 

- **Fuente de referencia utilizada:** 

https://www.asc-csa.gc.ca/eng/news/articles/2026/2026-02-26-monitoring-radiation-astronauthealth.asp 

## **7. Socios de la agencia espacial** 

####  **Referencias institucionales:** 

## **ANEXOS** 

Los documentos fuente incluyen cuatro diagramas técnicos integrados en el archivo de modelado de datos, junto con el catálogo detallado de 20 eventos médicos y la auditoría de 12 tablas: 

|**Entidad / Tabla SQL**|**1FN**|**2FN**|**3FN**|**Descripción y**<br>**Observación**<br>**Técnica**|
|---|---|---|---|---|
|**astronauts**|Sí|Sí|Sí|Registro maestro de<br>astronautas con<br>correo electrónico<br>único.|
|**users**|Sí|Sí|Sí|Usuarios del sistema<br>con rol asignado y<br>vínculo opcional a<br>astronauta.|
|**sessions**|Condicional|Sí|Sí|Sesiones EVA;<br>contiene atributo<br>ambiental en formato<br>JSONB.|
|**telemetry**|Sí|Sí|Sí|Mediciones<br>fisiológicas y<br>ambientales minuto a<br>minuto sin<br>duplicidad.|
|**baselines**|Sí|Sí|Sí|Media y desviación<br>estándar individual<br>por sesión y variable.|
|**event_types**|Sí|Sí|Sí|Catálogo maestro de<br>tipos de eventos<br>médicos.|
|**medical_events**|Sí|Sí|Sí|Historial de eventos<br>médicos reales<br>ocurridos durante<br>sesiones EVA.|
|**models**|Condicional|Sí|Sí|Versiones de<br>modelos de IA con<br>hiperparámetros en<br>JSONB.|
|**model_metrics**|Sí|Sí|Sí|Métricas de<br>evaluación por<br>modelo y partición de<br>datos.|
|**predictions**|Condicional|Sí|Sí|Predicciones de|



|||||riesgo a 30 minutos<br>con variables<br>explicativas JSONB.|
|---|---|---|---|---|
|**alerts**|Sí|Sí|Revisar|Alertas generadas; se<br>recomienda eliminar<br>session_id<br>redundante para 3FN<br>estricta.|
|**alert_actions**|Sí|Sí|Sí|Bitácora de acciones<br>ejecutadas por el<br>personal médico<br>sobre cada alerta.|



####  **Pantalla de Inicio de Sesión / Control de Acceso** 



<!-- Start of picture text -->
Z Control de mision<br>: Cada sefial.<br><!-- End of picture text -->

 **Centro de Operaciones / Vista General de Misiones** 



<!-- Start of picture text -->
Go CeCma=s Hele wun sae nae<br>C= emt<br>|<br>* 3 EKEKO en oe<br>: | Centro de operaciones. :<br>: 08 88 97.5 83<br>: alliihbiiti<br>. |<br><!-- End of picture text -->

 **Perfil individual y Gemelo Digital de Elena Martínez** 



<!-- Start of picture text -->
Or Ceomenn Hess SESS<br>i " e# Elena Martinez : |<br>: Gemeto digital<br>ry<br><!-- End of picture text -->

####  **Perfil individual y Gemelo Digital de Lucas Ferreira** 



<!-- Start of picture text -->
r= Gecmash Wegne Suoralalees<br>‘De<br>tr Lucas Ferreira < |<br>: Gemelo digital<br>> 75 3<br>At<br>y<br>-.<br>|<br>| a\y l<br>ee OD eco<br><!-- End of picture text -->

####  **Centro de alertas** 



<!-- Start of picture text -->
Gene Cocmanm Beane GEOSOEE<br>(es 3 EKEKO herent<br>= Centro de alertas.<br><!-- End of picture text -->

