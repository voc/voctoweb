import { Link, getRouteApi } from '@tanstack/react-router'
import { createServerFn } from '@tanstack/react-start'
import { and, count, desc, eq, isNotNull } from 'drizzle-orm'
import { db } from '#/db/index.ts'
import { conferences, events } from '#/db/schema.ts'

const TALK_LIMIT = 3

// Mirrors the original: 9 conferences with the most recent releases, a few talks each.
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
      confs.map(async (c) => {
        const released = and(
          eq(events.conferenceId, c.id),
          isNotNull(events.releaseDate),
        )
        const [talks, totals] = await Promise.all([
          db
            .select({ id: events.id, slug: events.slug, title: events.title })
            .from(events)
            .where(released)
            .orderBy(desc(events.releaseDate), desc(events.id))
            .limit(TALK_LIMIT),
          db.select({ total: count() }).from(events).where(released),
        ])
        return { ...c, talks, total: totals[0]?.total ?? 0 }
      }),
    )
  },
)

const home = getRouteApi('/')

export function RecentlyAdded() {
  const conferences = home.useLoaderData({ select: (d) => d.recent })
  return (
    <section>
      <h2>Recently added</h2>
      {conferences.map((c) => {
        const more = c.total - c.talks.length
        return (
          <div key={c.id}>
            <h3>
              <Link to="/c/$acronym" params={{ acronym: c.acronym ?? '' }}>
                {c.title}
              </Link>
            </h3>
            <ul>
              {c.talks.map((t) => (
                <li key={t.id}>
                  <Link to="/v/$slug" params={{ slug: t.slug ?? '' }}>
                    {t.title}
                  </Link>
                </li>
              ))}
            </ul>
            {more > 0 && (
              <Link to="/c/$acronym" params={{ acronym: c.acronym ?? '' }}>
                +{more} more
              </Link>
            )}
          </div>
        )
      })}
    </section>
  )
}
