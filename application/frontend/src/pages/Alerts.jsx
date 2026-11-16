import { useLanguage } from '../lib/language.jsx'
import { useState } from 'react'
import { useTelemetry } from '../lib/useTelemetry.js'
import { request } from '../lib/api.js'
import { useAuth } from '../lib/authContext.js'
import { Panel } from '../components/Layout.jsx'
import { AlertList } from './Astronaut.jsx'
export default function Alerts() {
  const { t } = useLanguage()
  const {data,loading,error,retry}=useTelemetry(),{session}=useAuth(),[pending,setPending]=useState(''),[recognized,setRecognized]=useState({}),[showAll,setShowAll]=useState(false),[ackError,setAckError]=useState('')
  const alerts=Object.values(data||{}).flatMap(d=>d.alerts).map(a=>({...a,acknowledged:a.acknowledged||recognized[a.id]})).filter(a=>showAll||!a.acknowledged).sort((a,b)=>b.created_at.localeCompare(a.created_at))
  async function acknowledge(id){setPending(id);setAckError('');try{await request(`/api/v1/alerts/${id}/acknowledge`,{method:'POST',body:JSON.stringify({acknowledged_by:session.user.id,notes:'Revisada en control de misión (demo)'})});setRecognized(d=>({...d,[id]:true}))}catch(e){setAckError(e.message)}finally{setPending('')}}
  return <><div className="dashboard-heading"><div><div className="eyebrow">EKEKO / EVENT LOG</div><h1>{t("Centro de alertas")}<span className="title-dot">.</span></h1></div></div>{loading&&<p role="status">{t("Cargando alertas…")}</p>}{error&&<div className="error" role="alert">{t(error)}<button onClick={retry}>{t("Reintentar")}</button></div>}{ackError&&<p className="error" role="alert">{t(ackError)}</p>}{data&&<Panel title={t("Todas las operaciones")} code="BIOMETRIC EVENTS" action={<label className="check"><input type="checkbox" checked={showAll} onChange={e=>setShowAll(e.target.checked)}/>{t("Incluir reconocidas")}</label>}><AlertList alerts={alerts} onAcknowledge={acknowledge} pending={pending} names/></Panel>}</>
}


