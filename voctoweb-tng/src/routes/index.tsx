import { createFileRoute } from '@tanstack/react-router'
import { PromotedSection, getPromotedTalks } from '#/components/home/PromotedSection.tsx'
import { Stats, getStats } from '#/components/home/Stats.tsx'

export const Route = createFileRoute('/')({
  loader: async () => {
    const [stats, promoted] = await Promise.all([getStats(), getPromotedTalks()])
    return { stats, promoted }
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
      <section>[RecentlyAdded]</section>
    </main>
  )
}
