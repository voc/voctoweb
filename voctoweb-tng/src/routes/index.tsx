import { createFileRoute } from '@tanstack/react-router'
import { PromotedSection, getPromotedTalks } from '#/components/home/PromotedSection.tsx'
import { RecentlyAdded, getRecentConferences } from '#/components/home/RecentlyAdded.tsx'
import { Stats, getStats } from '#/components/home/Stats.tsx'

export const Route = createFileRoute('/')({
  loader: async () => {
    const [stats, promoted, recent] = await Promise.all([
      getStats(),
      getPromotedTalks(),
      getRecentConferences(),
    ])
    return { stats, promoted, recent }
  },
  component: Home,
})

function Home() {
  return (
    <main>
      <h1>media.ccc.de</h1>
      <section>[Search]</section>
      <PromotedSection />
      <Stats />
      <RecentlyAdded />
    </main>
  )
}
