# Health Monitoring System

A comprehensive health monitoring application with real-time patient monitoring, predictive analytics, and system status dashboard.

## Project Structure

```
health-monitoring/
├── backend/          # Python FastAPI backend
├── frontend/         # React frontend
├── database/         # Database initialization and seed scripts
├── deployment/       # Deployment configurations
├── docs/             # Documentation
├── scripts/          # Utility scripts
└── data/             # Data directories
```

## Quick Start

```bash
# Using Docker Compose
docker-compose up -d

# Or using Makefile
make up
```

## Services

- **Backend API**: http://localhost:8000
- **Frontend**: http://localhost:3000
- **API Docs**: http://localhost:8000/docs

## Documentation

- [Architecture](docs/architecture.md)
- [API Contract](docs/api-contract.md)
- [Database Schema](docs/database-schema.md)
- [User Stories](docs/user-stories.md)
- [Demo Flow](docs/demo-flow.md)