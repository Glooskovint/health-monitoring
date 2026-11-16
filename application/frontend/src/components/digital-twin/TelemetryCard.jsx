const ecg='0,25 18,25 22,22 26,25 35,25 40,30 45,5 50,44 56,19 62,25 87,25 92,22 96,25 105,25 110,30 115,5 120,44 126,19 132,25 160,25'
export default function TelemetryCard({system:s,index}) {
 return <article className={`dt-card dt-card-${s.id} relative backdrop-blur-[12px]`} style={{'--system-color':s.color}}>
 <div className="dt-card-top flex items-center justify-between gap-2"><span>0{index+1} / BIO SYSTEM</span><span className="dt-status">● {s.status}</span></div><h3>{s.title}</h3><div className={`dt-reading ${s.unit?'dt-reading-numeric':''}`}>{s.value}{s.unit&&<small>{s.unit}</small>}</div>
 {s.id==='cardiovascular'&&<svg className="dt-ecg" viewBox="0 0 160 50" aria-hidden="true"><path className="dt-ecg-grid" d="M0 12H160 M0 25H160 M0 38H160 M20 0V50 M60 0V50 M100 0V50 M140 0V50"/><polyline points={ecg}/><polyline className="dt-ecg-pulse" points={ecg}/></svg>}
 <p>{s.note}</p><div className="dt-card-track" aria-hidden="true"><span/></div></article>
}
