from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import func, select
from sqlalchemy.orm import Session as DbSession

from ..database import get_db
from ..models import Alert, AlertStatus, Astronaut, Prediction, Session
from ..schemas import AstronautOverview, OverviewResponse

router = APIRouter(prefix="/overview", tags=["overview"])


@router.get("", response_model=OverviewResponse)
def get_overview(db: DbSession = Depends(get_db)):
    astronauts = db.scalars(select(Astronaut).order_by(Astronaut.astronaut_id)).all()
    items: list[AstronautOverview] = []

    for astronaut in astronauts:
        session = db.scalars(
            select(Session)
            .where(Session.astronaut_id == astronaut.astronaut_id)
            .order_by(Session.started_at.desc())
        ).first()

        latest_prediction = None
        open_alerts = 0
        if session:
            latest_prediction = db.scalars(
                select(Prediction)
                .where(Prediction.session_id == session.session_id)
                .order_by(Prediction.minute.desc())
            ).first()
            open_alerts = db.scalar(
                select(func.count(Alert.alert_id)).where(
                    Alert.session_id == session.session_id,
                    Alert.status == AlertStatus.open,
                )
            ) or 0

        items.append(
            AstronautOverview(
                astronaut_id=astronaut.astronaut_id,
                full_name=astronaut.full_name,
                session_id=session.session_id if session else None,
                latest_minute=latest_prediction.minute if latest_prediction else None,
                risk_score=float(latest_prediction.risk_score) if latest_prediction else None,
                level=latest_prediction.level if latest_prediction else None,
                open_alerts=int(open_alerts),
            )
        )

    return OverviewResponse(
        generated_at=datetime.now(timezone.utc),
        astronauts=items,
    )
