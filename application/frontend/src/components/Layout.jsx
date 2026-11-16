import { useLanguage, LanguageSelector } from '../lib/language.jsx'
import { useEffect, useState } from 'react'
import { Link, NavLink, Outlet } from 'react-router-dom'
import { useAuth } from '../lib/authContext.js'
import { dataMode } from '../lib/api.js'
export function OrbitalMark() {
  
  return <svg viewBox="0 0 40 40" width="34" height="34" fill="none" aria-hidden="true"><circle cx="20" cy="20" r="10" stroke="currentColor" /><ellipse cx="20" cy="20" rx="19" ry="7" transform="rotate(-40 20 20)" stroke="currentColor" /><circle cx="20" cy="20" r="3" fill="currentColor" /><circle cx="33" cy="9" r="2" fill="currentColor" /></svg>
}
export default function Layout() {
  const { t, locale } = useLanguage()
  const { session, logout } = useAuth(), [clock, setClock] = useState(() => new Date())
  useEffect(() => { const timer = setInterval(() => setClock(new Date()), 1000); return () => clearInterval(timer) }, [])
  return <div className="shell"><aside className="sidebar"><Link to="/" className="brand"><OrbitalMark /><span>EKEKO<small>BIO-TELEMETRY OS / 2.0</small></span></Link><div className="workspace-label">{t("CONTROL DE MISIÓN")}</div><nav><NavLink to="/" end className={({isActive}) => `nav ${isActive ? 'active' : ''}`}><span aria-hidden="true">▦</span>{t("Operaciones")}</NavLink><NavLink to="/alertas" className={({isActive}) => `nav ${isActive ? 'active' : ''}`}><span aria-hidden="true">△</span>{t("Alertas")}</NavLink></nav><div className="sidebar-orbit" aria-hidden="true"><div className="orbit-ring"/><div className="orbit-ring second"/><span>EARTH LINK<br/><b>EKEKO NETWORK</b></span></div><div className="sidebar-bottom"><span className="avatar">CM</span><div>{t(session.user.name)}<small>{t("Sesión de demostración")}</small></div></div><button className="logout-button" onClick={logout}>{t("↪ Cerrar sesión")}</button></aside><div className="main"><header><span>MISSION CONTROL <span className="muted">/ BIO-TELEMETRY</span></span><div className="header-right"><LanguageSelector /><time>{clock.toLocaleTimeString(locale, {hour12:false})} <span className="muted">LOCAL</span></time><span className="demo-badge">● {dataMode === 'mock' ? t("DATOS SIMULADOS") : t("API / CATÁLOGO DEMO")}</span></div></header><main><Outlet /><footer><span>EKEKO / 2.0</span><span>{t("ENTORNO DE DEMOSTRACIÓN · SIN USO CLÍNICO")}</span></footer></main></div></div>
}
export function TrafficLight({ level, label }) {
  
  return <span className={`traffic ${level}`} aria-label={label}><i aria-hidden="true" />{label}</span>
}
export function Panel({ title, code, children, className = '', action }) {
  
  return <section className={`panel ${className}`}><div className="section-heading"><div>{code && <div className="panel-code">{code}</div>}<h2>{title}</h2></div>{action}</div>{children}</section>
}



