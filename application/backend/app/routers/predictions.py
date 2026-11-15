from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session as DbSession

from ..database import get_db
from ..models import (
    Alert,
    AlertLevel as AlertLevelEnum,
    Baseline,
    Model,
    Prediction,
    Session,
    Telemetry,
    User,
    UserRole,
)
from ..schemas import PredictionRead, PredictRequest, PredictResponse
from ..security import require_roles
from ..services.alerting import build_summary, recommend
from ..services.predictor import HeuristicRiskPredictor

router = APIRouter(prefix="/predictions", tags=["predictions"])


def _active_model(db: DbSession) -> Model:
    model = db.scalars(select(Model).where(Model.is_active.is_(True))).first()
    if model is None:
        model = Model(
            name="eva-risk-mvp",
            version="0.1.0",
            algorithm="heuristic-sigma",
            horizon_minutes=30,
            is_active=True,
        )
        db.add(model)
        db.flush()
    return model


@router.get("/{session_id}", response_model=list[PredictionRead])
def list_predictions(
    session_id: str,
    limit: int = Query(default=200, ge=1, le=2000),
    db: DbSession = Depends(get_db),
):
    query = (
        select(Prediction)
        .where(Prediction.session_id == session_id)
        .order_by(Prediction.minute.desc())
        .limit(limit)
    )
    return db.scalars(query).all()


@router.post("/{session_id}/run", response_model=PredictResponse)
def run_prediction(
    session_id: str,
    payload: PredictRequest,
    _current_user: User = Depends(
        require_roles(UserRole.flight_surgeon, UserRole.mission_control, UserRole.researcher)
    ),
    db: DbSession = Depends(get_db),
):
    session = db.get(Session, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Sesión no encontrada")

    telemetry = db.scalars(
        select(Telemetry).where(Telemetry.session_id == session_id).order_by(Telemetry.minute)
    ).all()
    if not telemetry:
        raise HTTPException(status_code=400, detail="Sesión sin telemetría")

    baseline_rows = db.scalars(select(Baseline).where(Baseline.session_id == session_id)).all()
    baselines = {row.variable: (float(row.mean), float(row.std)) for row in baseline_rows}

    predictor = HeuristicRiskPredictor(payload.horizon_minutes)
    result = predictor.predict(telemetry, baselines, payload.horizon_minutes)
    if result is None:
        raise HTTPException(status_code=400, detail="No se pudo calcular el riesgo")

    model = _active_model(db)
    level_enum = AlertLevelEnum(result.level)

    prediction = db.scalars(
        select(Prediction).where(
            Prediction.session_id == session_id,
            Prediction.minute == result.minute,
            Prediction.model_id == model.model_id,
        )
    ).first()

    if prediction is None:
        prediction = Prediction(
            session_id=session_id,
            minute=result.minute,
            model_id=model.model_id,
            horizon_minutes=payload.horizon_minutes,
            risk_score=result.risk_score,
            level=level_enum,
            hypothesis_code=result.hypothesis_code,
            top_features=result.top_features,
        )
        db.add(prediction)
    else:
        prediction.risk_score = result.risk_score
        prediction.level = level_enum
        prediction.hypothesis_code = result.hypothesis_code
        prediction.top_features = result.top_features
        prediction.horizon_minutes = payload.horizon_minutes
    db.flush()

    summary = build_summary(result, session.astronaut_id)
    action = recommend(result)
    alert_id = None

    if result.level != "surveillance":
        alert = db.scalars(
            select(Alert).where(Alert.prediction_id == prediction.prediction_id)
        ).first()
        if alert is None:
            alert = Alert(
                prediction_id=prediction.prediction_id,
                session_id=session_id,
                level=level_enum,
                summary=summary,
                recommended_action=action,
            )
            db.add(alert)
            db.flush()
        alert_id = alert.alert_id

    db.commit()
    db.refresh(prediction)

    return PredictResponse(
        session_id=session_id,
        minute=result.minute,
        horizon_minutes=payload.horizon_minutes,
        risk_score=result.risk_score,
        level=level_enum,
        hypothesis_code=result.hypothesis_code,
        top_features=result.top_features,
        prediction_id=prediction.prediction_id,
        alert_id=alert_id,
        summary=summary,
        recommended_action=action,
    )
