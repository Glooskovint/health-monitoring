import { useEffect, useState } from 'react'
import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { createSession, readSession, SESSION_KEY } from './session.js'
import { AuthContext, useAuth } from './authContext.js'
export function AuthProvider({ children }) {
  const [session, setSession] = useState(readSession)
  useEffect(() => {
    const sync = () => setSession(readSession())
    window.addEventListener('storage', sync)
    const timer = setInterval(sync, 15000)
    const expiry = session ? setTimeout(() => setSession(null), Math.max(0,session.expiresAt-Date.now())) : null
    return () => { window.removeEventListener('storage', sync); clearInterval(timer); if(expiry) clearTimeout(expiry) }
  }, [session])
  const login = (email, password) => {
    const next = createSession(email, password)
    try { localStorage.setItem(SESSION_KEY, JSON.stringify(next)) } catch { throw new Error('Habilita el almacenamiento del navegador para guardar la sesión.') }
    setSession(next)
  }
  const logout = () => { try { localStorage.removeItem(SESSION_KEY) } finally { setSession(null) } }
  return <AuthContext.Provider value={{ session, login, logout }}>{children}</AuthContext.Provider>
}
export function ProtectedRoute() {
  const { session } = useAuth(), location = useLocation()
  return session ? <Outlet /> : <Navigate to="/login" replace state={{ from: location.pathname + location.search }} />
}
