import { posterUrl } from '#/lib/media.ts'
import {
  type ConfPaths,
  type RawRecording,
  type Recording,
  type RecordingKind,
  toRecording,
} from '#/models/recording.ts'

// The raw talk columns we select from the DB.
export interface RawTalk {
  id: number
  title: string | null
  description: string | null
  duration: number | null
  date: string | null
  releaseDate: string | null
  viewCount: number | null
  link: string | null
  doi: string | null
  posterFilename: string | null
}

// Conference context needed to build a talk: paths (for URLs) plus the bits we
// surface on the talk itself.
export type TalkConference = ConfPaths & {
  acronym: string | null
  title: string | null
}

// Ready-to-use talk: recordings resolved and grouped by kind, poster resolved.
export interface Talk {
  id: number
  title: string
  description: string | null
  duration: number | null
  date: string | null
  releaseDate: string | null
  viewCount: number | null
  link: string | null
  doi: string | null
  poster: string | null
  conference: { acronym: string | null; title: string | null } | null
  media: {
    video: Recording[]
    audio: Recording[]
    subtitle: Recording[]
    other: Recording[]
  }
}

export function toTalk(
  raw: RawTalk,
  conference: TalkConference | null,
  rawRecordings: RawRecording[],
): Talk {
  const recordings = conference
    ? rawRecordings.map((r) => toRecording(r, conference))
    : []
  const byKind = (kind: RecordingKind) =>
    recordings.filter((r) => r.kind === kind)
  return {
    id: raw.id,
    title: raw.title ?? '',
    description: raw.description,
    duration: raw.duration,
    date: raw.date,
    releaseDate: raw.releaseDate,
    viewCount: raw.viewCount,
    link: raw.link,
    doi: raw.doi,
    poster: conference
      ? posterUrl(raw.posterFilename, conference.imagesPath)
      : null,
    conference: conference
      ? { acronym: conference.acronym, title: conference.title }
      : null,
    media: {
      video: byKind('video').sort((a, b) => (b.width ?? 0) - (a.width ?? 0)),
      audio: byKind('audio'),
      subtitle: byKind('subtitle'),
      other: byKind('other'),
    },
  }
}
