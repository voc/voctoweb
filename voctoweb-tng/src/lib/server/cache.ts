import { QueryClient } from "@tanstack/query-core";

// Long-lived, server-only cache for database query results. This query client
// is shared across different requests unlike tanstack/start's own query client
// which is only used for a single request on the server-side (but reused on
// the client-side).
const serverCache = new QueryClient({
	defaultOptions: {
		queries: { staleTime: 60_000, gcTime: 5 * 60_000 },
	},
});

// `fetchQuery` returns the cached value when fresh, otherwise runs `queryFn` and
// caches it — and dedupes concurrent identical calls into a single DB hit.
export function cachedQuery<T>(
	queryKey: unknown[],
	queryFn: () => Promise<T>,
): Promise<T> {
	return serverCache.fetchQuery({ queryKey, queryFn });
}
