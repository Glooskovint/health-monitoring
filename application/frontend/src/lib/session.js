export const SESSION_KEY = 'orbital.session.v1'
export const DEMO_USER = { id: '00000000-0000-4000-8000-000000000100', name: 'Control de misión', email: 'control@orbital.demo' }
export const DEMO_PASSWORD = 'Orbital2026!'
export function readSession(storage = localStorage) {
  try {
    const session = JSON.parse(storage.getItem(SESSION_KEY))
    if (session?.user?.id !== DEMO_USER.id || session?.user?.email !== DEMO_USER.email || session?.mode !== 'demo' || !Number.isFinite(session?.expiresAt) || session.expiresAt <= Date.now()) return null
    return session
  } catch { return null }
}
export function createSession(email, password) {
  if (email.trim().toLowerCase() !== DEMO_USER.email || password !== DEMO_PASSWORD) throw new Error('Correo o contraseña incorrectos.')
  return { user: DEMO_USER, mode: 'demo', expiresAt: Date.now() + 8 * 3600000 }
}
