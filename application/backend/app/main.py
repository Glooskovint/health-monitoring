from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text

from .config import settings
from .database import engine
from .routers import alerts, astronauts, auth, overview, predictions, sessions
from .security import get_current_user

app = FastAPI(
    title=settings.api_title,
    version=settings.api_version,
    description=(
        "API de monitoreo y predicción de eventos médicos para astronautas en EVA. "
        "Herramienta de soporte a la decisión; no reemplaza el criterio médico."
    ),
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api")

for router in (astronauts.router, sessions.router, predictions.router, alerts.router, overview.router):
    app.include_router(router, prefix="/api", dependencies=[Depends(get_current_user)])


@app.get("/", tags=["meta"])
def root():
    return {
        "service": settings.api_title,
        "version": settings.api_version,
        "docs": "/docs",
        "health": "/health",
    }


@app.get("/health", tags=["meta"])
def health():
    database_ok = True
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
    except Exception:  # noqa: BLE001 - reportamos estado, no fallamos
        database_ok = False
    return {"status": "ok" if database_ok else "degraded", "database": database_ok}
