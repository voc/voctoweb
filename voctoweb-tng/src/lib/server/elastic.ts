import { env } from '#/env.ts'

// Mirrors Rails ElasticsearchEvent.query: a phrase match + an and-match + a
// fuzzy best_fields match across the indexed fields, wrapped in a function_score
// with a gauss recency decay on `date`. We only read `slug` back and hydrate the
// rest from Postgres.
function queryBody(term: string) {
  return {
    size: 60,
    _source: ['slug'],
    query: {
      function_score: {
        query: {
          bool: {
            should: [
              {
                multi_match: {
                  query: term,
                  fields: ['title', 'conference.title'],
                  type: 'phrase',
                  boost: 9000,
                },
              },
              {
                multi_match: {
                  query: term,
                  fields: ['title'],
                  operator: 'and',
                  boost: 4000,
                },
              },
              {
                multi_match: {
                  query: term,
                  fields: [
                    'title^20',
                    'subtitle^4',
                    'persons^5',
                    'slug^3',
                    'remote_id^3',
                    'conference.acronym^3',
                    'conference.title^3',
                    'description^2',
                    'subtitles.fulltext^1',
                  ],
                  type: 'best_fields',
                  operator: 'and',
                  fuzziness: 1,
                },
              },
            ],
          },
        },
        boost: 1.2,
        boost_mode: 'avg',
        functions: [{ gauss: { date: { scale: '730d', decay: 0.5 } } }],
      },
    },
  }
}

// Returns event slugs ranked by relevance, or null when ES is not configured or
// unreachable so the caller can fall back. Read-only: only issues `_search`.
export async function searchEventSlugs(term: string): Promise<string[] | null> {
  const base = env.ELASTICSEARCH_URL
  const index = env.ELASTICSEARCH_INDEX
  if (!base || !index) return null
  try {
    const res = await fetch(`${base}/${index}/_search`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(queryBody(term)),
    })
    if (!res.ok) return null
    const data = (await res.json()) as {
      hits?: { hits?: Array<{ _source?: { slug?: string } }> }
    }
    return (data.hits?.hits ?? [])
      .map((h) => h._source?.slug)
      .filter((s): s is string => !!s)
  } catch {
    return null
  }
}
