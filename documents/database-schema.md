# Database Schema

## Overview
PostgreSQL 15 with TimescaleDB extension for time-series data optimization.

## Tables

### patients
```sql
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mrn VARCHAR(50) UNIQUE NOT NULL,  -- Medical Record Number
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    address JSONB,
    emergency_contact JSONB,
    primary_physician_id UUID,
    status VARCHAR(20) DEFAULT 'active',  -- active, inactive, discharged
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_patients_mrn ON patients(mrn);
CREATE INDEX idx_patients_status ON patients(status);
CREATE INDEX idx_patients_physician ON patients(primary_physician_id);
```

### measurements
```sql
CREATE TABLE measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    timestamp TIMESTAMPTZ NOT NULL,
    heart_rate INTEGER,
    blood_pressure_systolic INTEGER,
    blood_pressure_diastolic INTEGER,
    oxygen_saturation INTEGER,
    temperature DECIMAL(4,1),
    respiratory_rate INTEGER,
    device_id VARCHAR(100),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Convert to TimescaleDB hypertable
SELECT create_hypertable('measurements', 'timestamp', chunk_time_interval => INTERVAL '1 day');

CREATE INDEX idx_measurements_patient_time ON measurements(patient_id, timestamp DESC);
CREATE INDEX idx_measurements_device ON measurements(device_id);
CREATE INDEX idx_measurements_timestamp ON measurements(timestamp DESC);
```

### alerts
```sql
CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    measurement_id UUID REFERENCES measurements(id) ON DELETE SET NULL,
    type VARCHAR(50) NOT NULL,  -- threshold_exceeded, anomaly_detected, prediction_risk, device_offline
    severity VARCHAR(20) NOT NULL,  -- critical, high, medium, low
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    value DECIMAL(10,2),
    threshold DECIMAL(10,2),
    metadata JSONB DEFAULT '{}',
    acknowledged BOOLEAN DEFAULT FALSE,
    acknowledged_by UUID,
    acknowledged_at TIMESTAMPTZ,
    resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_alerts_patient ON alerts(patient_id);
CREATE INDEX idx_alerts_severity ON alerts(severity);
CREATE INDEX idx_alerts_acknowledged ON alerts(acknowledged) WHERE acknowledged = FALSE;
CREATE INDEX idx_alerts_created ON alerts(created_at DESC);
```

### predictions
```sql
CREATE TABLE predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    model_version VARCHAR(50) NOT NULL,
    prediction_timestamp TIMESTAMPTZ NOT NULL,
    horizon_hours INTEGER NOT NULL,
    risk_score DECIMAL(5,4) NOT NULL,  -- 0.0 to 1.0
    risk_level VARCHAR(20) NOT NULL,  -- critical, high, medium, low
    predicted_vitals JSONB NOT NULL,
    feature_importance JSONB,
    recommendations JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_predictions_patient_time ON predictions(patient_id, prediction_timestamp DESC);
CREATE INDEX idx_predictions_risk ON predictions(risk_level);
```

### devices
```sql
CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES patients(id) ON DELETE SET NULL,
    device_type VARCHAR(50) NOT NULL,  -- wearable, bedside, implantable
    serial_number VARCHAR(100) UNIQUE NOT NULL,
    firmware_version VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active',  -- active, inactive, maintenance, error
    last_seen TIMESTAMPTZ,
    configuration JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_devices_patient ON devices(patient_id);
CREATE INDEX idx_devices_status ON devices(status);
```

### users (for authentication)
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(200),
    role VARCHAR(50) NOT NULL,  -- admin, physician, nurse, technician, patient
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
```

### user_patients (many-to-many)
```sql
CREATE TABLE user_patients (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    assigned_by UUID REFERENCES users(id),
    PRIMARY KEY (user_id, patient_id)
);
```

### audit_logs
```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
```

## Views

### patient_latest_vitals
```sql
CREATE VIEW patient_latest_vitals AS
SELECT DISTINCT ON (m.patient_id)
    m.patient_id,
    m.timestamp,
    m.heart_rate,
    m.blood_pressure_systolic,
    m.blood_pressure_diastolic,
    m.oxygen_saturation,
    m.temperature,
    m.respiratory_rate
FROM measurements m
ORDER BY m.patient_id, m.timestamp DESC;
```

### patient_risk_summary
```sql
CREATE VIEW patient_risk_summary AS
SELECT
    p.id AS patient_id,
    p.mrn,
    p.first_name,
    p.last_name,
    l.heart_rate,
    l.blood_pressure_systolic,
    l.blood_pressure_diastolic,
    l.oxygen_saturation,
    l.temperature,
    pr.risk_score,
    pr.risk_level,
    pr.prediction_timestamp,
    COUNT(a.id) FILTER (WHERE a.acknowledged = FALSE) AS unacknowledged_alerts
FROM patients p
LEFT JOIN patient_latest_vitals l ON p.id = l.patient_id
LEFT JOIN LATERAL (
    SELECT risk_score, risk_level, prediction_timestamp
    FROM predictions
    WHERE patient_id = p.id
    ORDER BY prediction_timestamp DESC
    LIMIT 1
) pr ON TRUE
LEFT JOIN alerts a ON p.id = a.patient_id AND a.acknowledged = FALSE
WHERE p.status = 'active'
GROUP BY p.id, l.heart_rate, l.blood_pressure_systolic, l.blood_pressure_diastolic,
         l.oxygen_saturation, l.temperature, pr.risk_score, pr.risk_level, pr.prediction_timestamp;
```

## Functions

### update_updated_at_column
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';
```

### Triggers
```sql
CREATE TRIGGER update_patients_updated_at
    BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_devices_updated_at
    BEFORE UPDATE ON devices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Partitioning Strategy

- **measurements**: Partitioned by day (TimescaleDB hypertable)
- **alerts**: Partitioned by month (native partitioning)
- **audit_logs**: Partitioned by month

## Retention Policies

```sql
-- Measurements: Keep 2 years raw, 5 years aggregated
-- Alerts: Keep 3 years
-- Predictions: Keep 1 year
-- Audit logs: Keep 7 years (compliance)
```

## Sample Data

See `database/seed.sql` for sample data insertion scripts.