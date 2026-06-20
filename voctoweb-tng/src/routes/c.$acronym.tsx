import { createFileRoute, notFound } from '@tanstack/react-router'
import { ConferencePage, getConference } from '#/components/conference/ConferencePage.tsx'

export const Route = createFileRoute('/c/$acronym')({
  loader: async ({ params }) => {
    const conference = await getConference({ data: params.acronym })
    if (!conference) throw notFound()
    return conference
  },
  component: ConferencePage,
  notFoundComponent: () => <p>Conference not found.</p>,
})
