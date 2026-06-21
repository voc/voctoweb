import { eq } from "drizzle-orm";
import { db } from "#/db/index.ts";
import { conferences } from "#/db/schema.ts";
import { cachedQuery } from "#/lib/server/cache.ts";

// Cached conference-by-id lookup. Shared so that every talk of a conference
// doesn't re-fetch the same row on each talk-page cache miss.
export function loadConference(id: number) {
	return cachedQuery(["conference-by-id", id], async () => {
		const [conference] = await db
			.select({
				acronym: conferences.acronym,
				title: conferences.title,
				recordingsPath: conferences.recordingsPath,
				imagesPath: conferences.imagesPath,
			})
			.from(conferences)
			.where(eq(conferences.id, id))
			.limit(1);
		return conference ?? null;
	});
}
