import "@vidstack/react/player/styles/default/theme.css";
import "@vidstack/react/player/styles/default/layouts/video.css";
import { MediaPlayer, MediaProvider } from "@vidstack/react";
import {
  DefaultVideoLayout,
  defaultLayoutIcons,
} from "@vidstack/react/player/layouts/default";
import { useEffect, useState } from "react";
import type { Recording } from "#/lib/media.ts";

export function VideoPlayer({ recordings }: { recordings: Recording[] }) {
  const video = recordings
    .filter((r) => r.kind === "video" && r.html5)
    .sort((a, b) => (b.width ?? 0) - (a.width ?? 0))[0];

  // Only load the vidstack player client side, SSR would make clients without 
  // javascript unable to play the video
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);

  if (!video) return <p>No video recording.</p>;

  if (!mounted) {
    return (
      <video controls preload="none" className="aspect-video w-full">
        <source src={video.url} type={video.mimeType} />
      </video>
    );
  }

  return (
    <MediaPlayer
      className="aspect-video w-full"
      src={video.url}
      viewType="video"
      streamType="on-demand"
      playsInline
    >
      <MediaProvider />
      <DefaultVideoLayout icons={defaultLayoutIcons} />
    </MediaPlayer>
  );
}
