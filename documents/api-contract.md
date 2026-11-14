# API Contract

## Base URL
```
Development: http://localhost:8000
Production: https://api.health-monitoring.com
```

## Authentication
All protected endpoints require Bearer token:
```
Authorization: Bearer <access_token>
```

## Endpoints

### Health Check
```
GET /health
Response: 200 OK
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0"
}
```

### Monitoring

#### Get Patient Measurements
```
GET /api/v1/monitoring/patients/{patient_id}/measurements
Query Params:
  - start_time: ISO8601 (optional)
  - end_time: ISO8601 (optional)
  - limit: integer (default: 100)
  - offset: integer (default: 0)

Response: 200 OK
{
  "measurements": [
    {
      "id": "uuid",
      "patient_id": "uuid",
      "timestamp": "2024-01-15T10:30:00Z",
      "heart_rate": 72,
      "blood_pressure_systolic": 120,
      "blood_pressure_diastolic": 80,
      "oxygen_saturation": 98,
      "temperature": 36.5,
      "respiratory_rate": 16
    }
  ],
  "total": 150,
  "page": 1,
  "page_size": 100
}
```

#### Get Latest Measurement
```
GET /api/v1/monitoring/patients/{patient_id}/latest
Response: 200 OK
{
  "id": "uuid",
  "patient_id": "uuid",
  "timestamp": "2024-01-15T10:30:00Z",
  "heart_rate": 72,
  "blood_pressure_systolic": 120,
  "blood_pressure_diastolic": 80,
  "oxygen_saturation": 98,
  "temperature": 36.5,
  "respiratory_rate": 16
}
```

#### Create Measurement
```
POST /api/v1/monitoring/measurements
Body:
{
  "patient_id": "uuid",
  "timestamp": "2024-01-15T10:30:00Z",
  "heart_rate": 72,
  "blood_pressure_systolic": 120,
  "blood_pressure_diastolic": 80,
  "oxygen_saturation": 98,
  "temperature": 36.5,
  "respiratory_rate": 16
}

Response: 201 Created
```

### Predictions

#### Get Health Prediction
```
GET /api/v1/predictions/patients/{patient_id}
Query Params:
  - horizon_hours: integer (default: 24)

Response: 200 OK
{
  "patient_id": "uuid",
  "prediction_timestamp": "2024-01-15T10:30:00Z",
  "horizon_hours": 24,
  "risk_score": 0.23,
  "risk_level": "low",
  "predicted_vitals": {
    "heart_rate": {"mean": 75, "std": 5},
    "blood_pressure_systolic": {"mean": 122, "std": 8},
    "oxygen_saturation": {"mean": 97, "std": 1}
  },
  "recommendations": [
    "Continue current monitoring schedule",
    "No immediate intervention required"
  ]
}
```

#### Get Risk Trends
```
GET /api/v1/predictions/patients/{patient_id}/trends
Query Params:
  - days: integer (default: 7)

Response: 200 OK
{
  "patient_id": "uuid",
  "trends": [
    {
      "date": "2024-01-09",
      "risk_score": 0.15,
      "risk_level": "low"
    }
  ]
}
```

### System Status

#### Get System Status
```
GET /api/v1/system/status
Response: 200 OK
{
  "status": "operational",
  "services": {
    "database": "healthy",
    "redis": "healthy",
    "ml_model": "healthy",
    "api": "healthy"
  },
  "metrics": {
    "active_patients": 150,
    "measurements_per_minute": 45,
    "avg_response_time_ms": 120,
    "error_rate": 0.001
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

#### Get Service Health
```
GET /api/v1/system/services/{service_name}
Response: 200 OK
{
  "service": "database",
  "status": "healthy",
  "latency_ms": 5,
  "last_check": "2024-01-15T10:30:00Z",
  "details": {
    "connections_active": 10,
    "connections_idle": 5
  }
}
```

### Alerts

#### Get Active Alerts
```
GET /api/v1/alerts
Query Params:
  - patient_id: uuid (optional)
  - severity: critical|high|medium|low (optional)
  - acknowledged: boolean (optional)

Response: 200 OK
{
  "alerts": [
    {
      "id": "uuid",
      "patient_id": "uuid",
      "type": "threshold_exceeded",
      "severity": "high",
      "message": "Heart rate exceeded threshold: 125 bpm",
      "value": 125,
      "threshold": 120,
      "created_at": "2024-01-15T10:30:00Z",
      "acknowledged": false
    }
  ]
}
```

#### Acknowledge Alert
```
POST /api/v1/alerts/{alert_id}/acknowledge
Body:
{
  "acknowledged_by": "user_id",
  "notes": "Patient stable, monitoring"
}

Response: 200 OK
```

## WebSocket Endpoints

### Real-time Measurements
```
WS /ws/measurements/{patient_id}
Messages:
  - type: "measurement"
    payload: Measurement object
  - type: "alert"
    payload: Alert object
```

### System Events
```
WS /ws/system
Messages:
  - type: "status_change"
    payload: SystemStatus object
  - type: "service_health"
    payload: ServiceHealth object
```

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid input data",
  "errors": [
    {
      "field": "heart_rate",
      "message": "Value must be between 30 and 200"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "detail": "Invalid or expired token"
}
```

### 404 Not Found
```json
{
  "detail": "Patient not found"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error",
  "request_id": "uuid"
}
```

## Rate Limiting
- 100 requests/minute per IP for unauthenticated endpoints
- 1000 requests/minute per user for authenticated endpoints
- WebSocket: 50 connections per IP

## Versioning
- URL versioning: `/api/v1/`
- Header versioning: `Accept: application/vnd.health-monitoring.v1+json`