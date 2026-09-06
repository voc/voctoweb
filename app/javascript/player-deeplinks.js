/*
 * Deep-link helpers for the player: #t=<seconds>, #l=<language>, #s=<subtitle lang>.
 *
 * Pure helpers, no event wiring — the player's success callback does the glue
 * (seek on canplay, hash writeback on pause/seek, view counter on playing,
 * subtitle pick for #s=). That keeps the player-specific bits next to the player
 * setup and leaves this file as portable DOM/URL plumbing.
 *
 * node  = the original <video>/<audio> element (<source> children + data-id)
 * media = the playing element / wrapper (currentTime, src, media events)
 */
class PlayerDeepLinks {
  /**
   * Get a single parameter from the location hash.
   */
  static param(name) {
    var params = new URLSearchParams(window.location.hash && window.location.hash.split('#')[1]);
    return params.get(name);
  }

  // DOM tweaks that must happen before the player is built.
  /**
   * Prepare the player for deep links before initializing mejs for it.
   * This includes things such as removing the poster (thumbnail showing 
   * before playing) when linking to a specific time.
   */
  static prepare(node) {
    var stamp = PlayerDeepLinks.param('t'),
      lang = PlayerDeepLinks.param('l');

    // poster is the thumbnail the player overlays until you hit play. With a #t=
    // deep link we seek before playing, and that overlay would hide the seeked 
    // frame.
    if (stamp) {
      node.removeAttribute('poster');
    }

    // Preselect the language from the URL (#l=eng). Each <source> is a language
    // variant tagged with data-lang; the player takes the first one it can play
    // and has no "start in language X" option, so we move the requested one to
    // the front. (Used to be a startLanguage patch in source-chooser.js.)
    if (lang) {
      var match = node.querySelector('source[data-lang="' + lang + '"]');
      if (match) {
        node.insertBefore(match, node.firstChild);
      }
    }
  }

  /**
   * Get the default language by selecting the first source in the list.
   * Read this BEFORE prepare() reorders the sources.
   */
  static defaultLang(node) {
    var first = node.querySelector('source');
    return first ? (first.dataset.lang || '') : '';
  }

  /**
   * Get the current language by checking the language of the source with the
   * same url as the currently playing one.
   */
  static currentLang(node, media) {
    var sources = node.querySelectorAll('source');
    for (var i = 0; i < sources.length; i++) {
      if (sources[i].getAttribute('src') === media.src) {
        return sources[i].dataset.lang || '';
      }
    }
    return '';
  }

  /**
   * Build the hash for the current position. Also include the subtitle if
   * selected and the language if it differs from the default.
   */
  static buildHash(node, media, srt, defaultLang) {
    var lang = PlayerDeepLinks.currentLang(node, media);
    var withLang = lang && lang !== defaultLang;
    var hash = (withLang ? '#l=' + lang + '&t=' : '#t=') + Math.round(media.currentTime);
    if (srt) {
      hash += '&s=' + srt;
    }
    return hash;
  }
}

window.PlayerDeepLinks = PlayerDeepLinks;
