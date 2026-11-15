import { test } from 'node:test'
import assert from 'node:assert/strict'
import { createServer } from './server.mjs'

test('REST contract: measurements, predictions, alerts and errors', async t => {
  const server = await createServer()
  await new Promise(resolve => server.listen(0,'127.0.0.1',resolve))
  t.after(() => new Promise(resolve => server.close(resolve)))
  const base = `http://127.0.0.1:${server.address().port}`
  const get = async path => { const r = await fetch(base+path); assert.equal(r.status,200); return r.json() }
  assert.equal((await get('/health')).status,'healthy')
  const {patients} = await get('/api/demo/patients'), id=patients[0].id
  const latest=await get(`/api/v1/monitoring/patients/${id}/latest`)
  assert.equal(latest.patient_id,id)
  const history=await get(`/api/v1/monitoring/patients/${id}/measurements?limit=2&offset=2`)
  assert.equal(history.measurements.length,2);assert.equal(history.page,2);assert.equal(history.page_size,2)
  const post = (path,body) => fetch(base+path,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(body)})
  const created=await post('/api/v1/monitoring/measurements',{patient_id:id,timestamp:new Date().toISOString(),heart_rate:130})
  assert.equal(created.status,201)
  assert.equal((await get(`/api/v1/monitoring/patients/${id}/latest`)).heart_rate,130)
  assert.equal((await post('/api/v1/monitoring/measurements',{patient_id:id,timestamp:new Date().toISOString(),heart_rate:999})).status,400)
  const {alerts}=await get(`/api/v1/alerts?patient_id=${id}&acknowledged=false`)
  assert.equal(alerts.length,1)
  const acknowledged=await post(`/api/v1/alerts/${alerts[0].id}/acknowledge`,{acknowledged_by:id,notes:'test'})
  assert.equal((await acknowledged.json()).acknowledged,true)
  assert.equal((await get(`/api/v1/alerts?patient_id=${id}&acknowledged=false`)).alerts.length,0)
  assert.equal((await get(`/api/v1/predictions/patients/${id}?horizon_hours=48`)).horizon_hours,48)
  assert.equal((await get(`/api/v1/predictions/patients/${id}/trends?days=30`)).trends.length,30)
  assert.equal((await get('/api/v1/system/status')).services.database,'unavailable')
  assert.equal((await get('/api/v1/system/services/api')).status,'healthy')
  for(const [path,status] of [[`/api/v1/monitoring/patients/${id}/measurements?limit=-1`,400],[`/api/v1/monitoring/patients/${id}/measurements?start_time=invalid`,400],['/api/v1/monitoring/patients/missing/latest',404],['/api/v1/alerts?acknowledged=invalid',400]]) {
    const r=await fetch(base+path);assert.equal(r.status,status);assert.equal(typeof (await r.json()).detail,'string')
  }
})
