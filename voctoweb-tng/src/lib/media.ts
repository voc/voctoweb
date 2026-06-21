import { env } from '#/env.ts'

// Images/subtitles come from STATIC_URL, audio/video recordings from CDN_URL
// (validated in src/env.ts). Matches the Rails models.

// Drops the empty `folder` segment; tolerant of drizzle's nullable column types.
export const join = (...parts: Array<string | null>) =>
  parts.filter(Boolean).join('/')

// Event thumbnail URL, or null if it has none. No logo fallback on purpose —
// conference logos rarely work as thumbnails.
export function thumbUrl(
  thumbFilename: string | null,
  imagesPath: string | null,
): string | null {
  return thumbFilename
    ? `${env.STATIC_URL}/${join(imagesPath, thumbFilename)}`
    : null
}

// Event poster (the larger player still), or null if it has none.
export function posterUrl(
  posterFilename: string | null,
  imagesPath: string | null,
): string | null {
  return posterFilename
    ? `${env.STATIC_URL}/${join(imagesPath, posterFilename)}`
    : null
}
