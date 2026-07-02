// Vidstack player for voctoweb (opt-in ?player=vidstack; vanilla web
// components, no framework). Built by esbuild as its own entry point, so it is
// not part of application.js and only loads via _player_video_vidstack.haml.
// dash.js is bundled and self-hosted (no third-party CDN at runtime), matching
// the voctoweb-tng player.
//
// Entry point only: pulls in the layout styles and wires up page lifecycle. The
// actual behaviour lives in the focused modules imported below.

import "vidstack/player/styles/default/theme.css";
import "vidstack/player/styles/default/layouts/video.css";
import { initAll } from "./player.js";

// This bundle loads in the (cached) player partial, so Turbolinks may re-evaluate
// it on navigation. Register listeners once; initPlayer + Vidstack's own
// customElements.define are already idempotent.
if (!window.__voctowebVidstackInit) {
  window.__voctowebVidstackInit = true;
  // Turbolinks navigation fires turbolinks:load; fall back to DOMContentLoaded.
  document.addEventListener("turbolinks:load", initAll);
  if (document.readyState !== "loading") initAll();
  else document.addEventListener("DOMContentLoaded", initAll);
}
