import http from 'node:http'
import { readFile } from 'node:fs/promises'
import { randomUUID } from 'node:crypto'
import { fileURLToPath } from 'node:url'

const seedPath = new URL('../../infrastructure/data/sample/monitoring-demo.json', import.meta.url)
const now = () => new Date().toISOString()
const fault = (status, detail) => Object.assign(new Error(detail), { status })
const levels = score => score >= .75 ? 'critical' : score >= .5 ? 'high' : score >= .3 ? 'medium' : 'low'

export async function createServer() {
  const { patients } = JSON.parse(await readFile(seedPath, 'utf8'))
  const measurements = patients.flatMap(p => Array.from({length: 168}, (_, i) => ({
    id: randomUUID(), patient_id: p.id, timestamp: new Date(Date.now() - (167-i)*3600000).toISOString(),
    heart_rate: p.baseline + Math.round(Math.sin(i*.7)*5), blood_pressure_systolic: p.risk > .7 ? 148 : 120,
    blood_pressure_diastolic: p.risk > .7 ? 94 : 80, oxygen_saturation: p.risk > .7 ? 93 : 98,
    temperature: 36.5, respiratory_rate: p.risk > .7 ? 23 : 16,
  })))
  const alerts = [{id:randomUUID(), patient_id:patients[1].id, type:'threshold_exceeded', severity:'high',
    message:'Frecuencia cardíaca por encima del umbral de demostración', value:125, threshold:120, created_at:now(), acknowledged:false}]
  const findPatient = id => patients.find(p => p.id === id) || (() => {throw fault(404,'Patient not found')})()
  const latest = id => measurements.filter(m => m.patient_id === id).sort((a,b) => b.timestamp.localeCompare(a.timestamp))[0]
  const service = name => ({service:name, status:name === 'api' ? 'healthy' : 'unavailable', latency_ms:0,last_check:now(),details:{mode:'demo', simulated:name !== 'api'}})
  return http.createServer(async (req,res) => {
    res.setHeader('Content-Type','application/json; charset=utf-8')
    res.setHeader('Cache-Control','no-store')
    const send = (data,status=200) => {res.writeHead(status); res.end(JSON.stringify(data))}
    try {
      const url = new URL(req.url,'http://localhost')
      const path = url.pathname
      const integer = (key, fallback, max=10000) => {
        const raw = url.searchParams.get(key), value = raw === null ? fallback : Number(raw)
        if (!Number.isInteger(value) || value < (key === 'offset' ? 0 : 1) || value > max) throw fault(400,`Invalid ${key}`)
        return value
      }
      const body = async () => {
        let content = ''
        for await (const chunk of req) {content += chunk; if(content.length > 65536) throw fault(413,'Payload too large')}
        try { return JSON.parse(content) } catch {throw fault(400,'Invalid JSON body')}
      }
      if (req.method === 'GET' && path === '/health') return send({status:'healthy',timestamp:now(),version:'0.1.0-demo'})
      // Explicit demo-only discovery extension: patient listing is absent from the supplied contract.
      if (req.method === 'GET' && path === '/api/demo/patients') return send({patients,mode:'demo'})
      if (req.method === 'GET' && path === '/api/v1/system/status') return send({status:'degraded',services:{database:'unavailable',redis:'unavailable',ml_model:'unavailable',api:'healthy'},metrics:{active_patients:patients.length,measurements_per_minute:0,avg_response_time_ms:0,error_rate:0},timestamp:now()})
      const svc = path.match(/^\/api\/v1\/system\/services\/([^/]+)$/)
      if(req.method === 'GET' && svc) {
        if(!['database','redis','ml_model','api'].includes(svc[1])) throw fault(404,'Service not found')
        return send(service(svc[1]))
      }
      const monitoring = path.match(/^\/api\/v1\/monitoring\/patients\/([^/]+)\/(latest|measurements)$/)
      if(req.method === 'GET' && monitoring) {
        const [,id,kind] = monitoring; findPatient(id)
        if(kind === 'latest') return send(latest(id))
        const limit = integer('limit',100), offset = integer('offset',0)
        for(const key of ['start_time','end_time']) if(url.searchParams.has(key) && !Number.isFinite(Date.parse(url.searchParams.get(key)))) throw fault(400,`Invalid ${key}`)
        const start = url.searchParams.get('start_time'), end = url.searchParams.get('end_time')
        if(start && end && Date.parse(start)>Date.parse(end)) throw fault(400,'Invalid time range')
        const rows = measurements.filter(m => m.patient_id === id && (!start || Date.parse(m.timestamp)>=Date.parse(start)) && (!end || Date.parse(m.timestamp)<=Date.parse(end))).sort((a,b) => b.timestamp.localeCompare(a.timestamp))
        return send({measurements:rows.slice(offset,offset+limit),total:rows.length,page:Math.floor(offset/limit)+1,page_size:limit})
      }
      if(req.method === 'POST' && path === '/api/v1/monitoring/measurements') {
        const input = await body(); findPatient(input.patient_id)
        if(!Number.isFinite(Date.parse(input.timestamp))) throw fault(400,'Invalid timestamp')
        const ranges = {heart_rate:[30,200],blood_pressure_systolic:[40,300],blood_pressure_diastolic:[20,200],oxygen_saturation:[0,100],temperature:[25,45],respiratory_rate:[1,80]}
        const clean = {id:randomUUID(),patient_id:input.patient_id,timestamp:new Date(input.timestamp).toISOString()}
        for(const [key,[min,max]] of Object.entries(ranges)) {
          const value = input[key]
          if(value !== undefined && value !== null && (typeof value !== 'number' || !Number.isFinite(value) || value<min || value>max)) throw fault(400,`Invalid ${key}`)
          clean[key] = value ?? null
        }
        measurements.push(clean)
        if(clean.heart_rate > 120) alerts.unshift({id:randomUUID(),patient_id:clean.patient_id,type:'threshold_exceeded',severity:'high',message:'Frecuencia cardíaca por encima del umbral de demostración',value:clean.heart_rate,threshold:120,created_at:now(),acknowledged:false})
        return send(clean,201)
      }
      const prediction = path.match(/^\/api\/v1\/predictions\/patients\/([^/]+)(\/trends)?$/)
      if(req.method === 'GET' && prediction) {
        const patient = findPatient(prediction[1])
        if(prediction[2]) return send({patient_id:patient.id,trends:Array.from({length:integer('days',7,90)},(_,i) => ({date:new Date(Date.now()-i*86400000).toISOString().slice(0,10),risk_score:patient.risk,risk_level:levels(patient.risk)})).reverse()})
        return send({patient_id:patient.id,prediction_timestamp:now(),horizon_hours:integer('horizon_hours',24,168),risk_score:patient.risk,risk_level:levels(patient.risk),predicted_vitals:{heart_rate:{mean:patient.baseline,std:5},blood_pressure_systolic:{mean:120,std:8},oxygen_saturation:{mean:97,std:1}},recommendations:['Predicción simulada. No utilizar para decisiones clínicas.']})
      }
      if(req.method === 'GET' && path === '/api/v1/alerts') {
        const acknowledged = url.searchParams.get('acknowledged'), severity = url.searchParams.get('severity'), patient = url.searchParams.get('patient_id')
        if(acknowledged !== null && !['true','false'].includes(acknowledged)) throw fault(400,'Invalid acknowledged')
        if(severity && !['critical','high','medium','low'].includes(severity)) throw fault(400,'Invalid severity')
        return send({alerts:alerts.filter(a => (!patient || a.patient_id === patient) && (!severity || a.severity === severity) && (acknowledged === null || a.acknowledged === (acknowledged === 'true')))})
      }
      const ack = path.match(/^\/api\/v1\/alerts\/([^/]+)\/acknowledge$/)
      if(req.method === 'POST' && ack) {
        const alert = alerts.find(a => a.id === ack[1]); if(!alert) throw fault(404,'Alert not found')
        const input = await body(); if(typeof input.acknowledged_by !== 'string' || !input.acknowledged_by.trim()) throw fault(400,'acknowledged_by is required')
        if(!alert.acknowledged) Object.assign(alert,{acknowledged:true,acknowledged_by:input.acknowledged_by,acknowledged_at:now(),notes:typeof input.notes === 'string' ? input.notes : ''})
        return send(alert)
      }
      throw fault(404,'Endpoint not found')
    } catch(error) {send({detail:error.status ? error.message : 'Internal server error',...(!error.status ? {request_id:randomUUID()} : {})},error.status || 500)}
  })
}
if(process.argv[1] === fileURLToPath(import.meta.url)) {
  const server = await createServer()
  server.listen(Number(process.env.PORT || 8000),'127.0.0.1',() => console.log('Demo API: http://127.0.0.1:8000'))
}
