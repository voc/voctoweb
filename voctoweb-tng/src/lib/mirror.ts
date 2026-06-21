// Client-side CDN mirror pinning, mirroring voctoweb's own behaviour.
// Asking the CDN URL for JSON returns a mirror list geo-sorted by the user's IP;
// we pin MirrorList[0] so all (range) requests for a file hit one consistent,
// nearby mirror instead of re-following a 302. Best-effort: returns the original
// URL on any failure. (CDN is Mirrorbits today, same JSON API going forward.)
export async function pinMirror(
  url: string,
  signal?: AbortSignal,
): Promise<string> {
  try {
    const httpsUrl = url.replace(/^http:/, "https:");
    const res = await fetch(httpsUrl, {
      headers: { Accept: "application/json" },
      signal,
    });
    if (!res.ok) return url;
    const data = (await res.json()) as {
      MirrorList?: Array<{ HttpURL?: string }>;
      FileInfo?: { Path?: string };
    };
    const base = data.MirrorList?.[0]?.HttpURL;
    const path = data.FileInfo?.Path;
    return base && path ? base.replace(/\/+$/, "") + path : url;
  } catch {
    return url;
  }
}
