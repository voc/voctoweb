var MirrorbrainFix = {
  selectMirror: function(url, cb) {
    // Always request CDN via https
    url = url.replace(/^http/, 'https');
    console.log('asking cdn for mirror at', url);
    return $.ajax({
      url: url,
      dataType: 'json',
      success: function(dom) {
        var mirror = dom.MirrorList[0].HttpURL + dom.FileInfo.Path;

        console.log('using mirror', mirror);
        cb(mirror);
      }
    });
  }
}
