import { Link, getRouteApi } from "@tanstack/react-router";
import { createServerFn } from "@tanstack/react-start";
import { and, desc, eq, isNotNull } from "drizzle-orm";
import { db } from "#/db/index.ts";
import { events } from "#/db/schema.ts";
import { cachedQuery } from "#/lib/server/cache.ts";

// TODO: also surface currently-live streams here (conference `streaming` data),
// and make this a carousel (Embla / shadcn) that degrades to a scroll-snap row
// without JS.
export const getPromotedTalks = createServerFn({ method: "GET" }).handler(() =>
	cachedQuery(["promoted"], () =>
		db
			.select({ id: events.id, slug: events.slug, title: events.title })
			.from(events)
			.where(and(eq(events.promoted, true), isNotNull(events.releaseDate)))
			.orderBy(desc(events.updatedAt))
			.limit(12),
	),
);

const home = getRouteApi("/");

export function PromotedSection() {
	const talks = home.useLoaderData({ select: (d) => d.promoted });
	if (talks.length === 0) return null;
	return (
		<section>
			<h2>Featured</h2>
			<ul>
				{talks.map((t) => (
					<li key={t.id}>
						<Link to="/v/$slug" params={{ slug: t.slug ?? "" }}>
							{t.title}
						</Link>
					</li>
				))}
			</ul>
		</section>
	);
}
