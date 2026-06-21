import { createFileRoute } from '@tanstack/react-router'
import { SearchPage, searchTalks } from '#/components/search/SearchPage.tsx'

export const Route = createFileRoute('/search')({
  validateSearch: (search: Record<string, unknown>): { q: string } => ({
    q: typeof search.q === 'string' ? search.q : '',
  }),
  loaderDeps: ({ search }) => ({ q: search.q }),
  loader: ({ deps }) => searchTalks({ data: deps.q }),
  component: SearchPage,
})
