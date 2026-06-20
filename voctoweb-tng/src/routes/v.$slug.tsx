import { createFileRoute, notFound } from '@tanstack/react-router'
import { TalkPage, getTalk } from '#/components/talk/TalkPage.tsx'

export const Route = createFileRoute('/v/$slug')({
  loader: async ({ params }) => {
    const talk = await getTalk({ data: params.slug })
    if (!talk) throw notFound()
    return talk
  },
  component: TalkPage,
  notFoundComponent: () => <p>Talk not found.</p>,
})
