import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({ component: Home })

// Layout skeleton only — each bracketed block becomes its own component (and
// owns its own data) later. No data fetching here on purpose.
function Home() {
  return (
    <main>
      <h1>media.ccc.de</h1>
      <section>[Search]</section>
      <section>[PromotedSection]</section>
      <section>[Stats]</section>
      <section>[RecentlyAdded]</section>
    </main>
  )
}
