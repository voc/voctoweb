module ViewHelper

  def show_logo_url(conference)
    return nil if conference.logo.nil?
    "(#{File.join(MediaBackend::Application.config.staticURL, conference.get_images_url, conference.logo)})"
  end

  def show_logo_path(conference)
    return nil if conference.logo.nil?
    "#{conference.logo} (#{File.join(conference.get_images_path, conference.logo)})"
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

  def show_recording_url(recording)
    "(#{File.join(MediaBackend::Application.config.cdnURL, 
        recording.event.conference.get_recordings_url, recording.get_recording_webpath)})"
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
