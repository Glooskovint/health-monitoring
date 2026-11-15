import { useEffect, useState } from 'react'
import { astronauts } from '../mocks/catalog.js'
import { loadAstronaut } from './api.js'
export function useTelemetry(id, hours = 24) {
  const [state,setState] = useState({ key:null, data:null, loading:true, error:'' }), [revision,setRevision] = useState(0)
  const key = `${id || 'all'}:${hours}:${revision}`
  useEffect(() => {
    let active = true, running = false
    async function load() {
      if (running) return
      running = true
      try {
        const data = id ? await loadAstronaut(id,hours) : Object.fromEntries(await Promise.all(astronauts.map(async a => [a.id,await loadAstronaut(a.id,24)])))
        if(active) setState({key,data,loading:false,error:''})
      } catch(e) { if(active) setState(current => ({key,data:current.key === key ? current.data : null,loading:false,error:e.message})) }
      finally { running = false }
    }
    load(); const timer = setInterval(load,30000)
    return () => {active=false;clearInterval(timer)}
  },[id,hours,key])
  const current = state.key === key ? state : {data:null,loading:true,error:''}
  return {...current,retry:()=>setRevision(v=>v+1)}
}
