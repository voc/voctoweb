import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/v/$slug')({ component: TalkPage })

// Layout skeleton only — each block becomes a real component (and gets its data)
// next. Loader + 404 + the player come in following passes.
function TalkPage() {
  return (
    <main>
      <section>[ConferenceHeader]</section>
      <h1>[Title]</h1>
      <section>[Speakers]</section>
      <section>[Player]</section>
      <section>[Metadata]</section>
      <section>[Description]</section>
      <section>[Downloads]</section>
      <section>[Share]</section>
      <section>[Tags]</section>
    </main>
  )
}
