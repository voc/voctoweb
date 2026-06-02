var MirrorbrainFix = {
  selectMirror: function (url, cb) {
    // Always request CDN via https
    url = url.replace(/^http:/, 'https:');
    return fetch(url, { headers: { Accept: 'application/json' } })
      .then((response) => response.json())
      .then((dom) => {
        const mirror = dom.MirrorList[0].HttpURL + dom.FileInfo.Path;
        cb(mirror);
      })
      // Best-effort: on any failure keep the original src so the player still builds.
      .catch(function () { /* no mirror — leave the source untouched */ });
  }
}
