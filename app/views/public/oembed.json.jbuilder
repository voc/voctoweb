json.cache! json_cached_key(:event_oembed, @event), race_condition_ttl: 30 do
  json.version '1.0'
  json.type 'video'
  json.provider_name 'media.ccc.de'
  json.provider_url Settings.frontend_url
  json.width @width
  json.height @height
  json.title @event.title
  json.author @event.persons_text
  json.thumbnail_url @event.get_thumb_url
  json.html render(partial: 'html5player', formats: [:html], locals: { width: @width, height: @height, event: @event })
end
