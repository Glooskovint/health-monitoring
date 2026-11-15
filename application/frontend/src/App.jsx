import { lazy, Suspense } from 'react'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { AuthProvider, ProtectedRoute } from './lib/auth.jsx'
import Layout from './components/Layout.jsx'
import Login from './pages/Login.jsx'
import './App.css'
const Dashboard = lazy(() => import('./pages/Dashboard.jsx'))
const Astronaut = lazy(() => import('./pages/Astronaut.jsx'))
const Alerts = lazy(() => import('./pages/Alerts.jsx'))
export default function App() {
  return <BrowserRouter><AuthProvider><Suspense fallback={<div className="loading-state" role="status">Abriendo estación…</div>}><Routes><Route path="/login" element={<Login/>}/><Route element={<ProtectedRoute/>}><Route element={<Layout/>}><Route index element={<Dashboard/>}/><Route path="dashboard" element={<Navigate to="/" replace/>}/><Route path="astronautas/:id" element={<Astronaut/>}/><Route path="alertas" element={<Alerts/>}/><Route path="*" element={<Navigate to="/" replace/>}/></Route></Route></Routes></Suspense></AuthProvider></BrowserRouter>
}
