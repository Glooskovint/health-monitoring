from __future__ import annotations

import enum
from datetime import date, datetime
from typing import Optional

from sqlalchemy import (
    Boolean,
    Date,
    DateTime,
    Enum,
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.sql import func


class Base(DeclarativeBase):
    pass


class UserRole(str, enum.Enum):
    astronaut = "astronaut"
    flight_surgeon = "flight_surgeon"
    mission_control = "mission_control"
    researcher = "researcher"


class AlertLevel(str, enum.Enum):
    surveillance = "surveillance"
    alert = "alert"
    critical = "critical"


class AlertStatus(str, enum.Enum):
    open = "open"
    acknowledged = "acknowledged"
    resolved = "resolved"
    dismissed = "dismissed"


class Astronaut(Base):
    __tablename__ = "astronauts"

    astronaut_id: Mapped[str] = mapped_column(String(20), primary_key=True)
    full_name: Mapped[str] = mapped_column(String(120), nullable=False)
    birth_date: Mapped[Optional[date]] = mapped_column(Date)
    email: Mapped[Optional[str]] = mapped_column(String(160), unique=True)
    active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    sessions: Mapped[list[Session]] = relationship(back_populates="astronaut", cascade="all, delete-orphan")
    users: Mapped[list[User]] = relationship(back_populates="astronaut")


class User(Base):
    __tablename__ = "users"

    user_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    full_name: Mapped[str] = mapped_column(String(120), nullable=False)
    email: Mapped[str] = mapped_column(String(160), unique=True, nullable=False)
    role: Mapped[UserRole] = mapped_column(Enum(UserRole, name="user_role"), nullable=False)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    astronaut_id: Mapped[Optional[str]] = mapped_column(ForeignKey("astronauts.astronaut_id", ondelete="SET NULL"))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    last_login_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    astronaut: Mapped[Optional[Astronaut]] = relationship(back_populates="users")
    alert_actions: Mapped[list[AlertAction]] = relationship(back_populates="user")


class Session(Base):
    __tablename__ = "sessions"

    session_id: Mapped[str] = mapped_column(String(40), primary_key=True)
    astronaut_id: Mapped[str] = mapped_column(
        ForeignKey("astronauts.astronaut_id", ondelete="CASCADE"), nullable=False
    )
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    ended_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    environment: Mapped[dict] = mapped_column(JSONB, default=dict, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    astronaut: Mapped[Astronaut] = relationship(back_populates="sessions")
    telemetry: Mapped[list[Telemetry]] = relationship(back_populates="session", cascade="all, delete-orphan")
    baselines: Mapped[list[Baseline]] = relationship(back_populates="session", cascade="all, delete-orphan")
    events: Mapped[list[MedicalEvent]] = relationship(back_populates="session", cascade="all, delete-orphan")
    predictions: Mapped[list[Prediction]] = relationship(back_populates="session", cascade="all, delete-orphan")
    alerts: Mapped[list[Alert]] = relationship(back_populates="session", cascade="all, delete-orphan")


class Telemetry(Base):
    __tablename__ = "telemetry"

    telemetry_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    session_id: Mapped[str] = mapped_column(
        ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False
    )
    minute: Mapped[int] = mapped_column(Integer, nullable=False)
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    hr_bpm: Mapped[Optional[float]] = mapped_column(Numeric(6, 2))
    spo2_pct: Mapped[Optional[float]] = mapped_column(Numeric(5, 2))
    resp_rate_bpm: Mapped[Optional[float]] = mapped_column(Numeric(5, 2))
    core_temp_c: Mapped[Optional[float]] = mapped_column(Numeric(5, 2))
    skin_temp_c: Mapped[Optional[float]] = mapped_column(Numeric(5, 2))
    eeg_theta_beta_ratio: Mapped[Optional[float]] = mapped_column(Numeric(7, 4))
    eeg_alpha_uv2: Mapped[Optional[float]] = mapped_column(Numeric(8, 3))
    eeg_quality: Mapped[Optional[float]] = mapped_column(Numeric(5, 4))
    emg_rms_uv: Mapped[Optional[float]] = mapped_column(Numeric(8, 3))
    emg_mdf_hz: Mapped[Optional[float]] = mapped_column(Numeric(8, 3))
    rad_dose_rate_usv_h: Mapped[Optional[float]] = mapped_column(Numeric(10, 4))
    rad_cum_dose_msv: Mapped[Optional[float]] = mapped_column(Numeric(10, 4))

    session: Mapped[Session] = relationship(back_populates="telemetry")


class Baseline(Base):
    __tablename__ = "baselines"

    baseline_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    session_id: Mapped[str] = mapped_column(
        ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False
    )
    variable: Mapped[str] = mapped_column(String(40), nullable=False)
    window_minutes: Mapped[int] = mapped_column(Integer, default=30, nullable=False)
    mean: Mapped[float] = mapped_column(Numeric(12, 5), nullable=False)
    std: Mapped[float] = mapped_column(Numeric(12, 5), nullable=False)
    computed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    session: Mapped[Session] = relationship(back_populates="baselines")


class EventType(Base):
    __tablename__ = "event_types"

    code: Mapped[str] = mapped_column(String(40), primary_key=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    category: Mapped[str] = mapped_column(String(40), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text)

    events: Mapped[list[MedicalEvent]] = relationship(back_populates="event_type")
    predictions: Mapped[list[Prediction]] = relationship(back_populates="hypothesis")


class MedicalEvent(Base):
    __tablename__ = "medical_events"

    event_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    session_id: Mapped[str] = mapped_column(
        ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False
    )
    event_type_code: Mapped[str] = mapped_column(ForeignKey("event_types.code"), nullable=False)
    onset_minute: Mapped[int] = mapped_column(Integer, nullable=False)
    end_minute: Mapped[Optional[int]] = mapped_column(Integer)
    notes: Mapped[Optional[str]] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    session: Mapped[Session] = relationship(back_populates="events")
    event_type: Mapped[EventType] = relationship(back_populates="events")


class Model(Base):
    __tablename__ = "models"

    model_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    version: Mapped[str] = mapped_column(String(40), nullable=False)
    algorithm: Mapped[str] = mapped_column(String(120), nullable=False)
    horizon_minutes: Mapped[int] = mapped_column(Integer, default=30, nullable=False)
    hyperparameters: Mapped[dict] = mapped_column(JSONB, default=dict, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    trained_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    metrics: Mapped[list[ModelMetric]] = relationship(back_populates="model", cascade="all, delete-orphan")
    predictions: Mapped[list[Prediction]] = relationship(back_populates="model")


class ModelMetric(Base):
    __tablename__ = "model_metrics"

    metric_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    model_id: Mapped[int] = mapped_column(
        ForeignKey("models.model_id", ondelete="CASCADE"), nullable=False
    )
    split: Mapped[str] = mapped_column(String(20), nullable=False)
    metric_name: Mapped[str] = mapped_column(String(60), nullable=False)
    value: Mapped[float] = mapped_column(Numeric(10, 5), nullable=False)
    computed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    model: Mapped[Model] = relationship(back_populates="metrics")


class Prediction(Base):
    __tablename__ = "predictions"

    prediction_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    session_id: Mapped[str] = mapped_column(
        ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False
    )
    minute: Mapped[int] = mapped_column(Integer, nullable=False)
    model_id: Mapped[int] = mapped_column(ForeignKey("models.model_id"), nullable=False)
    horizon_minutes: Mapped[int] = mapped_column(Integer, nullable=False)
    risk_score: Mapped[float] = mapped_column(Numeric(6, 5), nullable=False)
    level: Mapped[AlertLevel] = mapped_column(Enum(AlertLevel, name="alert_level"), nullable=False)
    hypothesis_code: Mapped[Optional[str]] = mapped_column(ForeignKey("event_types.code"))
    top_features: Mapped[list] = mapped_column(JSONB, default=list, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    session: Mapped[Session] = relationship(back_populates="predictions")
    model: Mapped[Model] = relationship(back_populates="predictions")
    hypothesis: Mapped[Optional[EventType]] = relationship(back_populates="predictions")
    alerts: Mapped[list[Alert]] = relationship(back_populates="prediction", cascade="all, delete-orphan")


class Alert(Base):
    __tablename__ = "alerts"

    alert_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    prediction_id: Mapped[int] = mapped_column(
        ForeignKey("predictions.prediction_id", ondelete="CASCADE"), nullable=False
    )
    session_id: Mapped[str] = mapped_column(
        ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=False
    )
    level: Mapped[AlertLevel] = mapped_column(Enum(AlertLevel, name="alert_level"), nullable=False)
    summary: Mapped[str] = mapped_column(Text, nullable=False)
    recommended_action: Mapped[Optional[str]] = mapped_column(Text)
    status: Mapped[AlertStatus] = mapped_column(
        Enum(AlertStatus, name="alert_status"), default=AlertStatus.open, nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    resolved_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))

    prediction: Mapped[Prediction] = relationship(back_populates="alerts")
    session: Mapped[Session] = relationship(back_populates="alerts")
    actions: Mapped[list[AlertAction]] = relationship(back_populates="alert", cascade="all, delete-orphan")


class AlertAction(Base):
    __tablename__ = "alert_actions"

    action_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    alert_id: Mapped[int] = mapped_column(
        ForeignKey("alerts.alert_id", ondelete="CASCADE"), nullable=False
    )
    user_id: Mapped[int] = mapped_column(ForeignKey("users.user_id"), nullable=False)
    action: Mapped[str] = mapped_column(String(40), nullable=False)
    comment: Mapped[Optional[str]] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    alert: Mapped[Alert] = relationship(back_populates="actions")
    user: Mapped[User] = relationship(back_populates="alert_actions")
