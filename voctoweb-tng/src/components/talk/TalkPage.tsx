import { getRouteApi } from '@tanstack/react-router'
import { createServerFn } from '@tanstack/react-start'
import { eq } from 'drizzle-orm'
import { Downloads } from '#/components/talk/Downloads.tsx'
import { db } from '#/db/index.ts'
import { conferences, events, recordings } from '#/db/schema.ts'
import { mapRecording } from '#/lib/media.ts'

export const getTalk = createServerFn({ method: 'GET' })
  .validator((slug: string) => slug)
  .handler(async ({ data: slug }) => {
    const [talk] = await db
      .select({
        id: events.id,
        title: events.title,
        description: events.description,
        conferenceId: events.conferenceId,
      })
      .from(events)
      .where(eq(events.slug, slug))
      .limit(1)
    if (!talk) return null

    const [conference] = talk.conferenceId
      ? await db
          .select({
            acronym: conferences.acronym,
            title: conferences.title,
            recordingsPath: conferences.recordingsPath,
            imagesPath: conferences.imagesPath,
          })
          .from(conferences)
          .where(eq(conferences.id, talk.conferenceId))
          .limit(1)
      : []

    const raw = await db
      .select({
        id: recordings.id,
        mimeType: recordings.mimeType,
        filename: recordings.filename,
        folder: recordings.folder,
        language: recordings.language,
        width: recordings.width,
        height: recordings.height,
        size: recordings.size,
        html5: recordings.html5,
      })
      .from(recordings)
      .where(eq(recordings.eventId, talk.id))

    return {
      id: talk.id,
      title: talk.title,
      description: talk.description,
      conference: conference
        ? { acronym: conference.acronym, title: conference.title }
        : null,
      recordings: conference ? raw.map((r) => mapRecording(r, conference)) : [],
    }
  })

const route = getRouteApi('/v/$slug')

export function TalkPage() {
  const talk = route.useLoaderData()
  const video = talk.recordings
    .filter((r) => r.kind === 'video' && r.html5)
    .sort((a, b) => (b.width ?? 0) - (a.width ?? 0))[0]

  return (
    <main>
      <section>[ConferenceHeader]</section>
      <h1>{talk.title}</h1>
      <section>[Speakers]</section>
      {video ? (
        <video controls preload="metadata">
          <source src={video.url} type={video.mimeType} />
        </video>
      ) : (
        <section>[no video recording]</section>
      )}
      <section>[Metadata]</section>
      {talk.description && (
        <div>
          {talk.description.split(/\n\n+/).map((para, i) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: static, non-reordering list
            <p key={i}>{para}</p>
          ))}
        </div>
      )}
      <Downloads />
      <section>[Share]</section>
      <section>[Tags]</section>
    </main>
  )
}
