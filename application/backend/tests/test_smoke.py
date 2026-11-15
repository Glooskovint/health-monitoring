from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["service"]


def test_data_routes_require_auth():
    response = client.get("/api/overview")
    assert response.status_code == 401


def test_schema_tables_registered():
    from app.models import Base

    expected = {
        "astronauts",
        "users",
        "sessions",
        "telemetry",
        "baselines",
        "event_types",
        "medical_events",
        "models",
        "model_metrics",
        "predictions",
        "alerts",
        "alert_actions",
    }
    assert expected.issubset(set(Base.metadata.tables.keys()))
