import { createEnv } from '@t3-oss/env-core'
import { z } from 'zod'

export const env = createEnv({
  server: {
    SERVER_URL: z.url().optional(),
    // Public media.ccc.de CDNs urls
    CDN_URL: z.url(),
    STATIC_URL: z.url(),
    // CORS-enabled host for subtitle track fetches. The player fetches caption
    // files client-side to parse them, which needs CORS; the CDN doesn't send
    // CORS headers, so SRT tracks are served through this proxy instead.
    CORS_URL: z.url(),
    // Elasticsearch (read-only, queried server-side). When both are set, search
    // ranks via ES; otherwise it falls back to a basic SQL substring match.
    ELASTICSEARCH_URL: z.url().optional(),
    ELASTICSEARCH_INDEX: z.string().min(1).optional(),
  },

  /**
   * The prefix that client-side variables must have. This is enforced both at
   * a type-level and at runtime.
   */
  clientPrefix: 'VITE_',

  client: {
    VITE_APP_TITLE: z.string().min(1).optional(),
  },

  /**
   * What object holds the environment variables at runtime. This is usually
   * `process.env` or `import.meta.env`.
   */
  // Server vars come from process.env (server-side); client VITE_ vars from
  // import.meta.env. Guard keeps it from throwing if imported on the client.
  runtimeEnv: {
    ...import.meta.env,
    ...(typeof process !== 'undefined' ? process.env : {}),
  },

  /**
   * By default, this library will feed the environment variables directly to
   * the Zod validator.
   *
   * This means that if you have an empty string for a value that is supposed
   * to be a number (e.g. `PORT=` in a ".env" file), Zod will incorrectly flag
   * it as a type mismatch violation. Additionally, if you have an empty string
   * for a value that is supposed to be a string with a default value (e.g.
   * `DOMAIN=` in an ".env" file), the default value will never be applied.
   *
   * In order to solve these issues, we recommend that all new projects
   * explicitly specify this option as true.
   */
  emptyStringAsUndefined: true,
})
