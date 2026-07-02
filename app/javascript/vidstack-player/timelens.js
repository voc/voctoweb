// timelens seekbar thumbnails.
//
// The timelens VTT writes each tile rect as a *query string*
// (`sprite.jpg?xywh=x,y,w,h`), but Vidstack reads coords from the URL *hash*
// (`#xywh=`). So we parse the cues ourselves into Vidstack's thumbnail array
// (a first-class source that bypasses its own VTT loader). Mirrors
// voctoweb-tng/src/lib/timelens.ts.

function parseVttTime(s) {
  const m = s.trim().match(/(?:(\d+):)?(\d+):(\d+)\.(\d+)/);
  if (!m) return 0;
  const [, h, min, sec, ms] = m;
  return (
    (h ? Number(h) * 3600 : 0) +
    Number(min) * 60 +
    Number(sec) +
    Number(ms) / 1000
  );
}

function parseTimelensVtt(text, baseUrl) {
  const images = [];
  const lines = text.split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    const arrow = lines[i].indexOf("-->");
    if (arrow === -1) continue;
    const startTime = parseVttTime(lines[i].slice(0, arrow));
    const endTime = parseVttTime(lines[i].slice(arrow + 3));
    const payload = lines[i + 1] && lines[i + 1].trim();
    const m = payload && payload.match(/^(.*?)\?xywh=(\d+),(\d+),(\d+),(\d+)/);
    if (!m) continue;
    const [, img, x, y, w, h] = m;
    images.push({
      url: new URL(img, baseUrl).href,
      startTime,
      endTime,
      coords: { x: Number(x), y: Number(y) },
      width: Number(w),
      height: Number(h),
    });
  }
  return images;
}

// Fetches + parses the VTT, hands the array to the layout, and warms the browser
// cache for every distinct sprite sheet so fast scrubbing never flashes black
// (Vidstack only batch-preloads a couple sheets near the cursor). Non-blocking:
// the player is already running; previews just appear once the small file lands.
export function loadTimelensThumbnails(vttUrl, layout) {
  fetch(vttUrl)
    .then((r) => (r.ok ? r.text() : Promise.reject(r.status)))
    .then((text) => {
      const parsed = parseTimelensVtt(text, vttUrl);
      layout.thumbnails = parsed;
      for (const url of new Set(parsed.map((t) => String(t.url)))) {
        new Image().src = url;
      }
    })
    .catch(() => {});
}
