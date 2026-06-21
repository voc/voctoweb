import { getRouteApi } from "@tanstack/react-router";
import { createServerFn } from "@tanstack/react-start";
import { and, desc, eq, isNotNull } from "drizzle-orm";
import { TalkGrid } from "#/components/TalkCard.tsx";
import { db } from "#/db/index.ts";
import { conferences, events } from "#/db/schema.ts";
import { thumbUrl } from "#/lib/media.ts";
import { cachedQuery } from "#/lib/server/cache.ts";

export const getConference = createServerFn({ method: "GET" })
	.validator((acronym: string) => acronym)
	.handler(({ data: acronym }) =>
		cachedQuery(["conference", acronym], async () => {
			const [conference] = await db
				.select({
					id: conferences.id,
					acronym: conferences.acronym,
					title: conferences.title,
					imagesPath: conferences.imagesPath,
				})
				.from(conferences)
				.where(eq(conferences.acronym, acronym))
				.limit(1);
			if (!conference) return null;

			// TODO: user-selectable sort (name / date / duration / views) like prod.
			// Probably TanStack Table once we want sortable column headers.
			const talkRows = await db
				.select({
					id: events.id,
					slug: events.slug,
					title: events.title,
					thumbFilename: events.thumbFilename,
				})
				.from(events)
				.where(
					and(
						eq(events.conferenceId, conference.id),
						isNotNull(events.releaseDate),
					),
				)
				.orderBy(desc(events.viewCount));
			const talks = talkRows.map((t) => ({
				id: t.id,
				slug: t.slug,
				title: t.title,
				thumbUrl: thumbUrl(t.thumbFilename, conference.imagesPath),
			}));
			return {
				id: conference.id,
				acronym: conference.acronym,
				title: conference.title,
				talks,
			};
		}),
	);

const route = getRouteApi("/c/$acronym");

export function ConferencePage() {
	const conference = route.useLoaderData();
	return (
		<main className="mx-auto max-w-6xl px-4 py-8">
			<header className="mb-6">
				<h1 className="text-2xl font-semibold tracking-tight">
					{conference.title ?? conference.acronym}
				</h1>
				<p className="mt-1 text-sm text-muted-foreground">
					{conference.talks.length} talks
				</p>
			</header>
			<TalkGrid talks={conference.talks} />
		</main>
	);
}
