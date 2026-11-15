from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session as DbSession

from ..database import get_db
from ..models import Alert, AlertAction, AlertStatus, User, UserRole
from ..schemas import AlertActionCreate, AlertActionRead, AlertRead
from ..security import require_roles

router = APIRouter(prefix="/alerts", tags=["alerts"])

_STATUS_BY_ACTION = {
    "acknowledge": AlertStatus.acknowledged,
    "resolve": AlertStatus.resolved,
    "dismiss": AlertStatus.dismissed,
}


@router.get("", response_model=list[AlertRead])
def list_alerts(
    status: AlertStatus | None = Query(default=None),
    session_id: str | None = Query(default=None),
    limit: int = Query(default=100, ge=1, le=1000),
    db: DbSession = Depends(get_db),
):
    query = select(Alert).order_by(Alert.created_at.desc()).limit(limit)
    if status:
        query = query.where(Alert.status == status)
    if session_id:
        query = query.where(Alert.session_id == session_id)
    return db.scalars(query).all()


@router.get("/{alert_id}", response_model=AlertRead)
def get_alert(alert_id: int, db: DbSession = Depends(get_db)):
    alert = db.get(Alert, alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alerta no encontrada")
    return alert


@router.post("/{alert_id}/actions", response_model=AlertActionRead, status_code=201)
def register_action(
    alert_id: int,
    payload: AlertActionCreate,
    current_user: User = Depends(
        require_roles(UserRole.flight_surgeon, UserRole.mission_control, UserRole.researcher)
    ),
    db: DbSession = Depends(get_db),
):
    alert = db.get(Alert, alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alerta no encontrada")

    new_status = _STATUS_BY_ACTION.get(payload.action.lower())
    if new_status:
        alert.status = new_status
        alert.resolved_at = (
            datetime.now(timezone.utc)
            if new_status in (AlertStatus.resolved, AlertStatus.dismissed)
            else None
        )

    action = AlertAction(
        alert_id=alert_id,
        user_id=current_user.user_id,
        action=payload.action,
        comment=payload.comment,
    )
    db.add(action)
    db.commit()
    db.refresh(action)
    return action
