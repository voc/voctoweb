import "@vidstack/react/player/styles/default/theme.css";
import "@vidstack/react/player/styles/default/layouts/video.css";
import {
  MediaPlayer,
  type MediaPlayerInstance,
  MediaProvider,
  Menu,
  Poster,
  Track,
  type VideoSrc,
} from "@vidstack/react";
import {
  DefaultVideoLayout,
  defaultLayoutIcons,
} from "@vidstack/react/player/layouts/default";
import { ChevronRight, Gauge, Languages } from "lucide-react";
import { useEffect, useRef, useState } from "react";
import type { Recording } from "#/models/recording.ts";
import type { Talk } from "#/models/talk.ts";

const qualityKey = (r: Recording) => r.resolution ?? "Source";

// Two independent menus (Language + Quality) over the available progressive
// recordings. The (language × quality) matrix is sparse, so options that don't
// exist for the current other-axis value are dimmed; picking one anyway forces
// the other axis to its nearest available value. A future DASH source would let
// Vidstack drive quality/audio natively instead.
function SourceMenus({
  videos,
  lang,
  res,
  onLanguage,
  onQuality,
}: {
  videos: Recording[];
  lang: string;
  res: string;
  onLanguage: (code: string) => void;
  onQuality: (res: string) => void;
}) {
  const languages = [
    ...new Map(videos.map((v) => [v.language, v.languageLabel])).entries(),
  ].map(([code, label]) => ({ code, label }));
  const qualities = [
    ...new Map(videos.map((v) => [qualityKey(v), v.height ?? 0])).entries(),
  ]
    .map(([key, height]) => ({ key, height }))
    .sort((a, b) => b.height - a.height);
  const has = (l: string, r: string) =>
    videos.some((v) => v.language === l && qualityKey(v) === r);
  const langLabel = languages.find((l) => l.code === lang)?.label ?? lang;

  return (
    <>
      {languages.length > 1 && (
        <Menu.Root>
          <Menu.Button className="vds-menu-item">
            <Languages
              className="vds-menu-item-icon vds-icon"
              size={20}
              aria-hidden
            />
            <span className="vds-menu-item-label">Language</span>
            <span className="vds-menu-item-hint">{langLabel}</span>
            <ChevronRight
              className="vds-menu-open-icon vds-icon"
              size={16}
              aria-hidden
            />
          </Menu.Button>
          <Menu.Items className="vds-menu-items">
            <Menu.RadioGroup
              className="vds-radio-group"
              value={lang}
              onChange={onLanguage}
            >
              {languages.map(({ code, label }) => (
                <Menu.Radio
                  className="vds-radio"
                  value={code}
                  key={code}
                  style={has(code, res) ? undefined : { opacity: 0.5 }}
                >
                  <div className="vds-radio-check" />
                  <span className="vds-radio-label">{label}</span>
                </Menu.Radio>
              ))}
            </Menu.RadioGroup>
          </Menu.Items>
        </Menu.Root>
      )}
      {qualities.length > 1 && (
        <Menu.Root>
          <Menu.Button className="vds-menu-item">
            <Gauge
              className="vds-menu-item-icon vds-icon"
              size={20}
              aria-hidden
            />
            <span className="vds-menu-item-label">Quality</span>
            <span className="vds-menu-item-hint">{res}</span>
            <ChevronRight
              className="vds-menu-open-icon vds-icon"
              size={16}
              aria-hidden
            />
          </Menu.Button>
          <Menu.Items className="vds-menu-items">
            <Menu.RadioGroup
              className="vds-radio-group"
              value={res}
              onChange={onQuality}
            >
              {qualities.map(({ key }) => (
                <Menu.Radio
                  className="vds-radio"
                  value={key}
                  key={key}
                  style={has(lang, key) ? undefined : { opacity: 0.5 }}
                >
                  <div className="vds-radio-check" />
                  <span className="vds-radio-label">{key}</span>
                </Menu.Radio>
              ))}
            </Menu.RadioGroup>
          </Menu.Items>
        </Menu.Root>
      )}
    </>
  );
}

export function VideoPlayer({ talk }: { talk: Talk }) {
  const videos = talk.media.video.filter((r) => r.html5);
  const subtitles = talk.media.subtitle;
  const { poster, title } = talk;

  // Only load the vidstack player client side, SSR would make clients without
  // javascript unable to play the video
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);

  // Selected source axes (default: best = first, already width-sorted in model).
  const [selLang, setSelLang] = useState<string | null>(null);
  const [selRes, setSelRes] = useState<string | null>(null);
  const player = useRef<MediaPlayerInstance>(null);
  // Carries playback position across a source switch, restored on can-play.
  const resume = useRef<{ time: number; play: boolean } | null>(null);

  // DASH/HLS: hand Vidstack the manifest (it loads dash.js/hls.js and exposes
  // native Quality + Audio menus), so we skip the handrolled progressive menu.
  // These need JS to play, so the no-JS state just shows the poster.
  const manifest = talk.media.dash[0] ?? talk.media.hls[0];
  if (manifest) {
    if (!mounted) {
      return (
        <div className="aspect-video w-full bg-muted">
          {poster && (
            <img src={poster} alt="" className="h-full w-full object-cover" />
          )}
        </div>
      );
    }
    return (
      <MediaPlayer
        className="aspect-video w-full"
        src={manifest.url}
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
              type={t.mimeType === "application/x-subrip" ? "srt" : "vtt"}
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

  const best = videos[0];
  if (!best) return <p>No video recording.</p>;

  const lang = selLang ?? best.language;
  const res = selRes ?? qualityKey(best);
  const has = (l: string, r: string) =>
    videos.some((v) => v.language === l && qualityKey(v) === r);

  function switchTo(l: string, r: string) {
    const p = player.current;
    if (p) resume.current = { time: p.currentTime, play: !p.paused };
    setSelLang(l);
    setSelRes(r);
  }

  function onLanguage(l: string) {
    if (has(l, res)) return switchTo(l, res);
    const best = videos
      .filter((v) => v.language === l)
      .sort((a, b) => (b.height ?? 0) - (a.height ?? 0))[0];
    switchTo(l, best ? qualityKey(best) : res);
  }

  function onQuality(r: string) {
    if (has(lang, r)) return switchTo(lang, r);
    const best = videos
      .filter((v) => qualityKey(v) === r)
      .sort((a, b) => (b.width ?? 0) - (a.width ?? 0))[0];
    switchTo(best ? best.language : lang, r);
  }

  function restorePosition() {
    const r = resume.current;
    const p = player.current;
    if (!r || !p) return;
    p.currentTime = r.time;
    if (r.play) p.play();
    resume.current = null;
  }

  const selected = videos.filter(
    (v) => v.language === lang && qualityKey(v) === res,
  );
  const sources = selected.length ? selected : videos;

  if (!mounted) {
    return (
      <video
        controls
        preload="none"
        poster={poster ?? undefined}
        className="aspect-video w-full"
      >
        {videos.map((s) => (
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
      ref={player}
      onCanPlay={restorePosition}
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
            // Vidstack's caption parser defaults to vtt and ignores the file
            // extension, so SRT must be flagged explicitly or it parses to nothing.
            type={t.mimeType === "application/x-subrip" ? "srt" : "vtt"}
            language={t.language}
            label={t.languageLabel}
          />
        ))}
      </MediaProvider>
      <Poster className="vds-poster" />
      <DefaultVideoLayout
        icons={defaultLayoutIcons}
        slots={
          videos.length > 1
            ? {
                settingsMenuItemsEnd: (
                  <SourceMenus
                    videos={videos}
                    lang={lang}
                    res={res}
                    onLanguage={onLanguage}
                    onQuality={onQuality}
                  />
                ),
              }
            : undefined
        }
      />
    </MediaPlayer>
  );
}
