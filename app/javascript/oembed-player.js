// esbuild entry point for the oembed/iframe embed bundle. Reduced subset of
// application.js's manifest - deliberately excludes bxslider/theme/feed_toggle/
// mastodon-share/clappr/relive-seek/turbolinks/bootstrap.
//
// When adding plugins here, also add them to application.js.

import jquery from 'jquery';
window.jQuery = jquery;
window.$ = jquery;

import './replacehash';
import './mirrorbrain-fix';
import './subtitle-loader';
import './player-deeplinks';
import './vendor/mediaelement-and-player';
import './mejs-player';
import './player-gestures';

import './mediaelement-plugins/source-chooser/source-chooser';
import './mediaelement-plugins/speed/speed';
import './mediaelement-plugins/skip-back/skip-back';
import './mediaelement-plugins/jump-forward/jump-forward';

import './vendor/timelens';
