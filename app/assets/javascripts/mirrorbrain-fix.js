function selectMirror(url, cb) {
  // always request cdn via https
  url = url.replace(/^http/, 'https') + '.meta4';
  console.log('asking cdn for mirror at', url);
  return $.ajax({
    url: url,
    dataType: 'xml',
    success: function(dom) {
      var
      $dom = $(dom),
      $urls = $dom.find('file url'),
      $url = $($urls.get(0)),
      mirror = $url.text();

      console.log('using mirror', mirror);
      cb(mirror);
    }
  });
}

