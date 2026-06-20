import { config } from 'dotenv'
import { defineConfig } from 'drizzle-kit'

config({ path: ['.env.local', '.env'] })

// Pull only, Rails owns the database schema, we only read from the DB here
export default defineConfig({
  dialect: 'postgresql',
  out: './src/db/generated',
  schema: './src/db/generated/schema.ts',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  introspect: { casing: 'camel' },
  tablesFilter: ['!schema_migrations', '!ar_internal_metadata'],
})
