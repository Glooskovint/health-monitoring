import { Fragment, useEffect, useLayoutEffect, useState } from 'react'
import { createPortal } from '@react-three/fiber'
import { applyPose, createHumanRig, setWireframe } from './humanRig.js'
import Hotspot from './Hotspot.jsx'
export default function HumanModel({pose,wireframe,selectedJoint,onJointSelect,systems,...hotspotProps}) {
  const [rig]=useState(createHumanRig)
  useLayoutEffect(()=>{applyPose(rig,pose)},[rig,pose])
  useLayoutEffect(()=>{setWireframe(rig,wireframe)},[rig,wireframe])
  useEffect(()=>()=>rig.dispose(),[rig])
  function pick(event){event.stopPropagation();let node=event.object;while(node){if(rig.joints[node.name]){onJointSelect(node.name);return}node=node.parent}}
  const joint=rig.joints[selectedJoint]
  return <group position={[0,-3.88,0]}><primitive object={rig.root} dispose={null} onClick={pick}/>{joint&&createPortal(<mesh><sphereGeometry args={[.35,12,8]}/><meshBasicMaterial color="#00f0ff" wireframe transparent opacity={.22} depthWrite={false}/></mesh>,joint)}{systems.map(system=><Fragment key={system.id}>{createPortal(<Hotspot system={system} active={hotspotProps.active===system.id} selected={hotspotProps.selected===system.id} onHover={hotspotProps.onHover} onFocus={hotspotProps.onFocus} onSelect={hotspotProps.onSelect} motion={hotspotProps.motion} instanceId={hotspotProps.instanceId}/>,rig.anchors[system.id])}</Fragment>)}</group>
}
