import { getRouteApi } from '@tanstack/react-router'

const route = getRouteApi('/v/$slug')

export function Downloads() {
  const media = route.useLoaderData({ select: (d) => d.media })
  const recordings = [
    ...media.video,
    ...media.audio,
    ...media.subtitle,
    ...media.other,
  ]
  if (recordings.length === 0) return null

  const sorted = [...recordings].sort((a, b) =>
    a.mimeType.localeCompare(b.mimeType),
  )

  return (
    <section>
      <h2 className="mb-3 text-lg font-semibold tracking-tight">Downloads</h2>
      <ul className="flex flex-wrap gap-2">
        {sorted.map((r) => (
          <li key={r.id}>
            <a
              href={r.url}
              className="inline-flex rounded-md border border-border bg-card px-3 py-1.5 text-sm text-muted-foreground transition-colors hover:border-primary hover:text-foreground"
            >
              {[r.mimeType, r.language || null, r.resolution, r.sizeLabel]
                .filter(Boolean)
                .join(' · ')}
            </a>
          </li>
        ))}
      </ul>
    </section>
  )
}
