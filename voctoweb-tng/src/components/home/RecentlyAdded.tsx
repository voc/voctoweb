import { Link, getRouteApi } from "@tanstack/react-router";
import { createServerFn } from "@tanstack/react-start";
import { and, count, desc, eq, isNotNull } from "drizzle-orm";
import { TalkGrid } from "#/components/TalkCard.tsx";
import { db } from "#/db/index.ts";
import { conferences, events } from "#/db/schema.ts";
import { thumbUrl } from "#/lib/media.ts";
import { cachedQuery } from "#/lib/server/cache.ts";

const TALK_LIMIT = 3;

// Mirrors the original: 9 conferences with the most recent releases, a few talks each.
export const getRecentConferences = createServerFn({ method: "GET" }).handler(
	() =>
		cachedQuery(["recent-conferences"], async () => {
			const confs = await db
				.select({
					id: conferences.id,
					acronym: conferences.acronym,
					title: conferences.title,
					imagesPath: conferences.imagesPath,
				})
				.from(conferences)
				.where(isNotNull(conferences.eventLastReleasedAt))
				.orderBy(desc(conferences.eventLastReleasedAt))
				.limit(9);

			return Promise.all(
				confs.map(async (c) => {
					const released = and(
						eq(events.conferenceId, c.id),
						isNotNull(events.releaseDate),
					);
					const [talkRows, totals] = await Promise.all([
						db
							.select({
								id: events.id,
								slug: events.slug,
								title: events.title,
								thumbFilename: events.thumbFilename,
							})
							.from(events)
							.where(released)
							.orderBy(desc(events.releaseDate), desc(events.id))
							.limit(TALK_LIMIT),
						db.select({ total: count() }).from(events).where(released),
					]);
					const talks = talkRows.map((t) => ({
						id: t.id,
						slug: t.slug,
						title: t.title,
						thumbUrl: thumbUrl(t.thumbFilename, c.imagesPath),
					}));
					return {
						id: c.id,
						acronym: c.acronym,
						title: c.title,
						talks,
						total: totals[0]?.total ?? 0,
					};
				}),
			);
		}),
);

const home = getRouteApi("/");

export function RecentlyAdded() {
	const conferences = home.useLoaderData({ select: (d) => d.recent });
	return (
		<section className="space-y-8">
			<h2 className="text-xl font-semibold tracking-tight">Recently added</h2>
			{conferences.map((c) => {
				const more = c.total - c.talks.length;
				return (
					<div key={c.id}>
						<div className="mb-3 flex items-baseline justify-between gap-4">
							<h3 className="font-medium">
								<Link
									to="/c/$acronym"
									params={{ acronym: c.acronym ?? "" }}
									className="hover:text-primary"
								>
									{c.title}
								</Link>
							</h3>
							{more > 0 && (
								<Link
									to="/c/$acronym"
									params={{ acronym: c.acronym ?? "" }}
									className="shrink-0 text-sm text-muted-foreground hover:text-foreground"
								>
									+{more} more
								</Link>
							)}
						</div>
						<TalkGrid talks={c.talks} />
					</div>
				);
			})}
		</section>
	);
}
