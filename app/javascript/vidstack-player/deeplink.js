// ?t=<seconds> deep link; seek once the media is ready to play.
export function applyTimeDeepLink(player) {
  const t = parseFloat(new URLSearchParams(location.search).get("t"));
  if (Number.isNaN(t)) return;
  player.addEventListener(
    "can-play",
    () => {
      player.currentTime = t;
    },
    { once: true },
  );
}
