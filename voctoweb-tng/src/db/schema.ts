// App-facing schema barrel. Re-exports the machine-generated tables (from
// `drizzle-kit pull`) plus our hand-written relations, and derives the lite
// types the UI uses.
export * from './generated/schema'
export * from './relations'

import type {
  conferences,
  events,
  news,
  recordings,
  siteSettings,
} from './generated/schema'

export type Conference = typeof conferences.$inferSelect
export type Event = typeof events.$inferSelect
export type Recording = typeof recordings.$inferSelect
export type News = typeof news.$inferSelect
export type SiteSettings = typeof siteSettings.$inferSelect
