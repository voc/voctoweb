/**
 * newer versions of mediaelement no longer support the use of subtitle formats
 * other than the browser's native WebVTT, so we need to convert SRT to WebVTT
 * ourselves.
 * 
 * We do the conversion locally and make it available as blob: URLs, so the 
 * browser can load it without CORS. CORS could otherwise also cause issues
 * with mirrors, and my not work unless the <video> is in CORS mode.
 * 
 * This uses some more modern JS
 */
class SubtitleLoader {
  /**
   * select all subtitle <track> elements, fetch their URL, convert to WebVTT,
   * and set the src to a blob: URL. The browser will load the subtitles
   * without CORS, so the video can start playing.
   * 
   * If this conversion fails, the original src is left intact and the video
   * will load as normal, just without usable subtitles.
   */
  static prepare(media) {
    var promises = [];
    media.querySelectorAll('track[kind="subtitles"], track[kind="captions"]').forEach(function (track) {
      var src = track.getAttribute('src');
      if (!src) { return; }

      promises.push(
        fetch(src)
          .then(function (response) {
            if (!response.ok) { throw new Error('HTTP ' + response.status); }
            return response.text();
          })
          .then(function (text) {
            var vtt = SubtitleLoader.toVtt(text),
              blob = new Blob([vtt], { type: 'text/vtt' });
            track.setAttribute('src', URL.createObjectURL(blob));
          })
          .catch(function () { /* leave original src */ })
      );
    });
    return promises;
  }

  /**   * Convert SRT file bodies to VTT format.
   * The most important bit is the timestamp format conversion, but it will also
   * rewrite formatting tags to <i>/<b>/<u>. This tag conversion can break input
   * that is already in VTT format, so it's best to only call this on SRT input.
   * Line endings are normalized to \n and the body is terminated with a blank
   * line so the last cue always parses.
   */
  static srtBodyToVtt(text) {
    return text
      .replace(/\r\n|\r/g, '\n')
      .replace(/\{\\([ibu])\}/g, '</$1>')
      .replace(/\{\\([ibu])1\}/g, '<$1>')
      .replace(/\{([ibu])\}/g, '<$1>')
      .replace(/\{\/([ibu])\}/g, '</$1>')
      .replace(/(\d\d:\d\d:\d\d),(\d\d\d)/g, '$1.$2')
      .concat('\n\n');
  }

  /**
   * Convert SRT to WebVTT.
   * If the text is already in VTT format it is returned unchanged. Otherwise
   * the leading BOM (if any) is stripped, the body is converted via
   * srtBodyToVtt, and the WEBVTT header is prepended.
   */
  static toVtt(text) {
    if (/^\s*WEBVTT/.test(text)) {
      return text;
    }
    text = text.replace(/^\uFEFF/, '');
    return 'WEBVTT\n\n' + SubtitleLoader.srtBodyToVtt(text);
  }
}

window.SubtitleLoader = SubtitleLoader;
