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

// Recording language codes are ISO 639-2 (e.g. `deu`), sometimes joined for
// multi-language tracks (`deu-eng-fra`). Map the common ones; fall back to the
// uppercased code so an unknown language still reads sensibly.
const LANGUAGE_NAMES: Record<string, string> = {
  deu: 'German',
  eng: 'English',
  fra: 'French',
  spa: 'Spanish',
  ita: 'Italian',
  nld: 'Dutch',
  rus: 'Russian',
  gsw: 'Swiss German',
}

export function languageLabel(code: string | null): string {
  if (!code) return ''
  return code
    .split('-')
    .map((c) => LANGUAGE_NAMES[c] ?? c.toUpperCase())
    .join(' / ')
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
