import type * as dashjs from "dashjs";

// The interceptor signature, derived from dash.js's own API surface so we don't
// have to import its transitive `@svta/cml-request` types (not a direct dep).
type ResponseInterceptor = Parameters<
  dashjs.MediaPlayerClass["addResponseInterceptor"]
>[0];

// remove everything after the last slash
const dirOf = (url: string) => url.slice(0, url.lastIndexOf("/") + 1);

// URLs go into XML attribute/text, so the only char we must escape is `&`.
const xmlEscape = (s: string) => s.replace(/&/g, "&amp;");

function decode(data: unknown): string | null {
  if (typeof data === "string") return data;
  if (data instanceof ArrayBuffer) return new TextDecoder().decode(data);
  if (ArrayBuffer.isView(data)) return new TextDecoder().decode(data);
  return null;
}

/**
 * This is a response interceptor that adds a base cdn BaseURL to the dash manifest file
 * before it is processed by dash.js.
 * 
 * This is necessary because dash.js auto-pins to whichever mirror the CDN's 302 redirect
 * lands for the manifest file request. This means that if the mirror is missing files
 * that are referenced in the manifest, the player will fail to load them as it will only
 * try to load from the mirror that served the manifest file.
 * 
 * We inject two BaseURLs:
 *   1. the redirected mirror dir - primary; essentially equivalent to what the auto-pin does
 *   2. the original CDN dir - so the player can fall back to the CDN if the mirror is missing the file
 * 
 * We thought about also implementing a completeness check in the CDN host server to ensure
 * that .mpd files are only served if all referenced files are present on a mirror. But this
 * should suffice for now.
 * 
 * @param response 
 * @returns 
 */
export const addCdnFallbackBaseUrl: ResponseInterceptor = async (response) => {
  const requestUrl = response.request?.url ?? "";

  // only process .mpd files
  if (!/\.mpd(\?|$)/i.test(requestUrl)) return response;

  const xml = decode(response.data);

  // Leave manifests that already declare BaseURLs alone, in case we ever serve files
  // from a different origin than the CDN, or the CDN actually serves dynamic manifests.
  if (!xml || xml.includes("<BaseURL")) return response;


  const cdnDir = dirOf(requestUrl);

  // response.url is the final URL after redirects; "./" falls back to resolving
  // against the manifest's own (redirected) location if it's somehow absent.
  const mirrorDir = response.url ? dirOf(response.url) : "./";

  // cdn seems to already be serving the manifest file itself, we can't pin
  // anything else here
  if (mirrorDir === cdnDir) return response;

  const baseUrls =
    `<BaseURL serviceLocation="mirror">${xmlEscape(mirrorDir)}</BaseURL>` +
    `<BaseURL serviceLocation="cdn">${xmlEscape(cdnDir)}</BaseURL>`;
  
  // insert the constructed BaseURLs into the manifest file right after the
  // opening <MPD> tag
  const patched = xml.replace(/(<MPD\b[^>]*>)/, `$1${baseUrls}`);

  // couldn't locate <MPD> in the manifest file, we can just as well return
  // the original response
  if (patched === xml) return response;

  // Modify the response data in place so we don't accidentally modify anything else
  response.data = (
    typeof response.data === "string"
      ? patched
      : new TextEncoder().encode(patched).buffer
  ) as typeof response.data;
  return response;
};
