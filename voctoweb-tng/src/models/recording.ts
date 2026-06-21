import { env } from '#/env.ts'
import { languageLabel } from '#/lib/format.ts'
import { join } from '#/lib/media.ts'

export type RecordingKind = 'video' | 'audio' | 'subtitle' | 'other'

// The raw recording columns we select from the DB.
export interface RawRecording {
  id: number
  mimeType: string | null
  filename: string | null
  folder: string | null
  language: string | null
  width: number | null
  height: number | null
  size: number | null
  html5: boolean
}

// Conference path fields needed to resolve a recording's URL.
export interface ConfPaths {
  recordingsPath: string | null
  imagesPath: string | null
}

// Ready-to-use recording: URL resolved, kind classified, labels precomputed.
export interface Recording {
  id: number
  url: string
  mimeType: string
  language: string
  languageLabel: string
  width: number | null
  height: number | null
  resolution: string | null
  size: number | null
  sizeLabel: string | null
  html5: boolean
  kind: RecordingKind
}

function classify(mime: string | null): RecordingKind {
  if (!mime) return 'other'
  if (mime.startsWith('video/')) return 'video'
  if (mime.startsWith('audio/')) return 'audio'
  if (mime === 'text/vtt' || mime === 'application/x-subrip') return 'subtitle'
  return 'other'
}

export function toRecording(raw: RawRecording, conf: ConfPaths): Recording {
  const kind = classify(raw.mimeType)
  const url =
    kind === 'subtitle'
      ? `${env.STATIC_URL}/${join(conf.imagesPath, raw.filename)}`
      : `${env.CDN_URL}/${join(conf.recordingsPath, raw.folder, raw.filename)}`
  return {
    id: raw.id,
    url,
    mimeType: raw.mimeType ?? '',
    language: raw.language ?? '',
    languageLabel: languageLabel(raw.language),
    width: raw.width,
    height: raw.height,
    resolution: raw.height ? `${raw.height}p` : null,
    size: raw.size,
    sizeLabel: raw.size ? `${raw.size} MB` : null,
    html5: raw.html5,
    kind,
  }
}
