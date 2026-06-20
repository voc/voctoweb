import { getRouteApi } from '@tanstack/react-router'

const route = getRouteApi('/v/$slug')

export function Downloads() {
  const recordings = route.useLoaderData({ select: (d) => d.recordings })
  if (recordings.length === 0) return null

  const sorted = [...recordings].sort((a, b) =>
    a.mimeType.localeCompare(b.mimeType),
  )

  return (
    <section>
      <h2>Downloads</h2>
      <ul>
        {sorted.map((r) => (
          <li key={r.id}>
            <a href={r.url}>
              {[
                r.mimeType,
                r.language || null,
                r.width ? `${r.height}p` : null,
                r.size ? `${r.size} MB` : null,
              ]
                .filter(Boolean)
                .join(' · ')}
            </a>
          </li>
        ))}
      </ul>
    </section>
  )
}
