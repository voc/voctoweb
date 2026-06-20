// Pure display formatters (client-safe, no env).

export function formatDuration(seconds: number | null): string {
  if (!seconds) return '0:00'
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = seconds % 60
  const mm = String(m).padStart(2, '0')
  const ss = String(s).padStart(2, '0')
  return h > 0 ? `${h}:${mm}:${ss}` : `${m}:${ss}`
}

export function formatViews(n: number | null): string {
  const v = n ?? 0
  if (v >= 1_000_000) return `${(v / 1_000_000).toFixed(1)}M`
  if (v >= 1_000) return `${(v / 1_000).toFixed(1)}k`
  return String(v)
}

// Timestamps are naive UTC strings (drizzle `mode: 'string'`). Parse as UTC and
// format in UTC with a pinned locale, so SSR and client agree and the day never
// drifts. en-CA yields YYYY-MM-DD; swap the options/locale to change the look.
const dateFormat = new Intl.DateTimeFormat('en-CA', {
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
  timeZone: 'UTC',
})

export function formatDate(d: string | null): string {
  if (!d) return ''
  const date = new Date(`${d.replace(' ', 'T')}Z`)
  return Number.isNaN(date.getTime()) ? '' : dateFormat.format(date)
}
