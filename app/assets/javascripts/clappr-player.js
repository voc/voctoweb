$(function() {
  function deserialize(string) {
    var result = {};
    if (string) {
      var parts = string.split(/&|\?/);
      for (var i = 0; i < parts.length; i++) {
        var part = parts[i].split("=");
        if (part.length === 2)
          result[decodeURIComponent(part[0])] = decodeURIComponent(part[1]);
      }
    }
    return result;
  }

  var $clapprPlayer = $('.clappr-player .video-wrap');
  if($clapprPlayer.length > 0) {
    var sprites = [];


    var player = new Clappr.Player({
      baseUrl: 'assets/clapprio/',
      plugins: [
        ClapprThumbnailsPlugin, DashShakaPlayback, PlaybackRatePlugin, Timelens
      ],

      sources: $clapprPlayer.data('sources'),
      //sources: $clapprPlayer.find('video').find('source').toArray().map(x => x.src),
      height: $clapprPlayer.data('height'),
      width: $clapprPlayer.data('width'),
      poster: $clapprPlayer.data('poster'),
      timelens: {
        timeline: $clapprPlayer.data('timeline'),
        thumbnails: $clapprPlayer.data('thumbnails')
      },
      scrubThumbnails: {
        backdropHeight: 64,
        spotlightHeight: 84,
        thumbs: sprites
      },
      events: {
        onReady: function() {
          var playback = player.core.getCurrentContainer().playback;
          var params = deserialize(location.href)

          playback.once(Clappr.Events.PLAYBACK_PLAY, function() {
            var seek = parseFloat(params.t);
            if (!isNaN(seek)) {
              player.seek(seek);
            } 
          });
        }
      }
    });
    console.log(player);
    player.attachTo($clapprPlayer.get(0));
  }
});
