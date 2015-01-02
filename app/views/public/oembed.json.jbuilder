json.cache! json_cached_key(:event_oembed, @event), expires_in: 10.minutes do
  json.version '1.0'
  json.type 'video'
  json.provider_name 'media.ccc.de'
  json.provider_url 'http://media.ccc.de'
  json.width @width
  json.height @height
  json.title @event.title
  json.author @event.persons_text
  json.thumbnail_url @event.get_thumb_url
  json.html render(partial: 'html5player', formats: [:html], locals: { width: @width, height: @height, recording: @recording })
end
