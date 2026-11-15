import { test } from 'node:test'
import assert from 'node:assert/strict'
import { Box3, Vector3 } from 'three'
import { applyPose, createHumanRig } from './humanRig.js'
import { ANATOMY, JOINTS, POSES } from './rigConfig.js'
const world=node=>node.getWorldPosition(new Vector3())
const near=(a,b)=>assert.ok(Math.abs(a-b)<1e-6,`${a} != ${b}`)

test('human proportions, bilateral symmetry and complete anatomy',t=>{
  const rig=createHumanRig();t.after(()=>rig.dispose())
  const bounds=new Box3().setFromObject(rig.root),height=bounds.max.y-bounds.min.y
  assert.ok(height/ANATOMY.headHeight>=7.5&&height/ANATOMY.headHeight<=8)
  assert.ok(ANATOMY.hipHeight/ANATOMY.height>.5)
  for(const name of ['Shoulder','Elbow','Wrist','Hip','Knee','Ankle']) {
    const l=world(rig.joints[`left${name}`]),r=world(rig.joints[`right${name}`])
    near(l.x,-r.x);near(l.y,r.y);near(l.z,r.z)
  }
  for(const side of ['left','right'])for(const name of ['Palm','Foot','Heel','ThumbTip','Fingertip0','Fingertip1','Fingertip2','Fingertip3']) assert.ok(rig.root.getObjectByName(`${side}${name}`))
  for(const mesh of rig.root.children)assert.ok(mesh.position.toArray().every(Number.isFinite))
  assert.equal(Object.keys(rig.joints).length,Object.keys(JOINTS).length)
})
test('limbs form actual parent-child chains and joints remain at segment endpoints in every preset',t=>{
  const rig=createHumanRig();t.after(()=>rig.dispose())
  for(const side of ['left','right']) {
    assert.equal(rig.joints[`${side}Elbow`].parent,rig.joints[`${side}Shoulder`])
    assert.equal(rig.joints[`${side}Wrist`].parent,rig.joints[`${side}Elbow`])
    assert.equal(rig.joints[`${side}Knee`].parent,rig.joints[`${side}Hip`])
    assert.equal(rig.joints[`${side}Ankle`].parent,rig.joints[`${side}Knee`])
  }
  for(const pose of Object.values(POSES)) {
    applyPose(rig,pose)
    for(const side of ['left','right'])for(const [parent,child,length] of [['Shoulder','Elbow',ANATOMY.upperArm],['Elbow','Wrist',ANATOMY.forearm],['Hip','Knee',ANATOMY.thigh],['Knee','Ankle',ANATOMY.shin]]) {
      near(world(rig.joints[`${side}${parent}`]).distanceTo(world(rig.joints[`${side}${child}`])),length)
      const segment=rig.segments[`${side}${{Shoulder:'UpperArm',Elbow:'Forearm',Hip:'Thigh',Knee:'Shin'}[parent]}`]
      const end=segment.node.localToWorld(new Vector3(0,-.5,0))
      near(end.distanceTo(world(rig.joints[`${side}${child}`])),0)
    }
  }
})
test('independent rotation propagates to descendants and anatomical hotspots',t=>{
  const rig=createHumanRig();t.after(()=>rig.dispose())
  const wrist=world(rig.joints.leftWrist),right=world(rig.joints.rightWrist),bone=world(rig.anchors.skeletal),heart=world(rig.anchors.cardiovascular),brain=world(rig.anchors.psychological)
  applyPose(rig,{leftShoulder:[-60,0,40],leftElbow:[-70,0,0],leftHip:[-40,0,0],head:[0,40,0]})
  assert.ok(world(rig.joints.leftWrist).distanceTo(wrist)>1)
  near(world(rig.joints.rightWrist).distanceTo(right),0)
  assert.ok(world(rig.anchors.skeletal).distanceTo(bone)>.1)
  assert.ok(world(rig.anchors.psychological).distanceTo(brain)>.1)
  near(world(rig.anchors.cardiovascular).distanceTo(heart),0)
  applyPose(rig,{})
  near(world(rig.joints.leftWrist).distanceTo(wrist),0)
})
test('joint limits clamp unsafe values and handle malformed angles',t=>{
  const rig=createHumanRig();t.after(()=>rig.dispose())
  applyPose(rig,{leftElbow:[-999,NaN,Infinity],leftKnee:[-20,50,50]})
  near(rig.joints.leftElbow.rotation.x,-145*Math.PI/180)
  near(rig.joints.leftElbow.rotation.y,0)
  near(rig.joints.leftKnee.rotation.x,0)
  near(rig.joints.leftKnee.rotation.y,0)
  applyPose(rig,{leftKnee:[999,0,0]})
  near(rig.joints.leftKnee.rotation.x,140*Math.PI/180)
})
