from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session as DbSession

from ..database import get_db
from ..models import Astronaut
from ..schemas import AstronautRead

router = APIRouter(prefix="/astronauts", tags=["astronauts"])


@router.get("", response_model=list[AstronautRead])
def list_astronauts(db: DbSession = Depends(get_db)):
    return db.scalars(select(Astronaut).order_by(Astronaut.astronaut_id)).all()


@router.get("/{astronaut_id}", response_model=AstronautRead)
def get_astronaut(astronaut_id: str, db: DbSession = Depends(get_db)):
    astronaut = db.get(Astronaut, astronaut_id)
    if not astronaut:
        raise HTTPException(status_code=404, detail="Astronauta no encontrado")
    return astronaut
