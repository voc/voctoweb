module ViewHelper

  def oembed_url(url)
    url.gsub(/https?:/, '').gsub(/.html$/, '/oembed.html')
  end

  def frontend_link(event)
    [MediaBackend::Application.config.frontendURL, 'browse', event.conference.webgen_location, event.slug].join('/') + '.html'
  end

  def show_logo_url(conference)
    return nil if conference.logo.nil?
    "(#{conference.get_logo_url})"
  end

  def show_recording_url(recording)
    "(#{recording.get_recording_url})"
  end

  def show_logo_path(conference)
    return nil if conference.logo.nil?
    "#{conference.logo} (#{conference.get_logo_path})"
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

  def job_object(job)
    begin
      YAML.load(job.handler).object.class.to_s
    rescue
      ""
    end
  end

  def job_method(job)
    begin
      YAML.load(job.handler).method_name.to_s
    rescue
      ""
    end
  end

end
