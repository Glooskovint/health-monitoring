import { Billboard, Html } from '@react-three/drei'
import { useFrame } from '@react-three/fiber'
import { useRef } from 'react'
const palette={cyan:'#00f0ff',amber:'#ffb300',crimson:'#ff2a6d',violet:'#8b5cf6'}
export default function Hotspot({system,active,selected,onHover,onFocus,onSelect,motion,instanceId}) {
  const mesh=useRef(null)
  useFrame(({clock})=>{if(mesh.current)mesh.current.scale.setScalar((active?1.25:1)*(motion&&system.tone==='crimson'?1+Math.sin(clock.elapsedTime*3)*.22:1))})
  return <group><Billboard><mesh ref={mesh}><octahedronGeometry args={[.10,0]}/><meshBasicMaterial color={palette[system.tone]} toneMapped={false}/></mesh></Billboard><Html center zIndexRange={[20,10]} style={{pointerEvents:'none'}}><button type="button" id={`${instanceId}-node-${system.id}`} aria-controls={`${instanceId}-card-${system.id}`} aria-pressed={selected} aria-label={`${system.title}: ${system.status}, ${system.value} ${system.unit}`} className={`human-hotspot human-tone-${system.tone} ${active?'is-active':''}`} onPointerDown={e=>e.stopPropagation()} onPointerEnter={()=>onHover(system.id)} onPointerLeave={()=>onHover(null)} onFocus={()=>onFocus(system.id)} onBlur={()=>onFocus(null)} onClick={()=>onSelect(system.id)}><span/><small>{system.id.slice(0,2).toUpperCase()}</small></button></Html></group>
}
