import { VidstackPlayer, VidstackPlayerLayout } from "vidstack/global/player";
import { useLocalAdaptiveLibrary } from "./adaptive-library.js";
import { applyTimeDeepLink } from "./deeplink.js";
import { setupSourceMenu } from "./source-menu.js";
import { loadTimelensThumbnails } from "./timelens.js";

// Boot a single Vidstack player from a `.vidstack-player[data-config]` element.
// The data-config JSON is built server-side in _player_video_vidstack.haml.
async function initPlayer(el) {
  if (el.dataset.vidstackReady) return;
  el.dataset.vidstackReady = "1";

  const cfg = JSON.parse(el.dataset.config);
  const player = await VidstackPlayer.create({
    target: el,
    src: cfg.src,
    poster: cfg.poster || undefined,
    title: cfg.title || undefined,
    viewType: "video",
    streamType: "on-demand",
    // No aspectRatio here: the .video.player wrapper's CSS drives sizing (and the
    // conference's 4:3/16:9), same as the other players. See _videoplayer.scss.
    playsInline: true,
    crossOrigin: true,
    tracks: cfg.tracks || [],
    layout: new VidstackPlayerLayout(),
  });

  const onProvider = (provider) => {
    if (!provider) return;
    useLocalAdaptiveLibrary(provider);
    if (provider.type === "dash") setupSourceMenu(player, provider);
  };
  player.addEventListener("provider-change", (e) => onProvider(e.detail));
  // The provider may already exist by the time create() resolves; missing it
  // would leave provider.library on its default CDN loader (the IP leak).
  onProvider(player.provider);

  applyTimeDeepLink(player);

  if (cfg.thumbnails) {
    const layout = player.querySelector("media-video-layout");
    if (layout) loadTimelensThumbnails(cfg.thumbnails, layout);
  }
}

// Boot every not-yet-initialised player on the page.
export function initAll() {
  document
    .querySelectorAll(".vidstack-player[data-config]")
    .forEach((el) => initPlayer(el));
}
