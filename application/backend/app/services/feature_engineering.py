"""Ingeniería de features de telemetría (ventanas móviles + sigma vs baseline)."""

from __future__ import annotations

from typing import Iterable

import numpy as np
import pandas as pd

SENSOR_VARIABLES = [
    "hr_bpm",
    "spo2_pct",
    "resp_rate_bpm",
    "core_temp_c",
    "skin_temp_c",
    "eeg_theta_beta_ratio",
    "eeg_alpha_uv2",
    "eeg_quality",
    "emg_rms_uv",
    "emg_mdf_hz",
    "rad_dose_rate_usv_h",
    "rad_cum_dose_msv",
]


def records_to_dataframe(records: Iterable[object]) -> pd.DataFrame:
    """Convierte filas ORM de Telemetry (o dicts) en DataFrame ordenado por minuto."""
    rows: list[dict] = []
    for record in records:
        get = record.get if isinstance(record, dict) else lambda key, r=record: getattr(r, key, None)
        row = {"minute": int(get("minute"))}
        for variable in SENSOR_VARIABLES:
            value = get(variable)
            row[variable] = float(value) if value is not None else np.nan
        rows.append(row)
    if not rows:
        return pd.DataFrame(columns=["minute", *SENSOR_VARIABLES])
    return pd.DataFrame(rows).sort_values("minute").reset_index(drop=True)


def _slope(series: pd.Series, window: int) -> pd.Series:
    def fit(values: np.ndarray) -> float:
        values = np.asarray(values, dtype=float)
        mask = ~np.isnan(values)
        if mask.sum() < 2:
            return np.nan
        x = np.arange(len(values))[mask]
        y = values[mask]
        return float(np.polyfit(x, y, 1)[0])

    return series.rolling(window, min_periods=2).apply(fit, raw=True)


def add_rolling_features(df: pd.DataFrame, windows: tuple[int, ...] = (5, 15)) -> pd.DataFrame:
    """Añade delta, medias móviles, desviación y pendiente por variable."""
    out = df.copy()
    for variable in SENSOR_VARIABLES:
        if variable not in out or out[variable].isna().all():
            continue
        series = out[variable]
        out[f"{variable}__delta"] = series.diff()
        for window in windows:
            out[f"{variable}__m{window}"] = series.rolling(window, min_periods=1).mean()
            out[f"{variable}__sd{window}"] = series.rolling(window, min_periods=2).std(ddof=0)
        out[f"{variable}__slope15"] = _slope(series, 15)
    return out


def sigma_vs_baseline(value: float | None, mean: float, std: float) -> float:
    if value is None or np.isnan(value):
        return 0.0
    safe_std = std if std and std > 0 else 1e-6
    return float((value - mean) / safe_std)
