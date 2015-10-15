module ViewHelper

  def oembed_url(url)
    url.gsub(/https?:/, '').gsub(/.html$/, '/oembed.html')
  end

  def frontend_link(event)
    [Settings.frontendURL, 'browse', event.conference.slug, event.slug].join('/') + '.html'
  end

  def show_recording_url(recording)
    "(#{recording.get_recording_url})"
  end

  def show_folder(label: 'Path', path: '/')
    return nil if label.empty?
    if File.readable? path
      "#{label} (#{path})"
    else
      "#{label} (missing: #{path})"
    end
  end

  def show_event_folder(event, filename)
    label = event.send(filename)
    path = File.join(event.conference.get_images_path, label)
    show_folder label: label, path: path
  end

  def show_recording_path(recording)
    show_folder label: recording.filename ,path: recording.get_recording_path
  end

end
