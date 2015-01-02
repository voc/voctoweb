json.cache! json_cached_key(:event_oembed, @event), expires_in: 10.minutes do
  json.version '1.0'
  json.type 'video'
  json.provider_name 'media.ccc.de'
  json.provider_url 'http://media.ccc.de'
  json.width @width
  json.height @height
  json.title @event.title
  json.author @event.persons_text
  json.html <<-EOF
<video class='video' width="#{@width}" height="#{@height}" controls>
  <source src='#{@recording.get_recording_url}' type='#{MimeType.display_mime_type(@recording.mime_type)}'>
  <object data='http://media.ccc.de/assets/flashmediaelement.swf'
    type='application/x-shockwave-flash'>
    allowscriptaccess="always" allowfullscreen="true">
    <param name='flashvars' value='controls=true&amp;file=#{@recording.get_recording_url}'>
  </object>
</video>
  EOF
end
