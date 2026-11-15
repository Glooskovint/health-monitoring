import { test } from 'node:test'
import assert from 'node:assert/strict'
import { astronauts, operations } from './catalog.js'
import { mockRequest } from './api.js'
import { createSession, readSession, DEMO_USER, DEMO_PASSWORD, SESSION_KEY } from '../lib/session.js'

test('every astronaut belongs to exactly one operation', () => {
  assert.equal(operations.length,3)
  assert.equal(astronauts.length,8)
  assert.equal(new Set(astronauts.map(a=>a.id)).size,8)
  for(const astronaut of astronauts) {
    const operation=operations.find(o=>o.id===astronaut.operationId)
    assert.ok(operation.crewIds.includes(astronaut.number))
    assert.match(astronaut.id,/^[a-f0-9-]{36}$/)
  }
})
test('demo session rejects invalid credentials, restores valid sessions and expires', () => {
  assert.throws(()=>createSession(DEMO_USER.email,'wrong'))
  const session=createSession(DEMO_USER.email,DEMO_PASSWORD)
  const storage={getItem:key=>key===SESSION_KEY?JSON.stringify(session):null}
  assert.equal(readSession(storage).user.id,DEMO_USER.id)
  session.expiresAt=Date.now()-1
  assert.equal(readSession(storage),null)
  assert.equal(readSession({getItem:()=>'{bad json'}),null)
  assert.equal(readSession({getItem:()=>JSON.stringify({mode:'demo',expiresAt:Date.now()+1000,user:{id:'fake'}})}),null)
})
test('telemetry follows contract shapes and filters/paginates by time', async () => {
  const id=astronauts[0].id, base=`/api/v1/monitoring/patients/${id}`
  const latest=await mockRequest(`${base}/latest`)
  assert.equal(latest.patient_id,id)
  for(const key of ['heart_rate','blood_pressure_systolic','blood_pressure_diastolic','oxygen_saturation','temperature','respiratory_rate']) assert.equal(typeof latest[key],'number')
  const start=new Date(Date.parse(latest.timestamp)-3600000).toISOString()
  const history=await mockRequest(`${base}/measurements?start_time=${encodeURIComponent(start)}&limit=3&offset=3`)
  assert.equal(history.page,2);assert.equal(history.page_size,3);assert.equal(history.measurements.length,3);assert.equal(history.total,7)
  assert.ok(history.measurements.every(m=>m.timestamp>=start))
  const prediction=await mockRequest(`/api/v1/predictions/patients/${id}?horizon_hours=48`)
  assert.equal(prediction.horizon_hours,48);assert.ok(prediction.risk_score>=0&&prediction.risk_score<=1)
  const trends=await mockRequest(`/api/v1/predictions/patients/${id}/trends?days=7`)
  assert.equal(trends.trends.length,7)
  await assert.rejects(mockRequest('/api/v1/monitoring/patients/missing/latest'),{status:404})
})
test('acknowledgment filters out the matching alert without changing other crew', async () => {
  const before=await mockRequest('/api/v1/alerts?acknowledged=false')
  const target=before.alerts[0]
  assert.ok(target)
  const result=await mockRequest(`/api/v1/alerts/${target.id}/acknowledge`,{method:'POST',body:JSON.stringify({acknowledged_by:DEMO_USER.id,notes:'Demo test'})})
  assert.equal(result.acknowledged,true)
  assert.equal(result.acknowledged_by,DEMO_USER.id)
  assert.ok(Number.isFinite(Date.parse(result.acknowledged_at)))
  const after=await mockRequest('/api/v1/alerts?acknowledged=false')
  assert.equal(after.alerts.length,before.alerts.length-1)
  assert.ok(!after.alerts.some(a=>a.id===target.id))
  const filtered=await mockRequest(`/api/v1/alerts?patient_id=${target.patient_id}`)
  assert.equal(filtered.alerts.length,1)
  assert.equal(filtered.alerts[0].acknowledged,true)
})
