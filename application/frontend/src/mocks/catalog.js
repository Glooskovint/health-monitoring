// Fictional mission catalog. The API contract does not define operations or crew endpoints.
export const operations = [
  { id: 'artemis', name: 'Artemis IV', code: 'ART-04', destination: 'Órbita lunar', phase: 'Exploración', day: 18, duration: 30, color: '#00f0ff', orbit: '384 400', crewIds: [1, 2, 3] },
  { id: 'horizon', name: 'Horizon', code: 'HRZ-12', destination: 'Estación orbital', phase: 'Investigación', day: 42, duration: 90, color: '#8b5cf6', orbit: '408', crewIds: [4, 5, 6] },
  { id: 'ares', name: 'Ares Pathfinder', code: 'ARS-01', destination: 'Tránsito a Marte', phase: 'Tránsito', day: 76, duration: 210, color: '#ffb300', orbit: '54.6 M', crewIds: [7, 8] },
]
const people = [
  ['Elena Martínez', 'Comandante', 'PE', 39, 'artemis', 76, .16],
  ['Noah Williams', 'Especialista EVA', 'US', 34, 'artemis', 112, .73],
  ['Aiko Tanaka', 'Oficial científica', 'JP', 36, 'artemis', 72, .22],
  ['Lucas Ferreira', 'Comandante', 'BR', 42, 'horizon', 70, .12],
  ['Sofia Andersson', 'Ingeniera de vuelo', 'SE', 31, 'horizon', 88, .42],
  ['Amir Hassan', 'Oficial médico', 'AE', 38, 'horizon', 74, .18],
  ['Valentina Rossi', 'Comandante', 'IT', 40, 'ares', 80, .27],
  ['Daniel Kim', 'Especialista de misión', 'KR', 35, 'ares', 123, .84],
]
export const astronauts = people.map(([name, role, country, age, operationId, baseline, risk], i) => ({
  id: `00000000-0000-4000-8000-${String(i + 1).padStart(12, '0')}`,
  number: i + 1, name, role, country, age, operationId, baseline, risk,
  callsign: `ORB-${String(i + 1).padStart(2, '0')}`, bloodType: ['O+', 'A+', 'B+', 'O-'][i % 4],
}))
export const riskLevel = score => score >= .75 ? 'critical' : score >= .5 ? 'high' : score >= .3 ? 'medium' : 'low'
export const riskLabels = { low: 'Nominal', medium: 'Atención', high: 'Alto', critical: 'Crítico' }
export const statusColor = { low: '#43edcd', medium: '#ffb300', high: '#ff6d00', critical: '#ff2a6d' }
export const initials = name => name.split(' ').map(w => w[0]).slice(0, 2).join('')
