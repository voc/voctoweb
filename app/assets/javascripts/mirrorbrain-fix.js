var MirrorbrainFix = {

  selectMirror: function(url, cb) {
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
  },

  setupPlayer: function() {
    var stamp = window.location.hash.split('&t=')[1],
        $video = $('video'),
        promises = [];

    $('video source').each(function() {
      var $source = $(this);
      // prop always presents the fully resolved url
      promises.push(
        MirrorbrainFix.selectMirror($source.prop('src'), function(mirror) {
        $source.attr('src', mirror);
      })
      );
    });

    $.when.apply($, promises).done(function() {
      $('video').mediaelementplayer({
        usePluginFullScreen: true,
        enableAutosize: true,
        features: ['playpause','progress','current','duration','tracks','volume','fullscreen', 'speed'],
        success: function (mediaElement) {
          mediaElement.addEventListener('canplay', function () {
            if(stamp) {
              mediaElement.setCurrentTime(stamp);
              stamp = null;
            }
          });
          mediaElement.addEventListener('playing', function () {
            $.post("/public/recordings/count", {event_id: $video.data('id'), src: mediaElement.src});
          }, false);
          mediaElement.addEventListener('pause', function() {
            var hash = '#video&t='+Math.round(mediaElement.currentTime);;
            if(window.history && window.history.replaceState) {
              // set new hash without adding an entry into the browser history
              window.history.replaceState(null, "", hash);
            }
            else {
              // classic fallback
              window.location.hash = hash;
            }
          }, false);
        }
      });
    });
  }
}
