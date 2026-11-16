import { useId, useState } from 'react'

import './AstronautTwin.css'
const systems = [
 {id:'cardiovascular',title:'Cardiovascular',color:'#00F0FF',value:'75',unit:'BPM',status:'NOMINAL',note:'Ritmo sinusal · ECG',path:'285,215 350,215 430,245 510,245',x:510,y:245},
 {id:'skeletal',title:'Sistema óseo',color:'#FFB300',value:'Densidad: -2.4%',status:'CAUTION',note:'Variación de densidad mineral',path:'285,465 355,465 425,476 480,476',x:480,y:476},
 {id:'psychological',title:'Salud psicológica',color:'#8B5CF6',value:'Estrés: Bajo',status:'NOMINAL',note:'Balance cognitivo / emocional',path:'715,215 650,215 575,133 500,133',x:500,y:133},
 {id:'immune',title:'Sistema inmunológico',color:'#FF2A6D',value:'Glóbulos Blancos Estables',status:'CRÍTICO',note:'Estado de demostración',path:'715,465 645,465 570,322 500,322',x:500,y:322},
]
export default function AstronautTwin({name='Astronauta',callsign='ORB-01', initialGender='male'}) {
 const id=useId()
 const [gender, setGender] = useState(initialGender === 'female' ? 'female' : 'male');
 return <section className="digital-twin relative overflow-hidden" aria-labelledby={`${id}-title`}>
 <header className="dt-header flex flex-wrap items-center justify-between gap-4"><div><span className="dt-eyebrow">EKEKO HEALTH / DIGITAL TWIN</span><h2 id={`${id}-title`}>Gemelo digital <span>{callsign}</span></h2></div><div className="dt-header-controls"><div className="dt-gender-toggle" role="group" aria-label="Modelo anatómico">{[['male','MALE / VARÓN'],['female','FEMALE / MUJER']].map(([value,label])=><button key={value} type="button" aria-pressed={gender===value} onClick={()=>setGender(value)}>{label}</button>)}</div><span className="dt-online">● SYS.ONLINE</span></div></header>
 <div className="dt-stage relative"><div className="dt-hud dt-subject">{name} // BIOMETRIC DATA LOCK</div>
 <div className="dt-body"><div className="dt-hologram"><img src={gender === 'male' ? '/anatomy-male.png' : '/anatomy-female.png'} alt={`Holograma anatómico: ${gender === 'male' ? 'varón' : 'mujer'}`} className="dt-anatomy"/><div className="dt-scan" aria-hidden="true"/></div><div className="dt-projector" aria-hidden="true"><div className="dt-ring"/><div className="dt-ring dt-ring-inner"/></div></div>
 <svg className="dt-connections" viewBox="0 0 1000 700" preserveAspectRatio="none" aria-hidden="true">{systems.map(s=><g key={s.id}><polyline points={s.path}/><circle cx={s.x} cy={s.y} r="5" style={{stroke:s.color}}/></g>)}</svg>
 <div className="dt-panels">{systems.map((system,index)=><TelemetryCard key={system.id} system={system} index={index}/>)}</div>
 <div className="dt-hud dt-scanning">SYS.ONLINE // SCANNING…</div><div className="dt-hud dt-coordinate">ANATOMICAL MAP / 2D<br/>LINK STABLE · SIGNAL LOCKED</div></div>
 <footer className="dt-footer flex flex-wrap justify-between gap-2"><span>● HOLOGRAPHIC PROJECTION ACTIVE</span><span>DATOS SIMULADOS · SIN USO CLÍNICO</span></footer></section>
}

const ecg='0,25 18,25 22,22 26,25 35,25 40,30 45,5 50,44 56,19 62,25 87,25 92,22 96,25 105,25 110,30 115,5 120,44 126,19 132,25 160,25'
function TelemetryCard({system:s,index}) {
 return <article className={`dt-card dt-card-${s.id} relative backdrop-blur-[12px]`} style={{'--system-color':s.color}}>
 <div className="dt-card-top flex items-center justify-between gap-2"><span>0{index+1} / BIO SYSTEM</span><span className="dt-status">● {s.status}</span></div><h3>{s.title}</h3><div className={`dt-reading ${s.unit?'dt-reading-numeric':''}`}>{s.value}{s.unit&&<small>{s.unit}</small>}</div>
 {s.id==='cardiovascular'&&<svg className="dt-ecg" viewBox="0 0 160 50" aria-hidden="true"><path className="dt-ecg-grid" d="M0 12H160 M0 25H160 M0 38H160 M20 0V50 M60 0V50 M100 0V50 M140 0V50"/><polyline points={ecg}/><polyline className="dt-ecg-pulse" points={ecg}/></svg>}
 <p>{s.note}</p><div className="dt-card-track" aria-hidden="true"><span/></div></article>
}



