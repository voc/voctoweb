import { getRouteApi } from '@tanstack/react-router'
import { createServerFn } from '@tanstack/react-start'
import { eq } from 'drizzle-orm'
import { db } from '#/db/index.ts'
import { events } from '#/db/schema.ts'

export const getTalk = createServerFn({ method: 'GET' })
  .validator((slug: string) => slug)
  .handler(async ({ data: slug }) => {
    const [talk] = await db
      .select({
        id: events.id,
        title: events.title,
        description: events.description,
      })
      .from(events)
      .where(eq(events.slug, slug))
      .limit(1)
    return talk ?? null
  })

const route = getRouteApi('/v/$slug')

export function TalkPage() {
  const talk = route.useLoaderData()
  return (
    <main>
      <section>[ConferenceHeader]</section>
      <h1>{talk.title}</h1>
      <section>[Speakers]</section>
      <section>[Player]</section>
      <section>[Metadata]</section>
      {talk.description && (
        <div>
          {talk.description.split(/\n\n+/).map((para, i) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: static, non-reordering list
            <p key={i}>{para}</p>
          ))}
        </div>
      )}
      <section>[Downloads]</section>
      <section>[Share]</section>
      <section>[Tags]</section>
    </main>
  )
}
