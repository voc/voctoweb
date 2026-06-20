import { getRouteApi } from '@tanstack/react-router'
import { createServerFn } from '@tanstack/react-start'
import { and, desc, eq, isNotNull } from 'drizzle-orm'
import { db } from '#/db/index.ts'
import { conferences, events } from '#/db/schema.ts'

export const getConference = createServerFn({ method: 'GET' })
  .validator((acronym: string) => acronym)
  .handler(async ({ data: acronym }) => {
    const [conference] = await db
      .select({
        id: conferences.id,
        acronym: conferences.acronym,
        title: conferences.title,
      })
      .from(conferences)
      .where(eq(conferences.acronym, acronym))
      .limit(1)
    if (!conference) return null

    // TODO: user-selectable sort (name / date / duration / views) like prod.
    // Probably TanStack Table once we want sortable column headers.
    const talks = await db
      .select({ id: events.id, slug: events.slug, title: events.title })
      .from(events)
      .where(and(eq(events.conferenceId, conference.id), isNotNull(events.releaseDate)))
      .orderBy(desc(events.viewCount))
    return { ...conference, talks }
  })

const route = getRouteApi('/c/$acronym')

export function ConferencePage() {
  const conference = route.useLoaderData()
  return (
    <main>
      <h1>{conference.title ?? conference.acronym}</h1>
      <p>{conference.talks.length} talks</p>
      <ul>
        {conference.talks.map((t) => (
          <li key={t.id}>
            <a href={`/v/${t.slug}`}>{t.title}</a>
          </li>
        ))}
      </ul>
    </main>
  )
}
