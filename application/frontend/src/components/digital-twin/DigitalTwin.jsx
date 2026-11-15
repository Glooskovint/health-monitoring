import { useId } from 'react'
import TelemetryCard from './TelemetryCard.jsx'
import './DigitalTwin.css'
const systems = [
 {id:'cardiovascular',title:'Cardiovascular',color:'#FF2A6D',value:'75',unit:'BPM',status:'NOMINAL',note:'Ritmo sinusal · ECG',path:'285,215 350,215 430,245 510,245',x:510,y:245},
 {id:'skeletal',title:'Sistema óseo',color:'#FFB300',value:'Densidad: -2.4%',status:'CAUTION',note:'Variación de densidad mineral',path:'285,465 355,465 425,476 480,476',x:480,y:476},
 {id:'psychological',title:'Salud psicológica',color:'#8B5CF6',value:'Estrés: Bajo',status:'NOMINAL',note:'Balance cognitivo / emocional',path:'715,215 650,215 575,133 500,133',x:500,y:133},
 {id:'immune',title:'Sistema inmunológico',color:'#00D2B4',value:'Glóbulos Blancos: Estable',status:'NOMINAL',note:'Respuesta inmunitaria basal',path:'715,465 645,465 570,322 500,322',x:500,y:322},
]
export default function DigitalTwin({name='Astronauta',callsign='ORB-01',imageSrc=`${import.meta.env.BASE_URL}anatomy.png`}) {
 const id=useId()
 return <section className="digital-twin relative overflow-hidden" aria-labelledby={`${id}-title`}>
 <header className="dt-header flex flex-wrap items-center justify-between gap-4"><div><span className="dt-eyebrow">ORBITAL HEALTH / DIGITAL TWIN</span><h2 id={`${id}-title`}>Gemelo digital <span>{callsign}</span></h2></div><span className="dt-online">● SYS.ONLINE</span></header>
 <div className="dt-stage relative"><div className="dt-hud dt-subject">{name} // BIOMETRIC DATA LOCK</div>
 <div className="dt-body" role="img" aria-label="Holograma anatómico del astronauta con escáner y proyector"><div className="dt-hologram"><img src={imageSrc} alt="" className="dt-anatomy"/><div className="dt-scan"/></div><div className="dt-projector"><div className="dt-ring"/><div className="dt-ring dt-ring-inner"/></div></div>
 <svg className="dt-connections" viewBox="0 0 1000 700" preserveAspectRatio="none" aria-hidden="true">{systems.map(s=><g key={s.id}><polyline points={s.path}/><circle cx={s.x} cy={s.y} r="5" style={{stroke:s.color}}/></g>)}</svg>
 <div className="dt-panels">{systems.map((system,index)=><TelemetryCard key={system.id} system={system} index={index}/>)}</div>
 <div className="dt-hud dt-scanning">SYS.ONLINE // SCANNING…</div><div className="dt-hud dt-coordinate">ANATOMICAL MAP / 2D<br/>LINK STABLE · SIGNAL LOCKED</div></div>
 <footer className="dt-footer flex flex-wrap justify-between gap-2"><span>● HOLOGRAPHIC PROJECTION ACTIVE</span><span>DATOS SIMULADOS · SIN USO CLÍNICO</span></footer></section>
}
