# Demo Flow

## Overview
This document describes the end-to-end demo scenario for the Health Monitoring System.

## Prerequisites
- Docker and Docker Compose installed
- Ports 80, 443, 3000, 8000, 5432, 6379 available
- Sample data loaded (run `make seed`)

## Demo Scenario: "Patient John Doe - Post-Op Monitoring"

### 1. System Startup (30 seconds)
```bash
make up
```
- All services start: PostgreSQL, Redis, Backend, Frontend, Nginx
- Database initializes with schema and seed data
- ML model loads into memory

### 2. Access Dashboard (15 seconds)
1. Open browser to http://localhost
2. Login with demo credentials:
   - Email: `demo@health-monitoring.com`
   - Password: `demo123`
3. Dashboard loads with 5 demo patients

### 3. Patient Selection (10 seconds)
1. Click on "John Doe" (MRN: DEMO001)
2. Patient detail view opens showing:
   - Current vitals (updated in real-time)
   - 24-hour trend charts
   - Active alerts (if any)
   - Risk prediction panel

### 4. Real-time Monitoring (30 seconds)
1. Observe live vital signs updating every 10 seconds
2. Simulate vital sign change via mock data generator:
   ```bash
   make generate-mock-data
   ```
3. Watch charts update in real-time
4. Trigger threshold alert by setting HR > 120

### 5. Alert Demonstration (30 seconds)
1. Alert appears in top notification bar (red pulse animation)
2. Click alert to view details:
   - Type: "Threshold Exceeded"
   - Severity: "High"
   - Message: "Heart rate 125 bpm exceeds threshold 120 bpm"
   - Current value vs threshold comparison
3. Acknowledge alert:
   - Click "Acknowledge"
   - Add note: "Patient anxious, administering reassurance"
   - Alert moves to acknowledged list

### 6. Predictive Analytics (30 seconds)
1. Navigate to Predictions tab
2. View 24-hour risk prediction:
   - Risk Score: 0.23 (Low)
   - Risk Level: Low
   - Predicted vitals with confidence intervals
3. Click "Explain Prediction":
   - Feature importance bar chart
   - Top factors: "Recent HR variability", "Low SpO2 trend"
4. View 7-day risk trend chart

### 7. System Status Check (15 seconds)
1. Navigate to System Status page
2. Verify all services show "Healthy":
   - Database: 5ms latency, 10 active connections
   - Redis: 2ms latency, 50MB used
   - ML Model: v1.0.0, loaded 2h ago
   - API: 120ms avg response, 0.1% error rate
3. Check metrics:
   - Active patients: 5
   - Measurements/min: 45
   - Uptime: 99.9%

### 8. Device Management (15 seconds)
1. Navigate to Devices section
2. View connected devices for John Doe:
   - Wearable HR Monitor (SN: WHM-001) - Online
   - Bedside SpO2 (SN: BSM-042) - Online
3. Simulate device disconnect
4. Observe device offline alert generation

### 9. Historical Review (30 seconds)
1. Go back to Patient Dashboard
2. Select 7-day view on charts
3. Use date picker to review specific day
4. Export chart as PNG for handoff report
5. View alert history for the week

### 10. Multi-patient View (15 seconds)
1. Return to main dashboard
2. Enable "Compact View" for all patients
3. See at-a-glance status cards:
   - Green: Stable (3 patients)
   - Yellow: Watch (1 patient)
   - Red: Critical (1 patient)
4. Demonstrate quick navigation between patients

## Alternative Flows

### Flow A: New Patient Admission
1. Click "Add Patient"
2. Fill admission form (MRN, demographics, physician)
3. Assign monitoring device
4. Set custom thresholds
5. Verify appears on dashboard

### Flow B: Shift Handoff
1. Generate handoff report (PDF)
2. Includes: current vitals, active alerts, predictions, trends
3. Print or share digitally

### Flow C: Emergency Escalation
1. Critical alert triggers (e.g., SpO2 < 85%)
2. Auto-escalation after 2 minutes
3. Notification to on-call physician
4. Conference call button integration

## Demo Data

### Patients
| MRN | Name | Condition | Status |
|-----|------|-----------|--------|
| DEMO001 | John Doe | Post-op CABG | Stable |
| DEMO002 | Jane Smith | COPD Exacerbation | Watch |
| DEMO003 | Robert Johnson | Sepsis | Critical |
| DEMO004 | Maria Garcia | CHF | Stable |
| DEMO005 | James Wilson | Pneumonia | Watch |

### Devices
- 2-3 devices per patient
- Mixed types: wearable, bedside, implantable
- Simulated connectivity issues

### Measurements
- 1 measurement per 10 seconds per patient
- Realistic vital sign patterns
- Programmed anomalies for demo

### Alerts
- 3-5 active alerts at any time
- Mix of severities
- Some acknowledged, some pending

### Predictions
- Updated every 15 minutes
- Risk scores vary by patient condition
- Model explanations available

## Troubleshooting

### Dashboard not loading
```bash
make logs
# Check frontend container logs
```

### No real-time updates
```bash
# Check WebSocket connection in browser dev tools
# Verify backend WebSocket endpoint
```

### Alerts not triggering
```bash
# Check threshold configuration
# Verify measurement ingestion
make backend-shell
python -c "from app.services.monitoring_service import check_thresholds; check_thresholds()"
```

### Predictions not showing
```bash
# Check ML model loaded
make backend-shell
python -c "from app.ml.inference import load_model; print(load_model())"
```

## Reset Demo
```bash
make down
make clean
make up
make seed
```

## Performance Benchmarks (Demo Environment)
- Dashboard load: < 2 seconds
- Real-time update latency: < 500ms
- Alert generation: < 2 seconds
- Prediction inference: < 100ms
- API response (p95): < 200ms