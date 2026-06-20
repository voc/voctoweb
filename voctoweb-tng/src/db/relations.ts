import { relations } from 'drizzle-orm'
import { conferences, events, recordings } from './generated/schema'

// Hand-written: voctoweb has no DB-level foreign keys, so `drizzle-kit pull`
// generates an empty relations file. These mirror the ActiveRecord associations
// and enable `db.query.*.findMany({ with: { … } })`.
export const conferencesRelations = relations(conferences, ({ many }) => ({
  events: many(events),
}))

export const eventsRelations = relations(events, ({ one, many }) => ({
  conference: one(conferences, {
    fields: [events.conferenceId],
    references: [conferences.id],
  }),
  recordings: many(recordings),
}))

export const recordingsRelations = relations(recordings, ({ one }) => ({
  event: one(events, {
    fields: [recordings.eventId],
    references: [events.id],
  }),
}))
