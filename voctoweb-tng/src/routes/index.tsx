import { createFileRoute } from '@tanstack/react-router'
import { SearchForm } from '#/components/SearchForm.tsx'
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
    <main className="mx-auto max-w-6xl space-y-12 px-4 py-8">
      <section>
        <h1 className="text-3xl font-bold tracking-tight">media.ccc.de</h1>
        <p className="mt-1 text-muted-foreground">
          Conference recordings from the Chaos Computer Club and friends.
        </p>
        <div className="mt-4">
          <SearchForm />
        </div>
      </section>
      <PromotedSection />
      <Stats />
      <RecentlyAdded />
    </main>
  )
}
