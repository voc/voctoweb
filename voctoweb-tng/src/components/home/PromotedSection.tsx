import { getRouteApi } from "@tanstack/react-router";
import { createServerFn } from "@tanstack/react-start";
import { and, desc, eq, isNotNull } from "drizzle-orm";
import { TalkCard } from "#/components/TalkCard.tsx";
import { db } from "#/db/index.ts";
import { conferences, events } from "#/db/schema.ts";
import { thumbUrl } from "#/lib/media.ts";
import { cachedQuery } from "#/lib/server/cache.ts";

// TODO: also surface currently-live streams here (conference `streaming` data),
// and make this a carousel (Embla / shadcn) that degrades to a scroll-snap row
// without JS.
export const getPromotedTalks = createServerFn({ method: "GET" }).handler(() =>
	cachedQuery(["promoted"], async () => {
		const rows = await db
			.select({
				id: events.id,
				slug: events.slug,
				title: events.title,
				thumbFilename: events.thumbFilename,
				imagesPath: conferences.imagesPath,
			})
			.from(events)
			.innerJoin(conferences, eq(events.conferenceId, conferences.id))
			.where(and(eq(events.promoted, true), isNotNull(events.releaseDate)))
			.orderBy(desc(events.updatedAt))
			.limit(12);
		return rows.map((r) => ({
			id: r.id,
			slug: r.slug,
			title: r.title,
			thumbUrl: thumbUrl(r.thumbFilename, r.imagesPath),
		}));
	}),
);

const home = getRouteApi("/");

export function PromotedSection() {
	const talks = home.useLoaderData({ select: (d) => d.promoted });
	if (talks.length === 0) return null;
	return (
		<section>
			<h2 className="mb-4 text-xl font-semibold tracking-tight">Featured</h2>
			<ul className="flex snap-x gap-4 overflow-x-auto pb-2">
				{talks.map((t) => (
					<li key={t.id} className="w-64 shrink-0 snap-start">
						<TalkCard slug={t.slug} title={t.title} thumbUrl={t.thumbUrl} />
					</li>
				))}
			</ul>
		</section>
	);
}
