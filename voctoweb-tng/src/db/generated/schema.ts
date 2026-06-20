import {
	bigserial,
	boolean,
	date,
	index,
	integer,
	jsonb,
	pgTable,
	text,
	timestamp,
	uniqueIndex,
	varchar,
} from "drizzle-orm/pg-core";

export const activeAdminComments = pgTable(
	"active_admin_comments",
	{
		id: bigserial({ mode: "number" }).primaryKey().notNull(),
		namespace: varchar({ length: 255 }),
		body: text(),
		resourceId: varchar("resource_id", { length: 255 }).notNull(),
		resourceType: varchar("resource_type", { length: 255 }).notNull(),
		authorId: integer("author_id"),
		authorType: varchar("author_type", { length: 255 }),
		createdAt: timestamp("created_at", { mode: "string" }),
		updatedAt: timestamp("updated_at", { mode: "string" }),
	},
	(table) => [
		index("index_active_admin_comments_on_author_type_and_author_id").using(
			"btree",
			table.authorType.asc().nullsLast().op("int4_ops"),
			table.authorId.asc().nullsLast().op("int4_ops"),
		),
		index("index_active_admin_comments_on_namespace").using(
			"btree",
			table.namespace.asc().nullsLast().op("text_ops"),
		),
		index("index_active_admin_comments_on_resource_type_and_resource_id").using(
			"btree",
			table.resourceType.asc().nullsLast().op("text_ops"),
			table.resourceId.asc().nullsLast().op("text_ops"),
		),
	],
);

export const adminUsers = pgTable(
	"admin_users",
	{
		id: bigserial({ mode: "number" }).primaryKey().notNull(),
		email: varchar({ length: 255 }).default("").notNull(),
		encryptedPassword: varchar("encrypted_password", { length: 255 })
			.default("")
			.notNull(),
		resetPasswordToken: varchar("reset_password_token", { length: 255 }),
		resetPasswordSentAt: timestamp("reset_password_sent_at", {
			mode: "string",
		}),
		rememberCreatedAt: timestamp("remember_created_at", { mode: "string" }),
		signInCount: integer("sign_in_count").default(0),
		currentSignInAt: timestamp("current_sign_in_at", { mode: "string" }),
		lastSignInAt: timestamp("last_sign_in_at", { mode: "string" }),
		currentSignInIp: varchar("current_sign_in_ip", { length: 255 }),
		lastSignInIp: varchar("last_sign_in_ip", { length: 255 }),
		createdAt: timestamp("created_at", { mode: "string" }),
		updatedAt: timestamp("updated_at", { mode: "string" }),
	},
	(table) => [
		uniqueIndex("index_admin_users_on_email").using(
			"btree",
			table.email.asc().nullsLast().op("text_ops"),
		),
		uniqueIndex("index_admin_users_on_reset_password_token").using(
			"btree",
			table.resetPasswordToken.asc().nullsLast().op("text_ops"),
		),
	],
);

export const apiKeys = pgTable("api_keys", {
	id: bigserial({ mode: "number" }).primaryKey().notNull(),
	key: varchar({ length: 255 }),
	description: varchar({ length: 255 }),
	createdAt: timestamp("created_at", { mode: "string" }),
	updatedAt: timestamp("updated_at", { mode: "string" }),
});

export const conferences = pgTable(
	"conferences",
	{
		id: bigserial({ mode: "number" }).primaryKey().notNull(),
		acronym: varchar({ length: 255 }),
		recordingsPath: varchar("recordings_path", { length: 255 }),
		imagesPath: varchar("images_path", { length: 255 }),
		slug: varchar({ length: 255 }).default(""),
		aspectRatio: varchar("aspect_ratio", { length: 255 }),
		createdAt: timestamp("created_at", { mode: "string" }),
		updatedAt: timestamp("updated_at", { mode: "string" }),
		title: varchar({ length: 255 }),
		scheduleUrl: varchar("schedule_url", { length: 255 }),
		scheduleXml: text("schedule_xml"),
		scheduleState: varchar("schedule_state", { length: 255 })
			.default("not_present")
			.notNull(),
		logo: varchar({ length: 255 }),
		downloadedEventsCount: integer("downloaded_events_count")
			.default(0)
			.notNull(),
		metadata: jsonb().default({}),
		eventLastReleasedAt: timestamp("event_last_released_at", {
			mode: "string",
		}),
		streaming: jsonb().default({}),
		description: text(),
		link: varchar({ length: 255 }),
		customCss: text("custom_css"),
		globalEventNotes: varchar("global_event_notes"),
	},
	(table) => [
		index("index_conferences_on_acronym").using(
			"btree",
			table.acronym.asc().nullsLast().op("text_ops"),
		),
		index("index_conferences_on_streaming").using(
			"gin",
			table.streaming.asc().nullsLast().op("jsonb_ops"),
		),
	],
);

export const eventViewCounts = pgTable("event_view_counts", {
	id: bigserial({ mode: "number" }).primaryKey().notNull(),
	lastUpdatedAt: timestamp("last_updated_at", { mode: "string" }),
});

export const events = pgTable(
	"events",
	{
		id: bigserial({ mode: "number" }).primaryKey().notNull(),
		guid: varchar({ length: 255 }),
		posterFilename: varchar("poster_filename", { length: 255 }),
		conferenceId: integer("conference_id"),
		createdAt: timestamp("created_at", { mode: "string" }),
		updatedAt: timestamp("updated_at", { mode: "string" }),
		title: varchar({ length: 255 }),
		thumbFilename: varchar("thumb_filename", { length: 255 }),
		date: timestamp({ mode: "string" }),
		description: text(),
		link: varchar({ length: 255 }),
		persons: text(),
		slug: varchar({ length: 255 }),
		subtitle: varchar({ length: 255 }),
		tagsYaml: text("tags_yaml"),
		releaseDate: timestamp("release_date", { mode: "string" }),
		promoted: boolean(),
		viewCount: integer("view_count").default(0),
		duration: integer().default(0),
		downloadedRecordingsCount: integer("downloaded_recordings_count").default(
			0,
		),
		originalLanguage: varchar("original_language"),
		metadata: jsonb().default({}),
		timelineFilename: varchar("timeline_filename").default(""),
		thumbnailsFilename: varchar("thumbnails_filename").default(""),
		doi: varchar(),
		notes: varchar(),
		tags: varchar().array().default([""]).notNull(),
	},
	(table) => [
		index("index_events_on_conference_id").using(
			"btree",
			table.conferenceId.asc().nullsLast().op("int4_ops"),
		),
		index("index_events_on_guid").using(
			"btree",
			table.guid.asc().nullsLast().op("text_ops"),
		),
		index("index_events_on_metadata").using(
			"gin",
			table.metadata.asc().nullsLast().op("jsonb_ops"),
		),
		index("index_events_on_release_date").using(
			"btree",
			table.releaseDate.asc().nullsLast().op("timestamp_ops"),
		),
		index("index_events_on_slug").using(
			"btree",
			table.slug.asc().nullsLast().op("text_ops"),
		),
		index("index_events_on_slug_and_id").using(
			"btree",
			table.slug.asc().nullsLast().op("int8_ops"),
			table.id.asc().nullsLast().op("int8_ops"),
		),
		index("index_events_on_tags").using(
			"gin",
			table.tags.asc().nullsLast().op("array_ops"),
		),
		index("index_events_on_title").using(
			"btree",
			table.title.asc().nullsLast().op("text_ops"),
		),
	],
);

export const news = pgTable("news", {
	id: bigserial({ mode: "number" }).primaryKey().notNull(),
	title: varchar({ length: 255 }),
	body: text(),
	date: date(),
	createdAt: timestamp("created_at", { mode: "string" }),
	updatedAt: timestamp("updated_at", { mode: "string" }),
});

export const recordingViews = pgTable(
	"recording_views",
	{
		id: bigserial({ mode: "number" }).primaryKey().notNull(),
		recordingId: integer("recording_id"),
		createdAt: timestamp("created_at", { mode: "string" }),
		updatedAt: timestamp("updated_at", { mode: "string" }),
		userAgent: varchar("user_agent").default(""),
		identifier: varchar().default(""),
	},
	(table) => [
		index("index_recording_views_on_recording_id").using(
			"btree",
			table.recordingId.asc().nullsLast().op("int4_ops"),
		),
	],
);

export const recordings = pgTable(
	"recordings",
	{
		id: bigserial({ mode: "number" }).primaryKey().notNull(),
		size: integer(),
		length: integer(),
		mimeType: varchar("mime_type", { length: 255 }),
		eventId: integer("event_id"),
		createdAt: timestamp("created_at", { mode: "string" }),
		updatedAt: timestamp("updated_at", { mode: "string" }),
		filename: varchar({ length: 255 }),
		state: varchar({ length: 255 }).default("new").notNull(),
		folder: varchar({ length: 255 }),
		width: integer(),
		height: integer(),
		language: varchar().default("eng"),
		highQuality: boolean("high_quality").default(true).notNull(),
		html5: boolean().default(false).notNull(),
		translated: boolean().default(false).notNull(),
	},
	(table) => [
		index("index_recordings_on_event_id").using(
			"btree",
			table.eventId.asc().nullsLast().op("int4_ops"),
		),
		index("index_recordings_on_filename").using(
			"btree",
			table.filename.asc().nullsLast().op("text_ops"),
		),
		index("index_recordings_on_mime_type").using(
			"btree",
			table.mimeType.asc().nullsLast().op("text_ops"),
		),
		index("index_recordings_on_state").using(
			"btree",
			table.state.asc().nullsLast().op("text_ops"),
		),
		index("index_recordings_on_state_and_mime_type").using(
			"btree",
			table.state.asc().nullsLast().op("text_ops"),
			table.mimeType.asc().nullsLast().op("text_ops"),
		),
	],
);

export const siteSettings = pgTable("site_settings", {
	id: bigserial({ mode: "number" }).primaryKey().notNull(),
	promotedBannerUrl: varchar("promoted_banner_url"),
	liveBannerUrl: varchar("live_banner_url"),
	logoUrl: varchar("logo_url"),
	logoAlt: varchar("logo_alt"),
	createdAt: timestamp("created_at", {
		precision: 6,
		mode: "string",
	}).notNull(),
	updatedAt: timestamp("updated_at", {
		precision: 6,
		mode: "string",
	}).notNull(),
});

export const webFeeds = pgTable(
	"web_feeds",
	{
		id: bigserial({ mode: "number" }).primaryKey().notNull(),
		key: varchar(),
		kind: varchar(),
		lastBuild: timestamp("last_build", { mode: "string" }),
		content: text(),
	},
	(table) => [
		uniqueIndex("index_web_feeds_on_key_and_kind").using(
			"btree",
			table.key.asc().nullsLast().op("text_ops"),
			table.kind.asc().nullsLast().op("text_ops"),
		),
	],
);
