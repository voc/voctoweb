// esbuild entry point for the main frontend bundle. Mirrors the previous Sprockets
// application.js manifest, in the same require order, file for file.
//
// When adding plugins here, also add them to oembed.js.

import './vendor/jquery-global';

import './replacehash';
import 'jquery-ujs';
import 'bootstrap-sass/assets/javascripts/bootstrap';
// turbolinks' UMD auto-start check does `window.Turbolinks === <module>`, but
// under esbuild's CJS interop the module factory runs with `this` bound to
// module.exports rather than window, so the auto-start's own `this.Turbolinks =`
// assignment never reaches window and the check silently fails. Start explicitly.
import Turbolinks from 'turbolinks';
Turbolinks.start();

import './vendor/purl.min';
import './vendor/handlebars.min-latest';
import './vendor/jquery.bxslider';
import './slider';
import './theme';
import './feed_toggle';
import './mastodon-share';

import './mirrorbrain-fix';
import './subtitle-loader';
import './player-deeplinks';
import './vendor/mediaelement-and-player';
import './mejs-player';
import './player-gestures';
import './mediaelement-plugins/source-chooser/source-chooser';
import './mediaelement-plugins/speed/speed';
import './mediaelement-plugins/postroll/postroll';
import './mediaelement-plugins/skip-back/skip-back';
import './mediaelement-plugins/jump-forward/jump-forward';
import './mediaelement-plugins/playlist/playlist';

import './vendor/player.umd';
import './vendor/clappr-thumbnails-plugin.cjs';
import './vendor/clappr-playback-rate-plugin.cjs';

import './relive-seek';

import './vendor/timelens';
import './activate-timelens';
