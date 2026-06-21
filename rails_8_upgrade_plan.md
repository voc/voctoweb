# Voctoweb: Rails 8.0 Upgrade & Asset Modernization Plan (pnpm + esbuild + Propshaft)

This document details the upgrade of **Voctoweb** to **Rails 8.0.x** and the migration of the asset pipeline from **Sprockets** to **Propshaft**, managed through **pnpm** and **esbuild**.

By adopting this stack, you will be able to manage your frontend player libraries (MediaElement, Clappr, Shaka) via NPM modules rather than committing compiled javascript assets directly to your repository history.

---

## 1. Core Architecture Decisions

1.  **Direct Upgrade (Single Branch):** Skip the dual-booting configuration and execute the upgrade directly on an upgrade branch.
2.  **Asset Pipeline:** Migrate from Sprockets to **Propshaft**.
3.  **JS Bundling:** Use **`jsbundling-rails`** running **esbuild** to compile javascript entry points.
4.  **CSS Bundling:** Use **`cssbundling-rails`** running **sass** to compile SCSS assets.
5.  **Package Manager:** Use **pnpm** to manage frontend packages. Having `pnpm-lock.yaml` in the root of the project automatically tells Rails to use `pnpm` for assets compilation.
6.  **Infrastructure:** Retain **Redis** and **Sidekiq 8.0** for background processing and caching.

---

## 2. Dependencies Migration (Gemfile & package.json)

### Gemfile Changes
Remove legacy Sprockets and unused gems, and add the Propshaft/bundlers:

```ruby
# Remove these gems
gem 'sprockets-rails'
gem 'sass-rails'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'

# Add these gems
gem 'propshaft'
gem 'jsbundling-rails'
gem 'cssbundling-rails'
```

### package.json Setup via pnpm
Initialize your package metadata and install core packages and players:

```bash
# 1. Initialize pnpm package configuration
pnpm init

# 2. Add build tooling to development dependencies
pnpm add -D esbuild sass

# 3. Add core Rails dependencies and layout requirements
pnpm add @hotwired/turbo-rails jquery bootstrap@3

# 4. Add video/audio players from the NPM registry
pnpm add mediaelement clappr shaka-player
```

Your `package.json` should contain the following scripts to build JS and CSS:
```json
{
  "scripts": {
    "build": "esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds --public-path=/assets",
    "build:css": "sass ./app/assets/stylesheets/application.bootstrap.scss:./app/assets/builds/application.css --no-source-map --load-path=node_modules"
  }
}
```

---

## 3. Step-by-Step Migration Guide

### Step 1: Clean Up Git History
Delete the legacy players and unused config files from your repository:
*   `app/assets/javascripts/clappr-dash-shaka-playback.js`
*   `app/assets/javascripts/jquery.bxslider-v4.2.1d-ssfrontend.js`
*   `app/assets/javascripts/active_admin.js.coffee` (deleted in previous step)
*   `vendor/assets/mediaelement/`
*   `vendor/assets/mediaelement-plugins/`

### Step 2: Configure Javascript Entry Points
1.  **Expose jQuery globally:** Old plugins and layouts expect `$` on the `window`. Add this to `app/javascript/application.js`:
    ```javascript
    import jquery from 'jquery';
    window.jQuery = jquery;
    window.$ = jquery;
    ```
2.  **Import player modules:** Add imports for the player packages:
    ```javascript
    import 'mediaelement/build/mediaelement-and-player.js';
    import Clappr from 'clappr';
    import ShakaPlayer from 'shaka-player';

    window.Clappr = Clappr;
    window.shaka = ShakaPlayer;
    ```
3.  **ActiveAdmin entry point:** Create [app/javascript/active_admin.js](file:///home/mm/co/voctoweb/app/assets/javascripts/active_admin.js) containing only:
    ```javascript
    import "@activeadmin/activeadmin";
    ```
4.  **Refactor `mejs-player.js.erb` to `mejs-player.js`:**
    Remove the ERB interpolation (`<%= asset_path(...) %>`). Instead, retrieve player control SVG assets dynamically at runtime using HTML5 data attributes:
    ```javascript
    // In mejs-player.js
    const configEl = document.getElementById('player-config');
    const options = {
      iconSprite: configEl.dataset.controlsSvg,
      iconSpritePathSkipBack: configEl.dataset.skipBackSvg,
      iconSpritePathJumpForward: configEl.dataset.jumpForwardSvg
    };
    ```

### Step 3: Configure CSS Entry Point
Create `app/assets/stylesheets/application.bootstrap.scss` and import Bootstrap 3 and the players:
```scss
// Import Bootstrap 3 from node_modules
@import "bootstrap/dist/css/bootstrap.css";

// Import your custom SCSS sheets
@import "frontend/styles";
@import "mediaelement/build/mediaelementplayer.css";
```

### Step 4: Upgrade Rails
1.  Change your `Gemfile` Rails version constraint to `gem 'rails', '~> 8.0.0'`.
2.  Run `pnpm install` (this generates `pnpm-lock.yaml` which tells Rails to compile assets using `pnpm`).
3.  Run `bundle install`.
4.  Run the update task:
    ```bash
    bin/rails app:update
    ```
5.  Remove Sprockets compression setups in [production.rb](file:///home/mm/co/voctoweb/config/environments/production.rb):
    ```diff
    - config.assets.configure do |env|
    -   env.js_compressor  = :uglifier
    -   env.css_compressor = :sass
    - end
    - config.assets.compile = false
    ```

### Step 5: Test the Build
1.  Compile assets locally to verify `pnpm` and `esbuild` tasks:
    ```bash
    rails assets:precompile
    ```
2.  Run the Minitest suite to verify full codebase stability:
    ```bash
    bin/rails test
    ```
