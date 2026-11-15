"""Modelo de riesgo MVP (heurística interpretable).

Sustituible por un modelo supervisado (p. ej. Gradient Boosting) que consuma las
mismas features. Aquí se prioriza la *explicabilidad*: cada variable aporta un
término basado en su desviación (σ) respecto de la línea base individual y en su
tendencia reciente (pendiente de 15 min).
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Iterable

import pandas as pd

from .feature_engineering import (
    SENSOR_VARIABLES,
    add_rolling_features,
    records_to_dataframe,
    sigma_vs_baseline,
)

# +1 = un valor ALTO es fisiológicamente peor; -1 = un valor BAJO es peor.
DIRECTION: dict[str, int] = {
    "hr_bpm": 1,
    "spo2_pct": -1,
    "resp_rate_bpm": 1,
    "core_temp_c": 1,
    "skin_temp_c": 1,
    "eeg_theta_beta_ratio": 1,
    "eeg_alpha_uv2": -1,
    "emg_rms_uv": 1,
    "emg_mdf_hz": -1,
    "rad_dose_rate_usv_h": 1,
    "rad_cum_dose_msv": 1,
}

# Peso relativo de cada variable en el riesgo (hipótesis de simulación MVP).
WEIGHTS: dict[str, float] = {
    "hr_bpm": 0.20,
    "spo2_pct": 0.40,
    "resp_rate_bpm": 0.25,
    "core_temp_c": 0.25,
    "skin_temp_c": 0.10,
    "eeg_theta_beta_ratio": 0.30,
    "eeg_alpha_uv2": 0.10,
    "emg_rms_uv": 0.10,
    "emg_mdf_hz": 0.15,
    "rad_dose_rate_usv_h": 0.35,
    "rad_cum_dose_msv": 0.05,
}

HYPOTHESIS_GROUPS: dict[str, list[str]] = {
    "hipoxia_hipercapnia": ["spo2_pct", "resp_rate_bpm", "eeg_theta_beta_ratio", "eeg_alpha_uv2"],
    "estres_termico": ["core_temp_c", "skin_temp_c", "hr_bpm"],
    "estres_cardiaco": ["hr_bpm", "spo2_pct", "resp_rate_bpm"],
    "fatiga_lesion_muscular": ["emg_rms_uv", "emg_mdf_hz", "core_temp_c"],
    "exposicion_radiacion": ["rad_dose_rate_usv_h", "rad_cum_dose_msv"],
}

LEVEL_ALERT = 0.35
LEVEL_CRITICAL = 0.65


@dataclass
class RiskResult:
    minute: int
    risk_score: float
    level: str
    hypothesis_code: str | None
    top_features: list[dict] = field(default_factory=list)


class HeuristicRiskPredictor:
    """Predictor de riesgo de evento médico en el horizonte configurado."""

    def __init__(self, horizon_minutes: int = 30) -> None:
        self.horizon_minutes = horizon_minutes

    @staticmethod
    def risk_to_level(score: float) -> str:
        if score >= LEVEL_CRITICAL:
            return "critical"
        if score >= LEVEL_ALERT:
            return "alert"
        return "surveillance"

    def predict(
        self,
        telemetry_records: Iterable[object],
        baselines: dict[str, tuple[float, float]],
        horizon_minutes: int | None = None,
    ) -> RiskResult | None:
        df = records_to_dataframe(telemetry_records)
        if df.empty:
            return None

        df = add_rolling_features(df)
        last = df.iloc[-1]
        minute = int(last["minute"])

        contributions: list[dict] = []
        group_scores = {group: 0.0 for group in HYPOTHESIS_GROUPS}

        for variable in SENSOR_VARIABLES:
            if variable not in baselines:
                continue
            mean, std = baselines[variable]
            raw_value = last.get(variable)
            value = None if raw_value is None or pd.isna(raw_value) else float(raw_value)
            raw_sigma = sigma_vs_baseline(value, mean, std)

            weight = WEIGHTS.get(variable, 0.0)
            direction = DIRECTION.get(variable, 1)
            signed_deviation = max(0.0, raw_sigma * direction)

            slope_value = last.get(f"{variable}__slope15")
            trajectory = 0.0
            if slope_value is not None and not pd.isna(slope_value):
                trajectory = max(0.0, math.tanh(float(slope_value) * direction * 2.0))

            contribution = weight * (signed_deviation + 0.5 * trajectory)
            if contribution <= 0:
                continue

            contributions.append(
                {
                    "variable": variable,
                    "sigma": round(raw_sigma, 2),
                    "direction": "up" if raw_sigma >= 0 else "down",
                    "score": round(contribution, 3),
                }
            )
            for group, variables in HYPOTHESIS_GROUPS.items():
                if variable in variables:
                    group_scores[group] += contribution

        total = sum(feature["score"] for feature in contributions)
        risk_score = round(1.0 - math.exp(-total), 4) if total > 0 else 0.0
        level = self.risk_to_level(risk_score)

        hypothesis = None
        if contributions:
            best_group = max(group_scores, key=group_scores.get)
            if group_scores[best_group] > 0:
                hypothesis = best_group

        top_features = sorted(contributions, key=lambda f: f["score"], reverse=True)[:5]

        return RiskResult(
            minute=minute,
            risk_score=risk_score,
            level=level,
            hypothesis_code=hypothesis,
            top_features=top_features,
        )
