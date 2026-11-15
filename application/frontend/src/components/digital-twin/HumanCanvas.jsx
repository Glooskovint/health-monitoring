import { Component, useEffect, useRef, useState } from 'react'
import { Canvas } from '@react-three/fiber'
import { OrbitControls } from '@react-three/drei'
import HumanModel from './HumanModel.jsx'
class Boundary extends Component {
  state={failed:false}
  static getDerivedStateFromError(){return {failed:true}}
  render(){return this.state.failed?<Fallback/>:this.props.children}
}
function Fallback(){return <div className="human-fallback" role="status">WebGL no disponible. Las tarjetas y los controles de pose siguen accesibles.</div>}
const camera={position:[0,.2,15.8],fov:40,near:.1,far:60}
const renderer={alpha:true,antialias:true,powerPreference:'low-power'}
export default function HumanCanvas({autoRotate,onToggleRotate,reducedMotion,...modelProps}) {
  const container=useRef(null),controls=useRef(null)
  const [visible,setVisible]=useState(true),[pageVisible,setPageVisible]=useState(true)
  useEffect(()=>{
    const observer=new IntersectionObserver(([entry])=>setVisible(entry.isIntersecting));if(container.current)observer.observe(container.current)
    const sync=()=>setPageVisible(!document.hidden);document.addEventListener('visibilitychange',sync);sync()
    return()=>{observer.disconnect();document.removeEventListener('visibilitychange',sync)}
  },[])
  const motion=visible&&pageVisible&&!reducedMotion&&autoRotate
  return <div ref={container} className="human-viewport"><Boundary><Canvas camera={camera} gl={renderer} dpr={[1,1.5]} frameloop={motion?'always':'demand'} shadows fallback={<Fallback/>} onCreated={({gl})=>gl.setClearColor('#000000',0)}><ambientLight intensity={.7}/><directionalLight position={[4,8,6]} color="#00f0ff" intensity={2} castShadow shadow-mapSize={[1024,1024]} shadow-camera-left={-5} shadow-camera-right={5} shadow-camera-top={5} shadow-camera-bottom={-5} shadow-normalBias={.03}/><directionalLight position={[-4,3,-5]} color="#a4c5ff" intensity={1.4}/><HumanModel {...modelProps} motion={motion}/><mesh rotation={[-Math.PI/2,0,0]} position={[0,-3.845,0]} receiveShadow><planeGeometry args={[18,18]}/><shadowMaterial transparent opacity={.25}/></mesh><OrbitControls ref={controls} makeDefault autoRotate={motion&&!modelProps.active} autoRotateSpeed={.4} enablePan={false} minDistance={11} maxDistance={22} minPolarAngle={.15} maxPolarAngle={Math.PI-.15} enableDamping dampingFactor={.08}/></Canvas></Boundary><div className="human-view-actions"><button type="button" onClick={onToggleRotate} disabled={reducedMotion} aria-pressed={autoRotate}>{reducedMotion?'Movimiento reducido':autoRotate?'Ⅱ Pausar':'▶ Rotar'}</button><button type="button" onClick={()=>controls.current?.reset()}>↺ Cámara</button></div><div className="human-view-hint">ARRASTRAR / 360° · RUEDA / ZOOM · CLIC / ARTICULACIÓN</div></div>
}
