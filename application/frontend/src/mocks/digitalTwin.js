export function twinSystems(latest,history=[]) {
  return [
    {id:'cardiovascular',title:'Cardiovascular',value:latest?.heart_rate??75,unit:'BPM',status:'NOMINAL',tone:'cyan',trend:history.slice(-30).map(m=>({value:m.heart_rate})),note:'Telemetría cardíaca'},
    {id:'skeletal',title:'Sistema óseo',value:2.4,unit:'%',status:'ADVERTENCIA',tone:'amber',trend:[.6,.9,1.2,1.5,1.8,2.1,2.4].map(value=>({value})),note:'Pérdida de densidad · simulado'},
    {id:'immune',title:'Inmunológico',value:2.1,unit:'10³/µL',status:'CRÍTICO',tone:'crimson',trend:[5.1,4.8,4.2,3.7,3.1,2.7,2.1].map(value=>({value})),note:'Glóbulos blancos bajos · simulado'},
    {id:'psychological',title:'Salud psicológica',value:18,unit:'/100',status:'NOMINAL',tone:'violet',trend:[24,22,25,21,19,20,18].map(value=>({value})),note:'Estrés bajo · simulado'},
  ]
}
