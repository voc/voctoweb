import { getRouteApi } from "@tanstack/react-router";
import { createServerFn } from "@tanstack/react-start";
import { and, desc, eq, ilike, inArray, isNotNull, or } from "drizzle-orm";
import { SearchForm } from "#/components/SearchForm.tsx";
import { TalkGrid } from "#/components/TalkCard.tsx";
import { db } from "#/db/index.ts";
import { conferences, events } from "#/db/schema.ts";
import { thumbUrl } from "#/lib/media.ts";
import { cachedQuery } from "#/lib/server/cache.ts";
import { searchEventSlugs } from "#/lib/server/elastic.ts";

const LIMIT = 60;

const cardColumns = {
	id: events.id,
	slug: events.slug,
	title: events.title,
	thumbFilename: events.thumbFilename,
	imagesPath: conferences.imagesPath,
} as const;

type CardRow = {
	id: number;
	slug: string | null;
	title: string | null;
	thumbFilename: string | null;
	imagesPath: string | null;
};

const toCard = (r: CardRow) => ({
	id: r.id,
	slug: r.slug,
	title: r.title,
	thumbUrl: thumbUrl(r.thumbFilename, r.imagesPath),
});

// Hydrate ES-ranked slugs into card data from Postgres, preserving ES order and
// dropping any slug missing locally (ES may be ahead of the local DB dump).
async function hydrate(slugs: string[]) {
	if (slugs.length === 0) return [];
	const rows = await db
		.select(cardColumns)
		.from(events)
		.innerJoin(conferences, eq(events.conferenceId, conferences.id))
		.where(inArray(events.slug, slugs));
	const bySlug = new Map(rows.map((r) => [r.slug, r]));
	return slugs.flatMap((slug) => {
		const r = bySlug.get(slug);
		return r ? [toCard(r)] : [];
	});
}

// Fallback substring match when ES isn't configured/reachable.
async function ilikeSearch(term: string) {
	const pattern = `%${term.replace(/[\\%_]/g, "\\$&")}%`;
	const rows = await db
		.select(cardColumns)
		.from(events)
		.innerJoin(conferences, eq(events.conferenceId, conferences.id))
		.where(
			and(
				isNotNull(events.releaseDate),
				or(
					ilike(events.title, pattern),
					ilike(conferences.acronym, pattern),
					ilike(conferences.title, pattern),
				),
			),
		)
		.orderBy(desc(events.viewCount))
		.limit(LIMIT);
	return rows.map(toCard);
}

export const searchTalks = createServerFn({ method: "GET" })
	.validator((q: string) => q)
	.handler(({ data: q }) =>
		cachedQuery(["search", q], async () => {
			const term = q.trim();
			if (!term) return [];
			const slugs = await searchEventSlugs(term);
			return slugs ? hydrate(slugs) : ilikeSearch(term);
		}),
	);

const route = getRouteApi("/search");

export function SearchPage() {
	const { q } = route.useSearch();
	const results = route.useLoaderData();
	const count = results.length === LIMIT ? `${LIMIT}+` : results.length;

	return (
		<main className="mx-auto max-w-6xl px-4 py-8">
			<SearchForm defaultValue={q} />
			<div className="mt-8 grid gap-8 md:grid-cols-[200px_1fr]">
				<Filters />
				<section>
					{q ? (
						<p className="mb-4 text-sm text-muted-foreground">
							{count} result{results.length === 1 ? "" : "s"} for “{q}”
						</p>
					) : (
						<p className="text-muted-foreground">
							Type a query above to search talks.
						</p>
					)}
					{q && results.length === 0 && (
						<p className="text-muted-foreground">No talks found.</p>
					)}
					{results.length > 0 && <TalkGrid talks={results} />}
				</section>
			</div>
		</main>
	);
}

// Non-functional filter panel — shows the shape of upcoming filters. The whole
// fieldset is disabled so nothing submits or implies it works yet.
function Filters() {
	return (
		<aside className="text-sm">
			<div className="mb-3 flex items-baseline justify-between">
				<h2 className="font-semibold tracking-tight">Filters</h2>
				<span className="text-xs text-muted-foreground">coming soon</span>
			</div>
			<fieldset disabled className="space-y-5 opacity-60">
				<div>
					<label className="mb-1 block font-medium">Sort by</label>
					<select className="w-full rounded-md border border-border bg-card px-2 py-1.5">
						<option>Relevance</option>
						<option>Newest</option>
						<option>Most viewed</option>
						<option>Longest</option>
					</select>
				</div>
				<div>
					<label className="mb-1 block font-medium">Conference</label>
					<select className="w-full rounded-md border border-border bg-card px-2 py-1.5">
						<option>All conferences</option>
					</select>
				</div>
				<div>
					<span className="mb-1 block font-medium">Language</span>
					<div className="mt-1 space-y-1">
						<label className="flex items-center gap-2">
							<input type="checkbox" /> German
						</label>
						<label className="flex items-center gap-2">
							<input type="checkbox" /> English
						</label>
					</div>
				</div>
			</fieldset>
		</aside>
	);
}
