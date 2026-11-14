# Health Monitoring System

A comprehensive health monitoring application with real-time patient monitoring, predictive analytics, and system status dashboard.

## Project Structure

```
├── applications/       # Depelopment space
│   ├── backend/        # Python FastAPI backend
│   ├── database/       # Database initialization and seed scripts
│   └── frontend/       # React frontend
├── documents/          # Documentation
├── infrastructure/     # Complementary for deployment
│   ├── data/           # Data directories
│   ├── nginx/          # Deployment configurations
│   └── scripts/        # Utility scripts
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