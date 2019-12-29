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

  function tryInitRelivePlayer() {
    var $relivePlayer = $(".relive-player .video-wrap");
    if ($relivePlayer.length > 0) {
      var sprites = [];

      if ($relivePlayer.data("sprites")) {
        sprites = ClapprThumbnailsPlugin.buildSpriteConfig(
          $relivePlayer.data("sprites"),
          $relivePlayer.data("sprites-n"),
          160,
          90,
          $relivePlayer.data("sprites-cols"),
          $relivePlayer.data("sprites-interval")
        );
      }

      var player = new Clappr.Player({
        baseUrl: "assets/clapprio/",
        plugins: {
          core: [ClapprThumbnailsPlugin, PlaybackRatePlugin]
        },

        source: $relivePlayer.data("m3u8"),
        height: $relivePlayer.data("height"),
        width: $relivePlayer.data("width"),
        autoPlay: true,
        scrubThumbnails: {
          backdropHeight: 64,
          spotlightHeight: 84,
          thumbs: sprites
        },
        events: {
          onReady: function() {
            var playback = player.core.getCurrentContainer().playback;
            var params = deserialize(location.href);

            playback.once(Clappr.Events.PLAYBACK_PLAY, function() {
              var seek = parseFloat(params.t);
              if (!isNaN(seek)) {
                player.seek(seek);
              } else if (playback.getPlaybackType() == "vod") {
                // skip forward to scheduled beginning of the talk at ~ 0:14:30  (30 sec offset, if speaker starts on time)
                player.seek(14 * 60 + 30);
              }
            });
          }
        }
      });
      player.attachTo($relivePlayer.get(0));
    }
  }

  $(document).on('turbolinks:load', function() {
    tryInitRelivePlayer();
  });

});
