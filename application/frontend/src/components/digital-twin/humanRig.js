import { Group, Mesh, MeshStandardMaterial, SphereGeometry, CylinderGeometry, MathUtils } from 'three'

import { ANATOMY, JOINTS } from './rigConfig.js'
export function setWireframe(rig, enabled) { rig.material.wireframe = enabled }

export function applyPose(rig,pose={}) {
  for(const [name,config] of Object.entries(JOINTS)) {
    const angles=config.limits.map(([min,max],axis)=>MathUtils.degToRad(MathUtils.clamp(Number.isFinite(pose[name]?.[axis])?pose[name][axis]:0,min,max)))
    rig.joints[name].rotation.set(...angles)
  }
  rig.root.updateMatrixWorld(true)
}

/** Hierarchical primitive rig. Y is up; +Z is anterior. Units are head heights. */
export function createHumanRig() {
  const root=new Group();root.name='Human'
  const joints={},anchors={},segments={}
  const sphere=new SphereGeometry(1,20,12), taper=new CylinderGeometry(1,.78,1,16)
  const material=new MeshStandardMaterial({color:'#557d89',emissive:'#00f0ff',emissiveIntensity:.13,roughness:.55,metalness:.25})
  const detailMaterial=new MeshStandardMaterial({color:'#0b263c',emissive:'#00f0ff',emissiveIntensity:.35,roughness:.4})
  const group=(parent,name,position)=>{const node=new Group();node.name=name;node.position.set(...position);parent.add(node);return node}
  const mesh=(parent,name,geometry,position,scale,mat=material)=>{const node=new Mesh(geometry,mat);node.name=name;node.position.set(...position);node.scale.set(...scale);node.castShadow=true;node.receiveShadow=true;parent.add(node);return node}
  const ellipsoid=(parent,name,position,scale,mat)=>mesh(parent,name,sphere,position,scale,mat)
  const joint=(parent,name,position,radius)=>{const node=group(parent,name,position);joints[name]=node;if(radius)ellipsoid(node,`${name}.seal`,[0,0,0],[radius,radius,radius]);return node}
  const anchor=(parent,name,position)=>{anchors[name]=group(parent,`anchor.${name}`,position)}
  const segment=(parent,name,length,radius)=>{const node=mesh(parent,name,taper,[0,-length/2,0],[radius,length,radius]);segments[name]={node,length,radius};return node}

  const pelvis=group(root,'Pelvis',[0,4.3,0])
  ellipsoid(pelvis,'pelvic volume',[0,0,0],[.72,.48,.43])
  const torso=group(root,'Torso',[0,0,0])
  ellipsoid(torso,'abdomen',[0,4.95,0],[.61,.72,.38])
  ellipsoid(torso,'rib cage',[0,5.78,0],[.88,.85,.46])
  ellipsoid(torso,'upper thorax',[0,6.18,-.015],[.93,.38,.38])
  mesh(root,'Neck',taper,[0,6.65,0],[.21,.42,.21])
  const head=joint(root,'head',[0,6.86,0])
  ellipsoid(head,'cranium',[0,.39,0],[.355,.5,.39])
  ellipsoid(head,'jaw',[0,.12,.055],[.28,.28,.30])
  ellipsoid(head,'nose',[0,.3,.37],[.065,.1,.10])
  for(const side of [-1,1]){
    ellipsoid(head,`ear.${side}`,[side*.35,.35,0],[.065,.12,.085])
    ellipsoid(head,`eye.${side}`,[side*.125,.43,.357],[.06,.022,.025],detailMaterial)
  }
  anchor(head,'psychological',[0,.55,.46])
  anchor(torso,'cardiovascular',[-.2,5.93,.47])
  anchor(torso,'immune',[.34,5.05,.4])

  for(const [side,sign] of [['left',1],['right',-1]]) {
    const arm=joint(torso,`${side}Shoulder`,[sign*.96,6.23,0],.29)
    segment(arm,`${side}UpperArm`,ANATOMY.upperArm,.265)
    const elbow=joint(arm,`${side}Elbow`,[0,-ANATOMY.upperArm,0],.215)
    segment(elbow,`${side}Forearm`,ANATOMY.forearm,.225)
    const wrist=joint(elbow,`${side}Wrist`,[0,-ANATOMY.forearm,0],.15)
    ellipsoid(wrist,`${side}Palm`,[0,-.20,.025],[.19,.27,.105])
    for(let finger=0;finger<4;finger++) {
      const length=[.19,.25,.23,.16][finger], x=(finger-1.5)*.082
      const digit=group(wrist,`${side}Finger${finger}`,[x,-.38,.025])
      segment(digit,`${side}Phalanx${finger}`,length,.044)
      ellipsoid(digit,`${side}Fingertip${finger}`,[0,-length,0],[.035,.045,.035])
    }
    const thumb=group(wrist,`${side}Thumb`,[sign*.16,-.12,.035]);thumb.rotation.z=sign*.6
    segment(thumb,`${side}ThumbBone`,.22,.065)
    ellipsoid(thumb,`${side}ThumbTip`,[0,-.22,0],[.055,.07,.055])

    const hip=joint(pelvis,`${side}Hip`,[sign*.43,-.25,0],.33)
    segment(hip,`${side}Thigh`,ANATOMY.thigh,.335)
    const knee=joint(hip,`${side}Knee`,[0,-ANATOMY.thigh,0],.265)
    ellipsoid(knee,`${side}Patella`,[0,.01,.17],[.18,.19,.13])
    segment(knee,`${side}Shin`,ANATOMY.shin,.265)
    ellipsoid(knee,`${side}Calf`,[0,-.48,-.055],[.26,.49,.23])
    const ankle=joint(knee,`${side}Ankle`,[0,-ANATOMY.shin,0],.185)
    ellipsoid(ankle,`${side}Heel`,[0,-.21,-.06],[.23,.23,.26])
    ellipsoid(ankle,`${side}Foot`,[0,-.25,.22],[.25,.18,.49])
    if(side==='left')anchor(hip,'skeletal',[0,-.4,.35])
  }
  const rig={root,joints,anchors,segments,material,dispose:()=>{sphere.dispose();taper.dispose();material.dispose();detailMaterial.dispose()}}
  applyPose(rig)
  return rig
}
