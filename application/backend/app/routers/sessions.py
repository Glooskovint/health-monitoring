from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session as DbSession

from ..database import get_db
from ..models import Baseline, MedicalEvent, Session, Telemetry
from ..schemas import BaselineRead, MedicalEventRead, SessionRead, TelemetryRead

router = APIRouter(prefix="/sessions", tags=["sessions"])


def _get_session(session_id: str, db: DbSession) -> Session:
    session = db.get(Session, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Sesión no encontrada")
    return session


@router.get("", response_model=list[SessionRead])
def list_sessions(
    astronaut_id: str | None = Query(default=None),
    db: DbSession = Depends(get_db),
):
    query = select(Session).order_by(Session.started_at.desc())
    if astronaut_id:
        query = query.where(Session.astronaut_id == astronaut_id)
    return db.scalars(query).all()


@router.get("/{session_id}", response_model=SessionRead)
def get_session(session_id: str, db: DbSession = Depends(get_db)):
    return _get_session(session_id, db)


@router.get("/{session_id}/telemetry", response_model=list[TelemetryRead])
def get_telemetry(
    session_id: str,
    limit: int = Query(default=2000, ge=1, le=10000),
    db: DbSession = Depends(get_db),
):
    _get_session(session_id, db)
    query = (
        select(Telemetry)
        .where(Telemetry.session_id == session_id)
        .order_by(Telemetry.minute)
        .limit(limit)
    )
    return db.scalars(query).all()


@router.get("/{session_id}/baselines", response_model=list[BaselineRead])
def get_baselines(session_id: str, db: DbSession = Depends(get_db)):
    _get_session(session_id, db)
    return db.scalars(select(Baseline).where(Baseline.session_id == session_id)).all()


@router.get("/{session_id}/events", response_model=list[MedicalEventRead])
def get_events(session_id: str, db: DbSession = Depends(get_db)):
    _get_session(session_id, db)
    query = (
        select(MedicalEvent)
        .where(MedicalEvent.session_id == session_id)
        .order_by(MedicalEvent.onset_minute)
    )
    return db.scalars(query).all()
