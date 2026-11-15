import { mockRequest } from '../mocks/api.js'
// Default is explicit demo mode. No silent fallback from an unavailable real API.
export const dataMode = import.meta.env.VITE_DATA_MODE === 'api' ? 'api' : 'mock'
export async function request(path, options = {}) {
  if (dataMode === 'mock') return mockRequest(path, options)
  // Real JWT issuance is not specified by the supplied contract; demo sessions never forge tokens.
  const response = await fetch(`${import.meta.env.VITE_API_BASE_URL || ''}${path}`, { ...options, headers: { 'Content-Type': 'application/json', ...options.headers } })
  const body = await response.json()
  if (!response.ok) throw new Error(body.detail || `Error HTTP ${response.status}`)
  return body
}
export async function loadAstronaut(id, hours = 24) {
  const start = new Date(Date.now() - hours * 3600000).toISOString()
  const [latest, history, prediction, trends, alerts] = await Promise.all([
    request(`/api/v1/monitoring/patients/${id}/latest`),
    request(`/api/v1/monitoring/patients/${id}/measurements?start_time=${encodeURIComponent(start)}&limit=1100&offset=0`),
    request(`/api/v1/predictions/patients/${id}?horizon_hours=24`),
    request(`/api/v1/predictions/patients/${id}/trends?days=7`),
    request(`/api/v1/alerts?patient_id=${id}`),
  ])
  return { latest, history: history.measurements.toSorted((a,b) => a.timestamp.localeCompare(b.timestamp)), prediction, trends: trends.trends, alerts: alerts.alerts }
}

