"""Construcción de alertas explicables para soporte a la decisión.

El lenguaje es operativo, nunca diagnóstico. Cada alerta incluye:
nivel, señales desviadas (en σ), hipótesis de causa y acción recomendada.
"""

from __future__ import annotations

from .predictor import RiskResult

HYPOTHESIS_LABELS: dict[str, str] = {
    "hipoxia_hipercapnia": "hipoxia/hipercapnia",
    "estres_termico": "estrés térmico",
    "estres_cardiaco": "estrés cardíaco",
    "fatiga_lesion_muscular": "fatiga/lesión muscular",
    "exposicion_radiacion": "exposición a radiación",
}

RECOMMENDED_ACTIONS: dict[str, str] = {
    "hipoxia_hipercapnia": (
        "Verificar suministro de O2 y scrubber de CO2; reducir esfuerzo; "
        "preparar retorno a la esclusa."
    ),
    "estres_termico": (
        "Verificar regulación térmica del traje; reducir actividad; "
        "monitorear temperatura central."
    ),
    "estres_cardiaco": (
        "Confirmar con telemetría y contacto verbal; reducir esfuerzo; "
        "alertar al médico de vuelo."
    ),
    "fatiga_lesion_muscular": (
        "Reducir carga de trabajo; revisar puntos de presión del traje; "
        "programar descanso."
    ),
    "exposicion_radiacion": (
        "Solicitar refugio/blindaje; consultar clima espacial; "
        "registrar dosis acumulada."
    ),
}

DEFAULT_ACTION = (
    "Verificar primero la calidad de los sensores; confirmar con el astronauta "
    "antes de escalar; notificar al médico de vuelo."
)


def _format_features(result: RiskResult) -> str:
    parts = [
        f"{feature['variable']} {feature['sigma']:+.1f}σ"
        for feature in result.top_features
    ]
    return ", ".join(parts) if parts else "sin desviaciones relevantes"


def build_summary(result: RiskResult, astronaut_id: str | None = None) -> str:
    label = HYPOTHESIS_LABELS.get(result.hypothesis_code or "", "evento inespecífico")
    who = f"Astronauta {astronaut_id}: " if astronaut_id else ""
    return (
        f"{who}patrón compatible con {label}: {_format_features(result)} "
        f"→ riesgo {result.risk_score:.0%} en próximos 30 min."
    )


def recommend(result: RiskResult) -> str:
    return RECOMMENDED_ACTIONS.get(result.hypothesis_code or "", DEFAULT_ACTION)
