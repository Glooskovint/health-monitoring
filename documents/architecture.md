# Architecture Overview

## System Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│    Nginx    │────▶│  Frontend   │
│  (Browser)  │     │  (Reverse   │     │  (React)    │
└─────────────┘     │   Proxy)    │     └─────────────┘
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐     ┌─────────────┐
                    │   Backend   │────▶│  Database   │
                    │  (FastAPI)  │     │ (PostgreSQL)│
                    └──────┬──────┘     └─────────────┘
                           │
                    ┌──────▼──────┐
                    │    Redis    │
                    │  (Cache/    │
                    │   Queue)    │
                    └─────────────┘
```

## Components

### Frontend (React + Vite)
- **Framework**: React 18 with Vite
- **State Management**: React Context + Hooks
- **UI Library**: Tailwind CSS
- **Charts**: Chart.js / Recharts
- **Real-time**: WebSocket / Server-Sent Events

### Backend (FastAPI)
- **Framework**: FastAPI (Python 3.11+)
- **ORM**: SQLAlchemy 2.0 with async support
- **Validation**: Pydantic v2
- **Authentication**: JWT with OAuth2
- **Background Tasks**: Celery with Redis
- **ML Integration**: scikit-learn / ONNX Runtime

### Database (PostgreSQL 15)
- **Primary**: Patient records, measurements, alerts
- **Extensions**: TimescaleDB for time-series data
- **Connection Pooling**: PgBouncer

### Cache/Queue (Redis 7)
- **Caching**: Session data, computed metrics
- **Queue**: Celery task queue for ML inference
- **Pub/Sub**: Real-time notifications

## Data Flow

1. **Ingestion**: IoT devices → API → Database
2. **Processing**: Background workers → ML models → Predictions
3. **Alerting**: Threshold checks → Notifications
4. **Visualization**: Frontend ↔ API ↔ Database

## Security

- HTTPS/TLS termination at Nginx
- JWT-based authentication
- Role-based access control (RBAC)
- Input validation with Pydantic
- Rate limiting
- CORS configuration

## Scalability

- Horizontal scaling via Docker Swarm / Kubernetes
- Database read replicas
- Redis clustering
- CDN for static assets