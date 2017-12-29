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
  },

  setupPlayer: function() {
    var stamp = window.location.hash.split('#t=')[1] || window.location.hash.split('&t=')[1],
        $video = $('video'),
        promises = [];

    $('video source').each(function() {
      var $source = $(this);
      // Prop always presents the fully resolved URL
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
        stretching: 'responsive',
        features: ['skipback', 'playpause', 'jumpforward', 'progress', 'current', 'duration', 'tracks', 'volume', 'speed', 'sourcechooser', 'fullscreen', 'postroll'],
        skipBackInterval: 15,
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
            var hash = '#t='+Math.round(mediaElement.currentTime);
            window.location.replaceHash(hash);
          }, false);
        }
      });
    });
  }
}
