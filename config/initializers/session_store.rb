# Be sure to restart your server when you modify this file.

MediaBackend::Application.config.session_store :cookie_store, key: '_media-backend_session', secure: Rails.env.production?
