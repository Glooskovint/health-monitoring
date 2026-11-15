from __future__ import annotations

from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field

from .models import AlertLevel, AlertStatus, UserRole


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


# ----------------------------- Astronautas ----------------------------------
class AstronautRead(ORMModel):
    astronaut_id: str
    full_name: str
    birth_date: Optional[date] = None
    email: Optional[str] = None
    active: bool
    created_at: datetime


class AstronautCreate(BaseModel):
    astronaut_id: str = Field(min_length=1, max_length=20)
    full_name: str = Field(min_length=1, max_length=120)
    birth_date: Optional[date] = None
    email: Optional[str] = None


# ------------------------------- Sesiones ------------------------------------
class SessionRead(ORMModel):
    session_id: str
    astronaut_id: str
    started_at: datetime
    ended_at: Optional[datetime] = None
    environment: dict
    created_at: datetime


# ------------------------------ Telemetría -----------------------------------
class TelemetryRead(ORMModel):
    telemetry_id: int
    session_id: str
    minute: int
    recorded_at: datetime
    hr_bpm: Optional[float] = None
    spo2_pct: Optional[float] = None
    resp_rate_bpm: Optional[float] = None
    core_temp_c: Optional[float] = None
    skin_temp_c: Optional[float] = None
    eeg_theta_beta_ratio: Optional[float] = None
    eeg_alpha_uv2: Optional[float] = None
    eeg_quality: Optional[float] = None
    emg_rms_uv: Optional[float] = None
    emg_mdf_hz: Optional[float] = None
    rad_dose_rate_usv_h: Optional[float] = None
    rad_cum_dose_msv: Optional[float] = None


class BaselineRead(ORMModel):
    baseline_id: int
    session_id: str
    variable: str
    window_minutes: int
    mean: float
    std: float


# ------------------------------- Eventos -------------------------------------
class EventTypeRead(ORMModel):
    code: str
    name: str
    category: str
    description: Optional[str] = None


class MedicalEventRead(ORMModel):
    event_id: int
    session_id: str
    event_type_code: str
    onset_minute: int
    end_minute: Optional[int] = None
    notes: Optional[str] = None


# ------------------------------ Predicciones ---------------------------------
class TopFeature(BaseModel):
    variable: str
    sigma: float
    direction: str
    score: float


class PredictionRead(ORMModel):
    prediction_id: int
    session_id: str
    minute: int
    model_id: int
    horizon_minutes: int
    risk_score: float
    level: AlertLevel
    hypothesis_code: Optional[str] = None
    top_features: list[TopFeature] = Field(default_factory=list)
    created_at: datetime


class PredictRequest(BaseModel):
    horizon_minutes: int = Field(default=30, ge=5, le=120)


class PredictResponse(BaseModel):
    session_id: str
    minute: int
    horizon_minutes: int
    risk_score: float
    level: AlertLevel
    hypothesis_code: Optional[str] = None
    top_features: list[TopFeature]
    prediction_id: Optional[int] = None
    alert_id: Optional[int] = None
    summary: Optional[str] = None
    recommended_action: Optional[str] = None


# -------------------------------- Alertas ------------------------------------
class AlertRead(ORMModel):
    alert_id: int
    prediction_id: int
    session_id: str
    level: AlertLevel
    summary: str
    recommended_action: Optional[str] = None
    status: AlertStatus
    created_at: datetime
    resolved_at: Optional[datetime] = None


class AlertActionCreate(BaseModel):
    action: str = Field(min_length=2, max_length=40)
    comment: Optional[str] = None


class AlertActionRead(ORMModel):
    action_id: int
    alert_id: int
    user_id: int
    action: str
    comment: Optional[str] = None
    created_at: datetime


# ------------------------------- Overview ------------------------------------
class AstronautOverview(BaseModel):
    astronaut_id: str
    full_name: str
    session_id: Optional[str] = None
    latest_minute: Optional[int] = None
    risk_score: Optional[float] = None
    level: Optional[AlertLevel] = None
    open_alerts: int = 0


class OverviewResponse(BaseModel):
    generated_at: datetime
    astronauts: list[AstronautOverview]


# -------------------------------- Usuarios -----------------------------------
class UserRead(ORMModel):
    user_id: int
    full_name: str
    email: str
    role: UserRole
    astronaut_id: Optional[str] = None
    is_active: bool
    last_login_at: Optional[datetime] = None


# -------------------------------- Autenticación -------------------------------
class LoginRequest(BaseModel):
    email: str = Field(min_length=3, max_length=160)
    password: str = Field(min_length=1, max_length=128)


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserRead
