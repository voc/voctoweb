import { getRouteApi } from '@tanstack/react-router'
import { createServerFn } from '@tanstack/react-start'
import { sql } from 'drizzle-orm'
import { db } from '#/db/index.ts'
import { conferences, events, recordings } from '#/db/schema.ts'

export const getStats = createServerFn({ method: 'GET' }).handler(async () => {
  const [row] = await db
    .select({
      hours: sql<number>`(select coalesce(sum(${events.duration}), 0) / 3600 from ${events})`,
      files: sql<number>`(select count(*) from ${recordings})`,
      talks: sql<number>`(select count(*) from ${events})`,
      conferences: sql<number>`(select count(*) from ${conferences})`,
    })
    .from(sql`(select 1) as _`)
  return row
})

const home = getRouteApi('/')
const fmt = (n: number) => new Intl.NumberFormat('en-US').format(Number(n))

export function Stats() {
  const s = home.useLoaderData({ select: (d) => d.stats })
  return (
    <section>
      <p>
        {fmt(s.hours)} hours of content in {fmt(s.files)} files
      </p>
      <p>
        {fmt(s.talks)} talks across {fmt(s.conferences)} conferences
      </p>
    </section>
  )
}
