import { getRouteApi } from '@tanstack/react-router'
import { createServerFn } from '@tanstack/react-start'
import { and, desc, eq, isNotNull } from 'drizzle-orm'
import { db } from '#/db/index.ts'
import { conferences, events } from '#/db/schema.ts'

// Mirrors prod: 9 conferences with the most recent releases, 3 talks each.
export const getRecentConferences = createServerFn({ method: 'GET' }).handler(
  async () => {
    const confs = await db
      .select({
        id: conferences.id,
        acronym: conferences.acronym,
        title: conferences.title,
      })
      .from(conferences)
      .where(isNotNull(conferences.eventLastReleasedAt))
      .orderBy(desc(conferences.eventLastReleasedAt))
      .limit(9)

    return Promise.all(
      confs.map(async (c) => ({
        ...c,
        talks: await db
          .select({ id: events.id, slug: events.slug, title: events.title })
          .from(events)
          .where(and(eq(events.conferenceId, c.id), isNotNull(events.releaseDate)))
          .orderBy(desc(events.releaseDate), desc(events.id))
          .limit(3),
      })),
    )
  },
)

const home = getRouteApi('/')

export function RecentlyAdded() {
  const conferences = home.useLoaderData({ select: (d) => d.recent })
  return (
    <section>
      <h2>Recently added</h2>
      {conferences.map((c) => (
        <div key={c.id}>
          <h3>
            <a href={`/c/${c.acronym}`}>{c.title}</a>
          </h3>
          <ul>
            {c.talks.map((t) => (
              <li key={t.id}>
                <a href={`/v/${t.slug}`}>{t.title}</a>
              </li>
            ))}
          </ul>
        </div>
      ))}
    </section>
  )
}
