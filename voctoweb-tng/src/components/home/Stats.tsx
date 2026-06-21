import { getRouteApi } from "@tanstack/react-router";
import { createServerFn } from "@tanstack/react-start";
import { sql } from "drizzle-orm";
import { Card } from "#/components/ui/Card.tsx";
import { db } from "#/db/index.ts";
import { conferences, events, recordings } from "#/db/schema.ts";
import { cachedQuery } from "#/lib/server/cache.ts";

export const getStats = createServerFn({ method: "GET" }).handler(() =>
	cachedQuery(["stats"], async () => {
		const [row] = await db
			.select({
				hours: sql<number>`(select coalesce(sum(${events.duration}), 0) / 3600 from ${events})`,
				files: sql<number>`(select count(*) from ${recordings})`,
				talks: sql<number>`(select count(*) from ${events})`,
				conferences: sql<number>`(select count(*) from ${conferences})`,
			})
			.from(sql`(select 1) as _`);
		return row;
	}),
);

const home = getRouteApi("/");
const fmt = (n: number) => new Intl.NumberFormat("en-US").format(Number(n));

export function Stats() {
	const s = home.useLoaderData({ select: (d) => d.stats });
	const items = [
		{ value: fmt(s.hours), label: "hours of content" },
		{ value: fmt(s.talks), label: "talks" },
		{ value: fmt(s.conferences), label: "conferences" },
		{ value: fmt(s.files), label: "files" },
	];
	return (
		<section className="grid grid-cols-2 gap-4 sm:grid-cols-4">
			{items.map((it) => (
				<Card key={it.label} className="p-4">
					<div className="text-2xl font-bold tracking-tight">{it.value}</div>
					<div className="mt-1 text-sm text-muted-foreground">{it.label}</div>
				</Card>
			))}
		</section>
	);
}
