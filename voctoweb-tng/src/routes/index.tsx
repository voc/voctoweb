import { createFileRoute } from '@tanstack/react-router'
import { Search } from 'lucide-react'
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
        {/* TODO: real search — disabled placeholder for now */}
        <div className="mt-4 flex max-w-xl items-center gap-2 rounded-lg border border-border bg-card px-3 py-2 text-muted-foreground">
          <Search size={18} aria-hidden />
          <input
            disabled
            placeholder="Search — coming soon"
            className="w-full bg-transparent outline-none placeholder:text-muted-foreground"
          />
        </div>
      </section>
      <PromotedSection />
      <Stats />
      <RecentlyAdded />
    </main>
  )
}
