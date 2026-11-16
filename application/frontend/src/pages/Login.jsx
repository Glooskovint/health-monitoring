import { useLanguage, LanguageSelector } from '../lib/language.jsx'
import { useState } from 'react'
import { Navigate, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../lib/authContext.js'
import { DEMO_PASSWORD, DEMO_USER } from '../lib/session.js'
import { OrbitalMark } from '../components/Layout.jsx'
export default function Login() {
  const { t } = useLanguage()
  const { session, login } = useAuth(), location = useLocation(), navigate = useNavigate()
  const [email,setEmail] = useState(''), [password,setPassword] = useState(''), [error,setError] = useState('')
  const from = location.state?.from
  const destination = typeof from === 'string' && from.startsWith('/') && !from.startsWith('//') && !from.startsWith('/login') ? from : '/'
  if (session) return <Navigate to={destination} replace />
  function submit(e) { e.preventDefault(); try { login(email,password); navigate(destination,{replace:true}) } catch (e) { setError(e.message) } }
  return <div className="login-shell"><section className="login-art"><div className="login-brand"><OrbitalMark />EKEKO</div><div className="login-orbit" aria-hidden="true"><div className="planet"/><div className="planet-ring"/><span className="orbit-point"/></div><div className="login-heading"><span className="eyebrow">HUMAN EXPLORATION / MISSION CONTROL</span><h1>{t("Cada señal.")}<br/>{t("Cada vida.")}<br/><span>{t("Más allá.")}</span></h1><div className="login-coordinates">BIO-TELEMETRY OS <span>02.00 / DEMO</span></div></div></section><section className="login-side"><LanguageSelector /><div className="login-card"><div className="eyebrow">{t("ACCESO A LA ESTACIÓN")}</div><h2>{t("Control de misión")}</h2><p>{t("Inicia sesión para supervisar las operaciones.")}</p><form onSubmit={submit}><label htmlFor="email">{t("Correo electrónico")}</label><input id="email" type="email" autoComplete="username" required value={email} onChange={e=>setEmail(e.target.value)} placeholder="control@orbital.demo"/><label htmlFor="password">{t("Contraseña")}</label><input id="password" type="password" autoComplete="current-password" required value={password} onChange={e=>setPassword(e.target.value)}/>{error && <p className="error" role="alert">{t(error)}</p>}<button className="primary-button" type="submit">{t("Entrar a la estación")}<span>→</span></button></form><div className="demo-access"><span className="panel-code">{t("CREDENCIALES DE DEMOSTRACIÓN")}</span><code>{DEMO_USER.email}</code><code>{DEMO_PASSWORD}</code><button className="text-button" onClick={()=>{setEmail(DEMO_USER.email);setPassword(DEMO_PASSWORD);setError('')}}>{t("Usar credenciales demo")}</button></div><small className="login-disclaimer">{t("Acceso local simulado. No ingreses credenciales reales.")}</small></div></section></div>
}


