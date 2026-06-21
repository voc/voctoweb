import { getRouteApi } from "@tanstack/react-router";
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
		<main>
			<section>[ConferenceHeader]</section>
			<h1>{talk.title}</h1>
			<section>[Speakers]</section>
			<VideoPlayer talk={talk} />
			<Metadata />
			{talk.description && (
				<div>
					{talk.description.split(/\n\n+/).map((para, i) => (
						// biome-ignore lint/suspicious/noArrayIndexKey: static, non-reordering list
						<p key={i}>{para}</p>
					))}
				</div>
			)}
			<Downloads />
			<section>[Share]</section>
			<section>[Tags]</section>
		</main>
	);
}
