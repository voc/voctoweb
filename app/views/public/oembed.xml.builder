xml.oembed do
  xml.version '1.0'
  xml.type 'video'
  xml.provider_name 'media.ccc.de'
  xml.provider_url Settings.frontend_url
  xml.width @width
  xml.height @height
  xml.title @event.title
  xml.author @event.persons_text
  xml.thumbnail_url @event.get_thumb_url
  xml.html render(partial: 'html5player', formats: [:html], locals: { width: @width, height: @height, event: @event })
end
