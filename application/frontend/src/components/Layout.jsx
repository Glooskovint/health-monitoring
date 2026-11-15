import { useEffect, useState } from 'react'
import { Link, NavLink, Outlet } from 'react-router-dom'
import { useAuth } from '../lib/authContext.js'
import { dataMode } from '../lib/api.js'
export function OrbitalMark() {
  return <svg viewBox="0 0 40 40" width="34" height="34" fill="none" aria-hidden="true"><circle cx="20" cy="20" r="10" stroke="currentColor" /><ellipse cx="20" cy="20" rx="19" ry="7" transform="rotate(-40 20 20)" stroke="currentColor" /><circle cx="20" cy="20" r="3" fill="currentColor" /><circle cx="33" cy="9" r="2" fill="currentColor" /></svg>
}
export default function Layout() {
  const { session, logout } = useAuth(), [clock, setClock] = useState(() => new Date())
  useEffect(() => { const timer = setInterval(() => setClock(new Date()), 1000); return () => clearInterval(timer) }, [])
  return <div className="shell"><aside className="sidebar"><Link to="/" className="brand"><OrbitalMark /><span>ORBITAL<small>BIO-TELEMETRY OS / 2.0</small></span></Link><div className="workspace-label">CONTROL DE MISIÓN</div><nav><NavLink to="/" end className={({isActive}) => `nav ${isActive ? 'active' : ''}`}><span aria-hidden="true">▦</span>Operaciones</NavLink><NavLink to="/alertas" className={({isActive}) => `nav ${isActive ? 'active' : ''}`}><span aria-hidden="true">△</span>Alertas</NavLink></nav><div className="sidebar-orbit" aria-hidden="true"><div className="orbit-ring"/><div className="orbit-ring second"/><span>EARTH LINK<br/><b>ORBITAL NETWORK</b></span></div><div className="sidebar-bottom"><span className="avatar">CM</span><div>{session.user.name}<small>Sesión de demostración</small></div></div><button className="logout-button" onClick={logout}>↪ Cerrar sesión</button></aside><div className="main"><header><span>MISSION CONTROL <span className="muted">/ BIO-TELEMETRY</span></span><div className="header-right"><time>{clock.toLocaleTimeString('es-PE', {hour12:false})} <span className="muted">LOCAL</span></time><span className="demo-badge">● {dataMode === 'mock' ? 'DATOS SIMULADOS' : 'API / CATÁLOGO DEMO'}</span></div></header><main><Outlet /><footer><span>ORBITAL / 2.0</span><span>ENTORNO DE DEMOSTRACIÓN · SIN USO CLÍNICO</span></footer></main></div></div>
}
export function TrafficLight({ level, label }) {
  return <span className={`traffic ${level}`} aria-label={label}><i aria-hidden="true" />{label}</span>
}
export function Panel({ title, code, children, className = '', action }) {
  return <section className={`panel ${className}`}><div className="section-heading"><div>{code && <div className="panel-code">{code}</div>}<h2>{title}</h2></div>{action}</div>{children}</section>
}


