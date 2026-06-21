import { Link, getRouteApi } from "@tanstack/react-router";
import { createServerFn } from "@tanstack/react-start";
import { eq } from "drizzle-orm";
import { Downloads } from "#/components/talk/Downloads.tsx";
import { Metadata } from "#/components/talk/Metadata.tsx";
import { VideoPlayer } from "#/components/talk/VideoPlayer.tsx";
import { db } from "#/db/index.ts";
import { events, recordings } from "#/db/schema.ts";
import { cachedQuery } from "#/lib/server/cache.ts";
import { loadConference } from "#/lib/server/conference.ts";
import { toTalk } from "#/models/talk.ts";

export const getTalk = createServerFn({ method: "GET" })
	.validator((slug: string) => slug)
	.handler(({ data: slug }) =>
		cachedQuery(["talk", slug], async () => {
			const [talk] = await db
				.select({
					id: events.id,
					title: events.title,
					description: events.description,
					conferenceId: events.conferenceId,
					duration: events.duration,
					date: events.date,
					releaseDate: events.releaseDate,
					viewCount: events.viewCount,
					link: events.link,
					doi: events.doi,
					posterFilename: events.posterFilename,
				})
				.from(events)
				.where(eq(events.slug, slug))
				.limit(1);
			if (!talk) return null;

			const conference = talk.conferenceId
				? await loadConference(talk.conferenceId)
				: null;

			const raw = await db
				.select({
					id: recordings.id,
					mimeType: recordings.mimeType,
					filename: recordings.filename,
					folder: recordings.folder,
					language: recordings.language,
					width: recordings.width,
					height: recordings.height,
					size: recordings.size,
					html5: recordings.html5,
				})
				.from(recordings)
				.where(eq(recordings.eventId, talk.id));

			return toTalk(talk, conference, raw);
		}),
	);

const route = getRouteApi("/v/$slug");

export function TalkPage() {
	const talk = route.useLoaderData();

	return (
		<main className="mx-auto max-w-4xl space-y-6 px-4 py-8">
			{talk.conference && (
				<Link
					to="/c/$acronym"
					params={{ acronym: talk.conference.acronym ?? "" }}
					className="text-sm font-medium text-muted-foreground hover:text-primary"
				>
					{talk.conference.title ?? talk.conference.acronym}
				</Link>
			)}
			<div className="overflow-hidden rounded-xl border border-border">
				<VideoPlayer talk={talk} />
			</div>
			<h1 className="text-2xl font-bold tracking-tight sm:text-3xl">
				{talk.title}
			</h1>
			<Metadata />
			{talk.description && (
				<div className="space-y-4 leading-relaxed">
					{talk.description.split(/\n\n+/).map((para, i) => (
						// biome-ignore lint/suspicious/noArrayIndexKey: static, non-reordering list
						<p key={i}>{para}</p>
					))}
				</div>
			)}
			<Downloads />
			{/* TODO: Speakers (after persons→array migration), Share, Tags */}
			<details className="rounded-lg border border-border bg-card p-3">
				<summary className="cursor-pointer text-sm font-medium text-muted-foreground">
					Debug: talk JSON
				</summary>
				<pre className="mt-3 overflow-x-auto text-xs leading-relaxed">
					{JSON.stringify(talk, null, 2)}
				</pre>
			</details>
		</main>
	);
}
