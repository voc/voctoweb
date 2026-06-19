/**
 * YouTube-style gestures & keyboard shortcuts for the mediaelement player.
 *
 * Split into small pieces:
 *   PlayerControls  — actions on the player/media (seek, play, rate, fullscreen)
 *   GestureHud      — on-screen feedback (2x badge, seek flash, rate toast)
 *   HoldToSpeed     — the press-and-hold-for-2x state machine
 *   Hotkeys         — keyboard shortcuts (maps keys to player actions)
 *   PointerGestures — pointer tap/double gestures (mouse/touch/pen, no hold)
 *   PlayerGestures  — decodes pointer events and routes the press lifecycle to
 *                     HoldToSpeed + PointerGestures, wires the inputs to the model,
 *                     owns the shared seek/rate actions; one player active at a
 *                     time, survives Turbolinks visits
 *
 * Gestures and keys:
 *  - click (mouse) ................... play / pause (deferred briefly to spot a double-click)
 *  - double-click (mouse) ............ toggle fullscreen
 *  - tap (touch) ..................... show / hide controls; tap the play button to resume
 *  - double-tap left/right (touch) ... seek -/+ SEEK seconds (keep tapping to keep seeking)
 *  - double-tap centre (touch) ....... play / pause
 *  - space / k ....................... play / pause
 *  - space (hold) .................... temporary 2x playback while held
 *  - click / tap and hold ............ temporary 2x playback while held
 *  - j / l / left / right arrows ..... seek -/+ SEEK seconds
 *  - , / . ........................... step one frame back / forward (pauses)
 *  - < / > (or shift+, / shift+.) .... playback speed down / up (0.25 steps)
 *  - 0-9 ............................. jump to that tenth of the duration
 */

/** Actions on the underlying mediaelement player / media element. */
class PlayerControls {
  constructor(player, media) {
    this.player = player;
    this.media = media;
  }

  get paused() { return this.media.paused; }
  get rate() { return this.media.playbackRate || 1; }
  set rate(r) { this.media.playbackRate = r; }

  play() { this.media.play(); }
  pause() { this.media.pause(); }
  togglePlay() { this.media.paused ? this.media.play() : this.media.pause(); }

  toggleFullScreen() {
    if (this.player.isFullScreen) { this.player.exitFullScreen(); } else { this.player.enterFullScreen(); }
  }

  /* Clamp a time to [0, duration]; so seeks don't go past the start or end. */
  clampTime(t) {
    var d = this.media.duration;
    if (isNaN(d) || !isFinite(d)) { return Math.max(t, 0); }
    return Math.min(Math.max(t, 0), d);
  }

  seekBy(delta) {
    this.media.currentTime = this.clampTime(this.media.currentTime + delta);
  }

  /**
   * Seek to a fraction of the duration, used for 0-9 key presses.
   */
  seekToFraction(frac) {
    var d = this.media.duration;
    if (isNaN(d) || !isFinite(d)) { return; }
    this.media.currentTime = this.clampTime(d * frac);
  }

  /**
   * Try to roughly advance a single frame in the given direction.
   * @param dir +1 or -1 for forward or backward
   */
  frameStep(dir, frameTime) {
    if (!this.media.paused) { this.media.pause(); }
    this.media.currentTime = this.clampTime(this.media.currentTime + dir * frameTime);
  }

  /**
   * Change the playback rate and sync the speed plugin's menu afterwards.
   */
  changeRate(delta) {
    var rate = Math.min(Math.max(this.rate + delta, 0.25), 4);
    rate = Math.round(rate * 100) / 100; // avoid float drift
    this.media.playbackRate = rate;
    this.syncSpeedMenu(rate);
    return rate;
  }

  /**
   * Try to sync the speed plugin's menu to the current playback rate by
   * emulating a click on the matching preset radio button.
   */
  syncSpeedMenu(rate) {
    var radios = this.player.speedRadioButtons;
    if (!radios) { return; }
    for (var i = 0; i < radios.length; i++) {
      if (parseFloat(radios[i].value) === rate) {
        radios[i].click();
        return;
      }
    }
    var button = this.player.speedButton && this.player.speedButton.querySelector('button');
    if (button) { button.innerHTML = rate.toFixed(2) + 'x'; }
  }
}

/** On-screen gesture feedback: the 2x badge, the seek flash, the rate toast. */
class GestureHud {
  constructor(container, fastRate) {
    this.fastBadge = GestureHud.ensure(container, 'mejs-gesture-fast');
    // YouTube-style pill: "2x" followed by a fast-forward (double-triangle) icon
    this.fastBadge.innerHTML =
      '<span class="mejs-gesture-fast-label">' + fastRate + 'x</span>' +
      '<svg class="mejs-gesture-fast-icon" viewBox="0 0 24 24" aria-hidden="true">' +
      '<path d="M4 18l8.5-6L4 6v12zm9-12v12l8.5-6L13 6z"></path>' +
      '</svg>';

    this.seekFx = GestureHud.ensure(container, 'mejs-gesture-seek');
    this.rateToast = GestureHud.ensure(container, 'mejs-gesture-rate');
    this.seekFxTimer = null;
    this.rateToastTimer = null;
  }

  // Reuse an existing overlay of this class (Turbolinks re-attach) or create it.
  static ensure(container, className) {
    var el = container.querySelector('.' + className);
    if (!el) {
      el = document.createElement('div');
      el.className = className;
      container.appendChild(el);
    }
    return el;
  }

  showFast(on) {
    this.fastBadge.classList.toggle('is-active', on);
  }

  flashRate(rate) {
    var toast = this.rateToast;
    toast.textContent = rate + 'x';
    toast.classList.add('is-active');
    clearTimeout(this.rateToastTimer);
    this.rateToastTimer = setTimeout(function () { toast.classList.remove('is-active'); }, 800);
  }

  flashSeek(delta) {
    var fx = this.seekFx;
    fx.textContent = (delta < 0 ? '« ' : '') + Math.abs(delta) + 's' + (delta > 0 ? ' »' : '');
    fx.classList.remove('left', 'right');
    fx.classList.add(delta < 0 ? 'left' : 'right', 'is-active');
    clearTimeout(this.seekFxTimer);
    this.seekFxTimer = setTimeout(function () { fx.classList.remove('is-active'); }, 500);
  }
}

/** Press-and-hold (space or pointer) -> temporary fast playback while held. */
class HoldToSpeed {
  constructor(controls, hud, fastRate, holdMs) {
    this.controls = controls;
    this.hud = hud;
    this.fastRate = fastRate;
    this.holdMs = holdMs;
    this.timer = null;
    this.active = false;   // currently sped up
    this.savedRate = 1;
    this.wasPaused = false;
  }

  /**
   * Start the hold timer. This will speed up the playback rate once the timer
   * elapses, and then restore the prior rate and paused state.
   * 
   * If the timer is already running, or it is already active, do nothing.
   * 
   * If the hold is released before the timer elapses, the timer is cancelled.
   */
  start() {
    if (this.timer || this.active) { return; }
    var self = this;
    this.timer = setTimeout(function () {
      self.timer = null;
      self.savedRate = self.controls.rate;
      self.wasPaused = self.controls.paused;
      if (self.wasPaused) { self.controls.play(); }
      self.controls.rate = self.fastRate;
      self.active = true;
      self.hud.showFast(true);
    }, this.holdMs);
  }

  /**
   * Drop the pending timer and, if we were sped up, restore the prior rate and
   * paused state.
   */
  end() {
    if (this.timer) { clearTimeout(this.timer); this.timer = null; }
    if (this.active) {
      this.controls.rate = this.savedRate;
      if (this.wasPaused) { this.controls.pause(); }
      this.active = false;
      this.hud.showFast(false);
    }
  }
}

/**
 * Keyboard shortcuts will also handle stuff related to keys for other modules such as
 * the hold-to-speed.
 */
class Hotkeys {
  constructor(host) {
    this.host = host;
    this.spaceDown = false;
    this.onKeyDown = this.onKeyDown.bind(this);
    this.onKeyUp = this.onKeyUp.bind(this);
  }

  static isSpace(e) {
    return e.key === ' ' || e.code === 'Space' || e.keyCode === 32;
  }

  /* clear spaceDown on blur */
  onBlur() {
    this.spaceDown = false;
  }

  onKeyDown(e) {
    if (e.ctrlKey || e.metaKey || e.altKey) { return; } // leave browser shortcuts alone
    var host = this.host;

    if (Hotkeys.isSpace(e)) {
      e.preventDefault(); // stop the page from scrolling
      if (!this.spaceDown) { this.spaceDown = true; host.hold.start(); }
      return;
    }

    var k = e.key;
    var handled = true;
    if (k === 'k' || k === 'K') {
      host.controls.togglePlay();
    } else if (k === 'j' || k === 'J' || k === 'ArrowLeft') {
      host.seek(-host.seekSeconds);
    } else if (k === 'l' || k === 'L' || k === 'ArrowRight') {
      host.seek(host.seekSeconds);
    } else if (k === '<' || (e.shiftKey && e.code === 'Comma')) {
      host.adjustRate(-0.25);
    } else if (k === '>' || (e.shiftKey && e.code === 'Period')) {
      host.adjustRate(0.25);
    } else if (k === ',') {
      host.controls.frameStep(-1, host.frameTime);
    } else if (k === '.') {
      host.controls.frameStep(1, host.frameTime);
    } else if (k.length === 1 && k >= '0' && k <= '9') {
      host.controls.seekToFraction((+k) / 10);
    } else {
      handled = false;
    }

    if (handled) { e.preventDefault(); }
  }

  onKeyUp(e) {
    if (!Hotkeys.isSpace(e)) { return; }
    e.preventDefault();
    this.spaceDown = false;
    var wasHold = this.host.hold.active;
    this.host.hold.end();
    if (!wasHold) { this.host.controls.togglePlay(); } // quick press: play/pause; a hold just restores
  }
}

/**
 * Pointer tap gestures (mouse/touch/pen): tap/click to play-pause, double-tap to
 * seek (touch) or double-click to fullscreen (mouse).
 *
 * PlayerGestures decodes the raw pointer events and drives the press lifecycle
 * here via press()/release(), passing whether the press turned into a 2x hold —
 * so this stays independent of HoldToSpeed. We own play/pause (the player's
 * clickToPlayPause is off), so there's no stray click to suppress.
 */
class PointerGestures {
  constructor(host) {
    this.host = host;
    this.pointerType = 'mouse';
    this.clickTimer = null; // mouse: pending deferred single-click (see mouseTap)
    this.tapTimer = null;   // touch: open double-tap / seek-streak window (see touchTap)
  }

  /**
   * A click/tap started, remember the pointer type
   */
  press(e) {
    this.pointerType = e.pointerType;
  }

  /**
   * Handle a pointer release event.
   * @param {boolean} wasHold if the press turned into a 2x hold rather than a tap
   */
  release(e, wasHold) {
    if (wasHold) { this.reset(); return; } // a hold is not a tap

    // we differentiate between mouse and touch here so we can
    // handle them differently
    if (this.pointerType === 'mouse') {
      this.mouseTap();
    } else {
      this.touchTap(e);
    }
  }

  /**
   * We slightly defer the the single click (play/pause) so we can tell a single
   * click from a double-click (fullscreen)
   */
  mouseTap() {
    if (this.clickTimer) {
      // timer was still active so this is a double-click
      // drop the buffered single click so we don't toggle pause
      clearTimeout(this.clickTimer);
      this.clickTimer = null;
      this.host.controls.toggleFullScreen();
      return;
    }
    this.clickTimer = setTimeout(() => {
      this.clickTimer = null;
      this.host.controls.togglePlay();
    }, this.host.doubleClickMs);
  }

  /**
   * Detect double tapping using a timer.
   * Double tapping the left/right seeks, the center toggles play/pause
   */
  touchTap(e) {
    var inWindow = this.tapTimer !== null;
    var zone = this.zoneOf(e.clientX); // -1 left, +1 right, 0 center

    // clear the ongoing timer
    if (this.tapTimer) { clearTimeout(this.tapTimer); this.tapTimer = null; }

    if (inWindow) {
      // handle double-tap
      if (zone === 0) {
        // center was double-tapped: toggle play/pause
        this.host.controls.togglePlay();
        return; // we don't need a third tap to toggle again so return early
      } else {
        // direction was double-tapped: seek
        this.host.seek(zone * this.host.seekSeconds);
      }
    }

    // start a timer that is used to detect the double tap or any subsequent multi-tap after seek
    this.tapTimer = setTimeout(() => { this.tapTimer = null; }, this.host.doubleTapMs);
  }

  /** Which third of the player an x coordinate falls in: -1 left, +1 right, 0 center. */
  zoneOf(x) {
    var rect = this.host.container.getBoundingClientRect();
    var rel = (x - rect.left) / rect.width;
    if (rel < 0.4) { return -1; }
    if (rel > 0.6) { return 1; }
    return 0;
  }

  /**
   * press cancelled or focus lost: forget the touch double-tap window and drop any
   * pending deferred mouse click (so it doesn't fire after we've navigated away).
   */
  reset() {
    if (this.clickTimer) { clearTimeout(this.clickTimer); this.clickTimer = null; }
    if (this.tapTimer) { clearTimeout(this.tapTimer); this.tapTimer = null; }
  }
}

/**
 * Coordinates the player model (PlayerControls, GestureHud, HoldToSpeed) and the
 * input components (Hotkeys for keyboard, PointerGestures for mouse/touch/pen),
 * and owns the seek/rate actions both inputs share.
 * 
 * Because only one player is active at a time we reuse this and just change which player
 * we target. We will also unbind from the player when navigating via turbolinks.
 */
class PlayerGestures {
  constructor(player, media, container, opts) {
    this.container = container;
    this.controls = new PlayerControls(player, media);
    this.hud = new GestureHud(container, opts.fastRate);
    this.hold = new HoldToSpeed(this.controls, this.hud, opts.fastRate, opts.holdMs);
    this.hotkeys = new Hotkeys(this);
    this.pointer = new PointerGestures(this);

    this.seekSeconds = opts.seekSeconds;
    this.frameTime = opts.frameTime;
    this.doubleClickMs = opts.doubleClickMs;
    this.doubleTapMs = opts.doubleTapMs;
    this.pressing = false;

    // mediaelement's big centre play button (when present): toggle playback on click,
    // and swallow the press so the region gestures below never see it.
    this.bigPlay = container.querySelector('.mejs__overlay-button');

    // keyboard goes straight to Hotkeys; raw pointer events are decoded here and
    // fanned out to HoldToSpeed and PointerGestures (see the pointer section)
    this.handlers = {
      keydown: this.hotkeys.onKeyDown,
      keyup: this.hotkeys.onKeyUp,
      focusout: this.onFocusOut.bind(this),
      pointerdown: this.onPointerDown.bind(this),
      pointerup: this.onPointerUp.bind(this),
      pointercancel: this.onPointerCancel.bind(this),
      contextmenu: this.onContextMenu.bind(this)
    };
    this.bigPlayHandlers = {
      // stop the press at the button so the container gestures (hold-to-speed, the
      // mouse/touch tap handlers) never fire for it
      pointerdown: function (e) { e.stopPropagation(); },
      click: this.onBigPlay.bind(this)
    };
  }

  seek(delta) {
    this.controls.seekBy(delta);
    this.hud.flashSeek(delta);
  }

  adjustRate(delta) {
    this.hud.flashRate(this.controls.changeRate(delta));
  }

  isOnControlsBar(target) {
    return target && target.closest && target.closest('.mejs__controls');
  }

  /** The big centre play/pause button toggles playback (only shown while paused). */
  onBigPlay(e) {
    e.stopPropagation();
    this.controls.togglePlay();
  }

  onPointerDown(e) {
    // primary button / first finger only, never over the controls bar
    if (!e.isPrimary || e.button !== 0 || this.isOnControlsBar(e.target)) { return; }
    this.pressing = true;
    this.container.setPointerCapture(e.pointerId);
    this.hold.start();    // hold-to-speed starts its timer
    this.pointer.press(e); // pointer notes the press for tap detection
  }

  onPointerUp(e) {
    if (!this.pressing) { return; }
    this.pressing = false;
    var wasHold = this.hold.active; // read before ending, to tell the tap handler
    this.hold.end();
    this.pointer.release(e, wasHold);
  }

  onPointerCancel() {
    if (!this.pressing) { return; }
    this.pressing = false;
    this.hold.end();
    this.pointer.reset();
  }

  /** block the native long-press menu opening the context menu instead of seeking. */
  onContextMenu(e) {
    if (this.pressing || this.hold.active) { e.preventDefault(); }
  }

  /** and any hold or started double tap */
  onBlur() {
    this.pressing = false;
    this.hold.end();
    this.hotkeys.onBlur();
    this.pointer.reset();
  }

  onFocusOut(e) {
    // ignore focus moving between elements inside the player
    if (e.relatedTarget && this.container.contains(e.relatedTarget)) { return; }
    this.onBlur();
  }

  /** attach event handlers to the container */
  bindContainer() {
    var c = this.container, h = this.handlers;
    c.addEventListener('keydown', h.keydown);
    c.addEventListener('keyup', h.keyup);
    c.addEventListener('focusout', h.focusout);
    c.addEventListener('pointerdown', h.pointerdown);
    c.addEventListener('pointerup', h.pointerup);
    c.addEventListener('pointercancel', h.pointercancel);
    c.addEventListener('contextmenu', h.contextmenu);
    if (this.bigPlay) {
      this.bigPlay.addEventListener('pointerdown', this.bigPlayHandlers.pointerdown);
      this.bigPlay.addEventListener('click', this.bigPlayHandlers.click);
    }
  }

  /** remove event handlers from the container */
  unbindContainer() {
    var c = this.container, h = this.handlers;
    c.removeEventListener('keydown', h.keydown);
    c.removeEventListener('keyup', h.keyup);
    c.removeEventListener('focusout', h.focusout);
    c.removeEventListener('pointerdown', h.pointerdown);
    c.removeEventListener('pointerup', h.pointerup);
    c.removeEventListener('pointercancel', h.pointercancel);
    c.removeEventListener('contextmenu', h.contextmenu);
    if (this.bigPlay) {
      this.bigPlay.removeEventListener('pointerdown', this.bigPlayHandlers.pointerdown);
      this.bigPlay.removeEventListener('click', this.bigPlayHandlers.click);
    }
  }

  /**
   * Attach to a player binding event handlers and setting the active player.
   */
  static attach(player, media, options) {
    options = options || {};
    var container = player.getElement(player.container);
    if (!container) { return; }

    // We re-implement these keys ourselves (Hotkeys) — drop mediaelement's own
    // bindings so they don't double-fire. Volume (up/down) and Esc stay with it.
    PlayerGestures.dropOverriddenKeyActions(player);

    if (PlayerGestures.active) {
      PlayerGestures.active.unbindContainer();
    }

    var instance = new PlayerGestures(player, media, container, {
      seekSeconds: options.seekSeconds || 10,
      holdMs: options.holdThreshold || 500,
      frameTime: options.frameTime || (1 / 30),
      fastRate: options.fastRate || 2,
      doubleClickMs: options.doubleClickMs || 250,
      doubleTapMs: options.doubleTapMs || 300
    });
    PlayerGestures.active = instance;
    instance.bindContainer();
    PlayerGestures.bindDocumentOnce();
  }

  /**
   * Remove mediaelement keyActions for the keys Hotkeys overrides: ← / → seek
   * (the progress feature) and < / > speed step (the speed plugin). Matched by
   * keyCode, including the IME/alias codes mediaelement bundles alongside them.
   */
  static dropOverriddenKeyActions(player) {
    var overridden = [37, 39, 60, 62, 188, 190]; // ← → and < > (shift+, / shift+.)
    var actions = player.options && player.options.keyActions;
    if (!actions) { return; }
    player.options.keyActions = actions.filter(function (action) {
      return !action.keys.some(function (k) { return overridden.indexOf(k) !== -1; });
    });
  }

  /**
   * We only document wide listeners once. These are for stuff like global blur
   * and turbolinks events.
   */
  static bindDocumentOnce() {
    if (PlayerGestures.docBound) { return; }
    PlayerGestures.docBound = true;
    window.addEventListener('blur', function () {
      if (PlayerGestures.active) { PlayerGestures.active.onBlur(); }
    });
    document.addEventListener('turbolinks:before-cache', function () {
      if (!PlayerGestures.active) { return; }
      PlayerGestures.active.onBlur();
      PlayerGestures.active.unbindContainer();
      PlayerGestures.active = null;
    });
  }
}

// the single currently-attached player, and whether the document listeners are bound
PlayerGestures.active = null;
PlayerGestures.docBound = false;

window.PlayerGestures = PlayerGestures;
