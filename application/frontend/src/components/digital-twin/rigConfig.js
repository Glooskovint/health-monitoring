export const ANATOMY = Object.freeze({ height:7.75, headHeight:1, hipHeight:4.05, thigh:1.82, shin:1.75, upperArm:1.28, forearm:1.10 })
export const JOINTS = {
  head:{label:'Cabeza',limits:[[-35,35],[-65,65],[-25,25]]},
  leftShoulder:{label:'Hombro izquierdo',limits:[[-150,60],[-60,60],[-15,160]]},
  rightShoulder:{label:'Hombro derecho',limits:[[-150,60],[-60,60],[-160,15]]},
  leftElbow:{label:'Codo izquierdo',limits:[[-145,0],[-20,20],[0,0]]},
  rightElbow:{label:'Codo derecho',limits:[[-145,0],[-20,20],[0,0]]},
  leftWrist:{label:'Muñeca izquierda',limits:[[-60,60],[-45,45],[-25,25]]},
  rightWrist:{label:'Muñeca derecha',limits:[[-60,60],[-45,45],[-25,25]]},
  leftHip:{label:'Cadera izquierda',limits:[[-100,30],[-35,35],[-10,45]]},
  rightHip:{label:'Cadera derecha',limits:[[-100,30],[-35,35],[-45,10]]},
  leftKnee:{label:'Rodilla izquierda',limits:[[0,140],[0,0],[0,0]]},
  rightKnee:{label:'Rodilla derecha',limits:[[0,140],[0,0],[0,0]]},
  leftAnkle:{label:'Tobillo izquierdo',limits:[[-25,40],[-15,15],[-15,15]]},
  rightAnkle:{label:'Tobillo derecho',limits:[[-25,40],[-15,15],[-15,15]]},
}
export const POSES = {
  neutral:{},
  inspection:{leftShoulder:[0,0,65],rightShoulder:[0,0,-65],leftElbow:[-20,0,0],rightElbow:[-20,0,0]},
  salute:{rightShoulder:[-20,0,-80],rightElbow:[-125,0,0],head:[0,-12,0]},
  step:{leftHip:[-30,0,0],leftKnee:[15,0,0],rightHip:[20,0,0],rightKnee:[40,0,0],leftShoulder:[20,0,0],rightShoulder:[-25,0,0]},
}
