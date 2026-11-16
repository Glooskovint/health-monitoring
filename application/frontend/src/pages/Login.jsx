import { useState } from 'react'
import { Navigate, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../lib/authContext.js'
import { DEMO_PASSWORD, DEMO_USER } from '../lib/session.js'
import { OrbitalMark } from '../components/Layout.jsx'
export default function Login() {
  const { session, login } = useAuth(), location = useLocation(), navigate = useNavigate()
  const [email,setEmail] = useState(''), [password,setPassword] = useState(''), [error,setError] = useState('')
  const from = location.state?.from
  const destination = typeof from === 'string' && from.startsWith('/') && !from.startsWith('//') && !from.startsWith('/login') ? from : '/'
  if (session) return <Navigate to={destination} replace />
  function submit(e) { e.preventDefault(); try { login(email,password); navigate(destination,{replace:true}) } catch (e) { setError(e.message) } }
  return <div className="login-shell"><section className="login-art"><div className="login-brand"><OrbitalMark />EKEKO</div><div className="login-orbit" aria-hidden="true"><div className="planet"/><div className="planet-ring"/><span className="orbit-point"/></div><div className="login-heading"><span className="eyebrow">HUMAN EXPLORATION / MISSION CONTROL</span><h1>Cada señal.<br/>Cada vida.<br/><span>Más allá.</span></h1><div className="login-coordinates">BIO-TELEMETRY OS <span>02.00 / DEMO</span></div></div></section><section className="login-side"><div className="login-card"><div className="eyebrow">ACCESO A LA ESTACIÓN</div><h2>Control de misión</h2><p>Inicia sesión para supervisar las operaciones.</p><form onSubmit={submit}><label htmlFor="email">Correo electrónico</label><input id="email" type="email" autoComplete="username" required value={email} onChange={e=>setEmail(e.target.value)} placeholder="control@orbital.demo"/><label htmlFor="password">Contraseña</label><input id="password" type="password" autoComplete="current-password" required value={password} onChange={e=>setPassword(e.target.value)}/>{error && <p className="error" role="alert">{error}</p>}<button className="primary-button" type="submit">Entrar a la estación <span>→</span></button></form><div className="demo-access"><span className="panel-code">CREDENCIALES DE DEMOSTRACIÓN</span><code>{DEMO_USER.email}</code><code>{DEMO_PASSWORD}</code><button className="text-button" onClick={()=>{setEmail(DEMO_USER.email);setPassword(DEMO_PASSWORD);setError('')}}>Usar credenciales demo</button></div><small className="login-disclaimer">Acceso local simulado. No ingreses credenciales reales.</small></div></section></div>
}


