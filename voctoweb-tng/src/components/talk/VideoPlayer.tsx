import "@vidstack/react/player/styles/default/theme.css";
import "@vidstack/react/player/styles/default/layouts/video.css";
import {
  MediaPlayer,
  MediaProvider,
  Poster,
  Track,
  type VideoSrc,
} from "@vidstack/react";
import {
  DefaultVideoLayout,
  defaultLayoutIcons,
} from "@vidstack/react/player/layouts/default";
import { useEffect, useState } from "react";
import type { Talk } from "#/models/talk.ts";

export function VideoPlayer({ talk }: { talk: Talk }) {
  const sources = talk.media.video.filter((r) => r.html5);
  const subtitles = talk.media.subtitle;
  const { poster, title } = talk;

  // Only load the vidstack player client side, SSR would make clients without
  // javascript unable to play the video
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);

  if (sources.length === 0) return <p>No video recording.</p>;

  if (!mounted) {
    return (
      <video
        controls
        preload="none"
        poster={poster ?? undefined}
        className="aspect-video w-full"
      >
        {sources.map((s) => (
          <source key={s.id} src={s.url} type={s.mimeType} />
        ))}
        {subtitles.map((t) => (
          <track
            key={t.id}
            kind="subtitles"
            src={t.url}
            srcLang={t.language}
            label={t.languageLabel}
          />
        ))}
      </video>
    );
  }

  return (
    <MediaPlayer
      className="aspect-video w-full"
      src={sources.map((s) => ({ src: s.url, type: s.mimeType }) as VideoSrc)}
      poster={poster ?? undefined}
      title={title}
      viewType="video"
      streamType="on-demand"
      playsInline
    >
      <MediaProvider>
        {subtitles.map((t) => (
          <Track
            key={String(t.id)}
            kind="subtitles"
            src={t.url}
            language={t.language}
            label={t.languageLabel}
          />
        ))}
      </MediaProvider>
      <Poster className="vds-poster" />
      <DefaultVideoLayout icons={defaultLayoutIcons} />
    </MediaPlayer>
  );
}
