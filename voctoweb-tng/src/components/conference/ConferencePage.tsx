import { Link, getRouteApi } from "@tanstack/react-router";
import { createServerFn } from "@tanstack/react-start";
import { and, desc, eq, isNotNull } from "drizzle-orm";
import { db } from "#/db/index.ts";
import { conferences, events } from "#/db/schema.ts";
import { Card } from "#/components/ui/Card.tsx";
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
			<ul className="grid grid-cols-[repeat(auto-fill,minmax(220px,1fr))] gap-4">
				{conference.talks.map((t) => (
					<li key={t.id}>
						<Link
							to="/v/$slug"
							params={{ slug: t.slug ?? "" }}
							className="block rounded-xl focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary"
						>
							<Card className="h-full">
								<div className="aspect-video bg-muted">
									{t.thumbUrl && (
										<img
											src={t.thumbUrl}
											alt=""
											loading="lazy"
											className="h-full w-full object-cover transition-transform duration-200 group-hover:scale-105"
										/>
									)}
								</div>
								<h2 className="line-clamp-2 p-3 text-sm font-medium leading-snug">
									{t.title}
								</h2>
							</Card>
						</Link>
					</li>
				))}
			</ul>
		</main>
	);
}
