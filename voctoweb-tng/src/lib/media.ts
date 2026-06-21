import { env } from '#/env.ts'

// Images/subtitles come from STATIC_URL, audio/video recordings from CDN_URL
// (validated in src/env.ts). Matches the Rails models.

export type RecordingKind = 'video' | 'audio' | 'subtitle' | 'other'

export function recordingKind(mime: string | null): RecordingKind {
  if (!mime) return 'other'
  if (mime.startsWith('video/')) return 'video'
  if (mime.startsWith('audio/')) return 'audio'
  if (mime === 'text/vtt' || mime === 'application/x-subrip') return 'subtitle'
  return 'other'
}

// Drops the empty `folder` segment; tolerant of drizzle's nullable column types.
const join = (...parts: Array<string | null>) => parts.filter(Boolean).join('/')

type ConfPaths = { recordingsPath: string | null; imagesPath: string | null }

type RawRecording = {
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

// Ready-to-use recording: URL resolved, kind classified.
export interface Recording {
  id: number
  url: string
  mimeType: string
  language: string
  width: number | null
  height: number | null
  size: number | null
  html5: boolean
  kind: RecordingKind
}

export function mapRecording(r: RawRecording, conf: ConfPaths): Recording {
  const kind = recordingKind(r.mimeType)
  const url =
    kind === 'subtitle'
      ? `${env.STATIC_URL}/${join(conf.imagesPath, r.filename)}`
      : `${env.CDN_URL}/${join(conf.recordingsPath, r.folder, r.filename)}`
  return {
    id: r.id,
    url,
    mimeType: r.mimeType ?? '',
    language: r.language ?? '',
    width: r.width,
    height: r.height,
    size: r.size,
    html5: r.html5,
    kind,
  }
}

// Event thumbnail URL, or null if it has none. No logo fallback on purpose —
// conference logos rarely work as thumbnails.
export function thumbUrl(
  thumbFilename: string | null,
  imagesPath: string | null,
): string | null {
  return thumbFilename
    ? `${env.STATIC_URL}/${join(imagesPath, thumbFilename)}`
    : null
}
