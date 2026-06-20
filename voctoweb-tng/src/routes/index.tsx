import { createFileRoute } from '@tanstack/react-router'
import { Stats, getStats } from '#/components/home/Stats.tsx'

export const Route = createFileRoute('/')({
  loader: async () => ({
    stats: await getStats(),
  }),
  component: Home,
})

function Home() {
  return (
    <main>
      <h1>media.ccc.de</h1>
      <section>[Search]</section>
      <section>[PromotedSection]</section>
      <Stats />
      <section>[RecentlyAdded]</section>
    </main>
  )
}
