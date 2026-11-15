import { astronauts, riskLevel } from './catalog.js'
const epoch = Math.floor(Date.now() / 600000) * 600000
const histories = new Map(astronauts.map(a => [a.id, Array.from({ length: 1009 }, (_, i) => ({
  id: `00000000-1000-4000-8000-${String(a.number * 10000 + i).padStart(12, '0')}`, patient_id: a.id, timestamp: new Date(epoch - (1008 - i) * 600000).toISOString(),
  heart_rate: Math.round(a.baseline + Math.sin(i * .34 + a.number) * 6 + Math.cos(i * .13) * 3),
  blood_pressure_systolic: Math.round((a.risk > .7 ? 141 : 119) + Math.sin(i * .19) * 7),
  blood_pressure_diastolic: Math.round((a.risk > .7 ? 91 : 77) + Math.cos(i * .19) * 4),
  oxygen_saturation: +(Math.min(100, (a.risk > .7 ? 94 : 98) + Math.sin(i * .15) * 1.2)).toFixed(1),
  temperature: +(36.6 + Math.sin(i * .09) * .3 + (a.risk > .7 ? .6 : 0)).toFixed(1),
  respiratory_rate: Math.round((a.risk > .7 ? 23 : 16) + Math.sin(i * .2) * 2),
}))]))
const initialAlerts = astronauts.filter(a => a.risk >= .3).map(a => ({
  id: `00000000-2000-4000-8000-${String(a.number).padStart(12, '0')}`, patient_id: a.id, type: 'threshold_exceeded',
  severity: riskLevel(a.risk), message: a.risk > .7 ? 'Frecuencia cardíaca elevada' : 'Frecuencia respiratoria en observación',
  value: a.risk > .7 ? a.baseline : 21, threshold: a.risk > .7 ? 110 : 20,
  created_at: new Date(epoch - a.number * 120000).toISOString(), acknowledged: false,
}))
let acknowledgments = {}
try {
  const saved = typeof window !== 'undefined' ? JSON.parse(window.localStorage.getItem('orbital.demo.alerts') || '{}') : {}
  if (saved && typeof saved === 'object' && !Array.isArray(saved)) acknowledgments = saved
} catch { /* browser storage may be disabled */ }
const error = (status, detail) => Object.assign(new Error(detail), { status })

// Implements only documented REST response shapes; no network calls or invented auth endpoints.
export async function mockRequest(path, options = {}) {
  const url = new URL(path, 'http://demo.local'), route = url.pathname
  if (route === '/api/v1/alerts' && !options.method) {
    let alerts = initialAlerts.map(a => ({ ...a, ...acknowledgments[a.id] }))
    for (const key of ['patient_id', 'severity']) if (url.searchParams.has(key)) alerts = alerts.filter(a => a[key] === url.searchParams.get(key))
    if (url.searchParams.has('acknowledged')) alerts = alerts.filter(a => a.acknowledged === (url.searchParams.get('acknowledged') === 'true'))
    return { alerts }
  }
  const ack = route.match(/^\/api\/v1\/alerts\/([^/]+)\/acknowledge$/)
  if (ack && options.method === 'POST') {
    const alert = initialAlerts.find(a => a.id === ack[1])
    if (!alert) throw error(404, 'Alerta no encontrada')
    const body = JSON.parse(options.body)
    if (!body.acknowledged_by) throw error(400, 'Se requiere acknowledged_by')
    acknowledgments[alert.id] ||= { acknowledged: true, acknowledged_by: body.acknowledged_by, acknowledged_at: new Date().toISOString(), notes: body.notes || '' }
    try { if (typeof window !== 'undefined') window.localStorage.setItem('orbital.demo.alerts', JSON.stringify(acknowledgments)) } catch { /* acknowledgment still works in memory */ }
    return { ...alert, ...acknowledgments[alert.id] }
  }
  const match = route.match(/^\/api\/v1\/(monitoring|predictions)\/patients\/([^/]+)(?:\/(latest|measurements|trends))?$/)
  if (!match) throw error(404, 'Ruta no disponible en demostración')
  const [, group, id, kind] = match, astronaut = astronauts.find(a => a.id === id)
  if (!astronaut) throw error(404, 'Astronauta no encontrado')
  const rows = histories.get(id)
  if (group === 'monitoring') {
    if (kind === 'latest') return { ...rows.at(-1) }
    const start = url.searchParams.get('start_time'), end = url.searchParams.get('end_time')
    const filtered = rows.filter(m => (!start || Date.parse(m.timestamp) >= Date.parse(start)) && (!end || Date.parse(m.timestamp) <= Date.parse(end))).toReversed()
    const limit = Number(url.searchParams.get('limit') || 100), offset = Number(url.searchParams.get('offset') || 0)
    return { measurements: filtered.slice(offset, offset + limit), total: filtered.length, page: Math.floor(offset / limit) + 1, page_size: limit }
  }
  if (kind === 'trends') {
    const days = Number(url.searchParams.get('days') || 7)
    return { patient_id: id, trends: Array.from({ length: days }, (_, i) => {
    const score = +Math.max(0, Math.min(1, astronaut.risk + Math.sin(i * .9) * .06)).toFixed(3)
    return { date: new Date(epoch - (days - 1 - i) * 86400000).toISOString().slice(0, 10), risk_score: score, risk_level: riskLevel(score) }
  }) }
  }
  return { patient_id: id, prediction_timestamp: new Date(epoch).toISOString(), horizon_hours: Number(url.searchParams.get('horizon_hours') || 24), risk_score: astronaut.risk, risk_level: riskLevel(astronaut.risk), predicted_vitals: { heart_rate: { mean: astronaut.baseline, std: 5 }, blood_pressure_systolic: { mean: 120, std: 8 }, oxygen_saturation: { mean: 98, std: 1 } }, recommendations: ['Estimación simulada. Sin uso clínico.'] }
}
