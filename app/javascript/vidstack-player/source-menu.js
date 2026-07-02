import * as dashjs from "dashjs";

// Video source selector (camera / slides) for DASH manifests with multiple
// video AdaptationSets. Vidstack only models ONE video set (its quality list
// is built from the first supported set in manifest order) and ignores the
// rest, so we build our own menu straight from the dash.js track API and
// switch sets with setCurrentTrack() (seamless, keeps position).
//
// Known gap: Vidstack's quality submenu keeps describing the initial set
// after a switch. Our manifests ship the same ladder for every source, so
// it stays functional; revisit if that ever changes.

// Checkmark drawn by the default theme for the selected radio ("menu-radio-
// check" from vidstack's icon set, inlined because the layout's lazy icon
// loader doesn't fill slots in DOM we insert ourselves).
const CHECK_ICON =
  '<svg class="vds-icon" viewBox="0 0 32 32" fill="none" aria-hidden="true"><path fill-rule="evenodd" clip-rule="evenodd" d="M24.9266 7.57992C25.015 7.60672 25.0886 7.64746 25.2462 7.80506L26.956 9.51488C27.1136 9.67248 27.1543 9.74604 27.1811 9.83447C27.2079 9.9229 27.2079 10.0133 27.1811 10.1018C27.1543 10.1902 27.1136 10.2638 26.956 10.4214L13.1822 24.1951C13.0246 24.3527 12.951 24.3935 12.8626 24.4203C12.797 24.4402 12.7304 24.4453 12.6642 24.4357L12.7319 24.4203C12.6435 24.4471 12.553 24.4471 12.4646 24.4203C12.3762 24.3935 12.3026 24.3527 12.145 24.1951L5.04407 17.0942C4.88647 16.9366 4.84573 16.863 4.81893 16.7746C4.79213 16.6862 4.79213 16.5957 4.81893 16.5073C4.84573 16.4189 4.88647 16.3453 5.04407 16.1877L6.7539 14.4779C6.9115 14.3203 6.98506 14.2796 7.07349 14.2528C7.16191 14.226 7.25235 14.226 7.34078 14.2528C7.42921 14.2796 7.50277 14.3203 7.66037 14.4779L12.6628 19.4808L24.3397 7.80506C24.4973 7.64746 24.5709 7.60672 24.6593 7.57992C24.7477 7.55311 24.8382 7.55311 24.9266 7.57992Z" fill="currentColor"/></svg>';

// Simple video-camera glyph (there is no fitting icon in the default set).
const CAMERA_ICON =
  '<svg class="vds-icon" viewBox="0 0 32 32" fill="none" aria-hidden="true"><path d="M6.5 9.5h13a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2h-13a2 2 0 0 1-2-2v-9a2 2 0 0 1 2-2Z M23.5 14.75l4.5-2.75a0.5 0.5 0 0 1 0.76 0.43v7.14a0.5 0.5 0 0 1-0.76 0.43l-4.5-2.75v-2.5Z" fill="currentColor"/></svg>';

const setupDone = new WeakSet();

export function setupSourceMenu(player, provider) {
  if (setupDone.has(provider)) return;
  setupDone.add(provider);

  provider.onInstance((dash) => {
    // Start deterministically on the camera (Role "main"), not whatever set
    // dash.js's bitrate heuristics pick - slides can have the higher bitrate.
    // This also keeps Vidstack's quality list truthful, since it is built
    // from the first (main) set. The role must be a descriptor object, a
    // plain string never matches (dash.js compares schemeIdUri + value).
    // Deferred a tick: onInstance fires right before initialize(), and
    // dash.js throws on this call until then.
    queueMicrotask(() => {
      dash.setInitialMediaSettingsFor("video", {
        role: { schemeIdUri: "urn:mpeg:dash:role:2011", value: "main" },
      });
    });

    dash.on(dashjs.MediaPlayer.events.STREAM_INITIALIZED, () => {
      const tracks = dash.getTracksFor("video");
      if (tracks.length < 2) return;
      observeAndMount(player, dash, tracks);
    });
  });
}

// The default layout swaps its whole controls DOM between the small and large
// templates on resize, which throws our injected menu away. Watch the player
// subtree and re-insert whenever the menu is gone but an anchor is available.
function observeAndMount(player, dash, tracks) {
  const mount = () => {
    if (player.querySelector(".voc-source-menu")) return;
    const anchor = player.querySelector(".vds-settings-menu");
    if (anchor) anchor.before(buildMenu(player, dash, tracks));
  };
  let scheduled = false;
  new MutationObserver(() => {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(() => {
      scheduled = false;
      mount();
    });
  }).observe(player, { childList: true, subtree: true });
  mount();
}

function trackLabel(track, index) {
  const label = track.labels && track.labels[0] && track.labels[0].text;
  if (label) return label;
  const role = track.roles && track.roles[0];
  const roleValue = role && (role.value || role);
  if (roleValue === "main") return "Video";
  return "Source " + (index + 1);
}

function currentIndex(dash, tracks) {
  const current = dash.getCurrentTrackFor("video");
  return current ? tracks.findIndex((t) => t.index === current.index) : 0;
}

function buildMenu(player, dash, tracks) {
  const menu = document.createElement("media-menu");
  menu.className = "voc-source-menu vds-menu";
  menu.innerHTML =
    '<media-menu-button class="vds-menu-button vds-button" aria-label="Video source">' +
    CAMERA_ICON +
    "</media-menu-button>" +
    '<media-menu-items class="vds-menu-items" placement="top end">' +
    '<media-radio-group class="vds-radio-group"></media-radio-group>' +
    "</media-menu-items>";

  const group = menu.querySelector("media-radio-group");
  tracks.forEach((track, i) => {
    const radio = document.createElement("media-radio");
    radio.className = "vds-radio";
    radio.setAttribute("value", String(i));
    radio.innerHTML = CHECK_ICON;
    const label = document.createElement("span");
    label.className = "vds-radio-label";
    label.textContent = trackLabel(track, i);
    radio.append(label);
    group.append(radio);
  });
  group.setAttribute("value", String(currentIndex(dash, tracks)));

  group.addEventListener("change", () => {
    const track = tracks[Number(group.value)];
    const current = dash.getCurrentTrackFor("video");
    if (!track || (current && track.index === current.index)) return;
    // dash.js 5.x cannot switch video AdaptationSets mid-session on our
    // SegmentList manifests: its scheduler keeps fetching the old set while
    // every API reports the new one. Restart the streaming session instead;
    // setCurrentTrack records the choice as the session's last-selected
    // track, which wins initial selection on re-attach.
    const wasPaused = player.paused;
    dash.setCurrentTrack(track);
    dash.attachSource(dash.getSource(), dash.time());
    if (!wasPaused) {
      // Resume once the new session is ready. The re-attach pauses the raw
      // <video> while Vidstack's state still says "playing", so player.play()
      // no-ops; drive the element directly (Vidstack re-syncs from its events)
      // and retry briefly since there is no single reliable "ready" moment.
      let attempts = 12;
      const resume = () => {
        const video = player.querySelector("video");
        if (video && !video.paused) return;
        if (attempts-- <= 0) return;
        video?.play().catch(() => {});
        setTimeout(resume, 500);
      };
      setTimeout(resume, 300);
    }
  });

  // Keep the radios honest if the track changes from elsewhere.
  dash.on(dashjs.MediaPlayer.events.TRACK_CHANGE_RENDERED, (e) => {
    if (e.mediaType !== "video" || !group.isConnected) return;
    group.setAttribute("value", String(currentIndex(dash, tracks)));
  });

  return menu;
}
