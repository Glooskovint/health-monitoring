import { useLanguage } from '../lib/language.jsx'
import { Area, AreaChart, Bar, BarChart, CartesianGrid, Cell, Legend, Line, LineChart, Pie, PieChart, ReferenceLine, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import { colors } from '../lib/colors.js'
const chartTheme = { backgroundColor: '#151b2b', border: '1px solid #3b494b', borderRadius: 4, color: '#dde2f7', fontFamily: 'JetBrains Mono, monospace', fontSize: 11 }
const axis = { fill: '#849495', fontSize: 10, fontFamily: 'JetBrains Mono, monospace' }
const clock = (value, locale) => new Date(value).toLocaleTimeString(locale, { hour: '2-digit', minute: '2-digit' })
export function Sparkline({ data, metric = 'heart_rate', color = colors.cyan, label = 'Tendencia' }) {
  
  return <div className="sparkline" role="img" aria-label={label}><ResponsiveContainer width="100%" height={52}><AreaChart data={data}><Area isAnimationActive={false} type="monotone" dataKey={metric} stroke={color} fill={color} fillOpacity={.08} strokeWidth={1.5} /><YAxis hide domain={['dataMin - 3', 'dataMax + 3']} /></AreaChart></ResponsiveContainer></div>
}
export function VitalChart({ data, series, unit, domain = ['auto', 'auto'], threshold, longRange = false }) {
  const { t, locale } = useLanguage()
  if (!data.length) return <div className="chart-empty">{t("Sin mediciones en este período")}</div>
  return <div className="chart-frame" role="img" aria-label={`${series.map(s => s.name).join(', ')} ${t("en el tiempo")}, ${unit}`}><ResponsiveContainer width="100%" height={230}><LineChart data={data} margin={{ top: 12, right: 14, bottom: 5, left: -15 }} accessibilityLayer>
    <CartesianGrid stroke="#4a90e222" strokeDasharray="3 6" vertical={false} />
    <XAxis dataKey="timestamp" tickFormatter={v => longRange ? new Date(v).toLocaleDateString(locale, { day:'2-digit', month:'2-digit' }) : clock(v, locale)} minTickGap={50} tick={axis} axisLine={false} tickLine={false} />
    <YAxis domain={domain} tick={axis} axisLine={false} tickLine={false} width={52} />
    <Tooltip contentStyle={chartTheme} itemStyle={{ color: '#dde2f7' }} labelFormatter={v => new Date(v).toLocaleString(locale)} formatter={(value, name) => [`${value} ${unit}`, name]} />
    <Legend iconType="plainline" wrapperStyle={{ fontSize: 11, paddingTop: 12 }} />
    {threshold !== undefined && <ReferenceLine y={threshold} stroke={colors.amber} strokeDasharray="4 4" label={{ value: t("Referencia demo"), fill: colors.amber, fontSize: 9, position: 'insideTopRight' }} />}
    {series.map(s => <Line key={s.key} type="monotone" dataKey={s.key} name={s.name} stroke={s.color || colors.cyan} dot={false} activeDot={{ r: 4 }} strokeWidth={2} isAnimationActive={false} />)}
  </LineChart></ResponsiveContainer></div>
}
export function Donut({ data, center, caption }) {
  
  return <div className="donut" role="img" aria-label={`${caption}: ${data.map(d => `${d.name} ${d.value}`).join(', ')}`}><ResponsiveContainer width="100%" height={180}><PieChart><Pie data={data} dataKey="value" nameKey="name" innerRadius={56} outerRadius={73} paddingAngle={4} stroke="none" isAnimationActive={false}>{data.map(d => <Cell key={d.name} fill={d.color} />)}</Pie><Tooltip contentStyle={chartTheme} itemStyle={{ color: '#dde2f7' }} /></PieChart></ResponsiveContainer><div className="donut-center"><strong>{center}</strong><small>{caption}</small></div></div>
}
export function Gauge({ value, max = 100, unit = '%', label, color = colors.cyan }) {
  
  const percent = Math.max(0, Math.min(max, value))
  return <div className="gauge" role="img" aria-label={`${label}: ${value}${unit}`}><ResponsiveContainer width="100%" height={140}><PieChart><Pie data={[{ value: percent }, { value: Math.max(0, max - percent) }]} dataKey="value" startAngle={180} endAngle={0} innerRadius={63} outerRadius={76} cy="83%" stroke="none" isAnimationActive={false}><Cell fill={color} /><Cell fill="#242a3a" /></Pie></PieChart></ResponsiveContainer><div className="gauge-value"><strong>{value}<small>{unit}</small></strong><span>{label}</span></div></div>
}
export function OperationBars({ data }) {
  const { t } = useLanguage()
  return <div role="img" aria-label={t("Estado de astronautas por operación")}><ResponsiveContainer width="100%" height={185}><BarChart data={data} margin={{ left: -20, right: 10 }} accessibilityLayer><CartesianGrid stroke="#4a90e222" vertical={false} /><XAxis dataKey="name" tick={axis} axisLine={false} tickLine={false} /><YAxis allowDecimals={false} tick={axis} axisLine={false} tickLine={false} /><Tooltip contentStyle={chartTheme} cursor={{ fill: '#ffffff05' }} /><Bar name="Nominal" dataKey="nominal" stackId="crew" fill={colors.green} maxBarSize={35} /><Bar name={t("Atención")} dataKey="attention" stackId="crew" fill={colors.amber} maxBarSize={35} /><Bar name={t("Riesgo alto")} dataKey="critical" stackId="crew" fill={colors.red} maxBarSize={35} radius={[3,3,0,0]} /></BarChart></ResponsiveContainer></div>
}
export function RiskBars({ data }) {
  const { t } = useLanguage()
  return <div role="img" aria-label={t("Riesgo simulado durante siete días")}><ResponsiveContainer width="100%" height={180}><BarChart data={data.map(d => ({ ...d, score: Math.round(d.risk_score * 100) }))} margin={{ left: -20, right: 5 }} accessibilityLayer><CartesianGrid stroke="#8b5cf622" vertical={false} /><XAxis dataKey="date" tickFormatter={d => d.slice(5)} tick={axis} axisLine={false} tickLine={false} /><YAxis domain={[0,100]} tick={axis} axisLine={false} tickLine={false} /><Tooltip contentStyle={chartTheme} formatter={v => [`${v}%`, t("Riesgo")]} /><Bar dataKey="score" name={t("Riesgo")} fill={colors.violet} radius={[3,3,0,0]} maxBarSize={30} /></BarChart></ResponsiveContainer></div>
}

