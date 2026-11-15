"""
Carga de telemetría simulada a PostgreSQL.

Uso (desde la raíz del proyecto):
    python db/load_csv.py --telemetry data/telemetry.csv [--events data/events.csv]

El DSN usa el mismo formato que el backend (SQLAlchemy):
    postgresql+psycopg://postgres:postgres@localhost:5432/eva_health

Requiere la variable de entorno DATABASE_URL (o --dsn).
"""

from __future__ import annotations

import argparse
import math
import os

import pandas as pd
from sqlalchemy import create_engine, text

SENSOR_COLUMNS = [
    "hr_bpm", "spo2_pct", "resp_rate_bpm", "core_temp_c", "skin_temp_c",
    "eeg_theta_beta_ratio", "eeg_alpha_uv2", "eeg_quality",
    "emg_rms_uv", "emg_mdf_hz", "rad_dose_rate_usv_h", "rad_cum_dose_msv",
]

BASELINE_WINDOW_MIN = 30


def clean(value):
    """NaN/NaT -> None para que Postgres reciba NULL."""
    if value is None:
        return None
    if isinstance(value, float) and math.isnan(value):
        return None
    return value


def insert_astronauts(conn, telemetry: pd.DataFrame) -> None:
    rows = [
        {"astronaut_id": astronaut_id, "full_name": f"Astronauta {astronaut_id}"}
        for astronaut_id in telemetry["astronaut_id"].dropna().unique()
    ]
    if rows:
        conn.execute(
            text(
                "INSERT INTO astronauts (astronaut_id, full_name) VALUES "
                "(:astronaut_id, :full_name) ON CONFLICT (astronaut_id) DO NOTHING"
            ),
            rows,
        )


def insert_sessions(conn, telemetry: pd.DataFrame) -> None:
    for (session_id, astronaut_id), group in telemetry.groupby(["session_id", "astronaut_id"]):
        conn.execute(
            text(
                "INSERT INTO sessions (session_id, astronaut_id, started_at, ended_at) "
                "VALUES (:session_id, :astronaut_id, :started_at, :ended_at) "
                "ON CONFLICT (session_id) DO UPDATE SET ended_at = EXCLUDED.ended_at"
            ),
            {
                "session_id": session_id,
                "astronaut_id": astronaut_id,
                "started_at": group["timestamp"].min(),
                "ended_at": group["timestamp"].max(),
            },
        )


def insert_telemetry(conn, telemetry: pd.DataFrame) -> None:
    columns = ["session_id", "minute", "recorded_at", *SENSOR_COLUMNS]
    statement = text(
        f"INSERT INTO telemetry ({', '.join(columns)}) VALUES "
        f"({', '.join(':' + col for col in columns)}) "
        "ON CONFLICT (session_id, minute) DO NOTHING"
    )
    rows = []
    for row in telemetry.itertuples(index=False):
        record = {
            "session_id": row.session_id,
            "minute": int(row.minute),
            "recorded_at": row.timestamp,
        }
        for column in SENSOR_COLUMNS:
            value = clean(getattr(row, column))
            record[column] = None if pd.isna(value) else float(value)
        rows.append(record)
    if rows:
        conn.execute(statement, rows)


def compute_baselines(conn, telemetry: pd.DataFrame) -> None:
    rows = []
    for session_id, group in telemetry.groupby("session_id"):
        window = group[group["minute"] < BASELINE_WINDOW_MIN]
        if window.empty:
            continue
        for column in SENSOR_COLUMNS:
            series = pd.to_numeric(window[column], errors="coerce").dropna()
            if series.empty:
                continue
            std = float(series.std(ddof=0))
            rows.append(
                {
                    "session_id": session_id,
                    "variable": column,
                    "window_minutes": BASELINE_WINDOW_MIN,
                    "mean": float(series.mean()),
                    "std": std if std and not math.isnan(std) else 1.0,
                }
            )
    if rows:
        conn.execute(
            text(
                "INSERT INTO baselines (session_id, variable, window_minutes, mean, std) "
                "VALUES (:session_id, :variable, :window_minutes, :mean, :std) "
                "ON CONFLICT (session_id, variable) DO UPDATE "
                "SET mean = EXCLUDED.mean, std = EXCLUDED.std"
            ),
            rows,
        )


def insert_events(conn, events: pd.DataFrame) -> None:
    rows = [
        {
            "session_id": row.session_id,
            "event_type_code": row.event_type,
            "onset_minute": int(row.onset_minute),
            "end_minute": clean(getattr(row, "end_minute", None)),
        }
        for row in events.itertuples(index=False)
    ]
    if rows:
        conn.execute(
            text(
                "INSERT INTO medical_events "
                "(session_id, event_type_code, onset_minute, end_minute) VALUES "
                "(:session_id, :event_type_code, :onset_minute, :end_minute)"
            ),
            rows,
        )


def main() -> None:
    parser = argparse.ArgumentParser(description="Carga telemetría EVA en PostgreSQL")
    parser.add_argument("--telemetry", required=True, help="Ruta al CSV de telemetría")
    parser.add_argument("--events", help="Ruta al CSV de eventos (verdad terreno)")
    parser.add_argument("--dsn", default=os.getenv("DATABASE_URL"))
    args = parser.parse_args()

    if not args.dsn:
        raise SystemExit("Falta DATABASE_URL o --dsn")

    telemetry = pd.read_csv(args.telemetry)
    telemetry["timestamp"] = pd.to_datetime(telemetry["timestamp"])

    engine = create_engine(args.dsn)
    with engine.begin() as conn:
        insert_astronauts(conn, telemetry)
        insert_sessions(conn, telemetry)
        insert_telemetry(conn, telemetry)
        compute_baselines(conn, telemetry)
        if args.events:
            insert_events(conn, pd.read_csv(args.events))

    print(f"OK: {len(telemetry)} filas de telemetría cargadas.")


if __name__ == "__main__":
    main()
